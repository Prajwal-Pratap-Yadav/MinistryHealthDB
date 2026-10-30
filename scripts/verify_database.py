"""Run real MySQL contracts against an explicitly selected disposable Docker container."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess

TABLES = (
    "official",
    "role",
    "official_role",
    "minister",
    "secretary",
    "division",
    "division_member",
)
ROOT = Path(__file__).resolve().parents[1]


def verify(container: str, initialize: bool = False) -> dict:
    def client(sql: str, database: bool = True):
        command = [
            "docker",
            "exec",
            "-i",
            "--env",
            "MYSQL_PWD",
            container,
            "mysql",
            "--batch",
            "--skip-column-names",
            "-uroot",
        ]
        if database:
            command.append("ministry_health")
        return subprocess.run(
            command, input=sql, text=True, capture_output=True, check=False
        )

    def query(sql: str) -> list[str]:
        result = client(sql)
        if result.returncode:
            raise RuntimeError(result.stderr)
        return result.stdout.strip().splitlines()

    if initialize:
        # Destructive only inside the container explicitly supplied by the caller.
        for name in [
            "01_schema.sql",
            "02_seed.sql",
            "03_views.sql",
            "04_validation.sql",
        ]:
            result = client((ROOT / "sql" / name).read_text(), database=False)
            if result.returncode:
                raise RuntimeError(f"{name}: {result.stderr}")
    counts = {name: int(query(f"SELECT COUNT(*) FROM `{name}`;")[0]) for name in TABLES}
    if not all(counts.values()):
        raise AssertionError("Every seeded core table must be populated")
    views = {
        name: int(query(f"SELECT COUNT(*) FROM {name};")[0])
        for name in [
            "vw_ministry_directory",
            "vw_division_summary",
            "vw_secretary_workload",
        ]
    }
    if not all(views.values()):
        raise AssertionError("Reporting views must be populated")
    if views["vw_division_summary"] != counts["division"]:
        raise AssertionError("Division summary must retain one row per division")
    total_members = int(query("SELECT SUM(member_count) FROM vw_division_summary;")[0])
    if total_members != counts["division_member"]:
        raise AssertionError("Summary member counts must reconcile to the bridge table")
    negative_cases = {
        "unknown_official_fk": (
            "INSERT INTO official_role VALUES(4294967295,1,CURRENT_DATE());",
            1452,
        ),
        "duplicate_official_name": (
            "INSERT INTO official(full_name) VALUES('__ci_unique__'); INSERT INTO official(full_name) VALUES('__ci_unique__');",
            1062,
        ),
        "null_official_name": ("INSERT INTO official(full_name) VALUES(NULL);", 1048),
        "duplicate_role_assignment": (
            "INSERT INTO official_role SELECT official_id,role_id,assigned_at FROM official_role LIMIT 1;",
            1062,
        ),
        "referenced_official_delete": (
            "DELETE FROM official WHERE official_id=(SELECT official_id FROM official_role LIMIT 1);",
            1451,
        ),
    }
    for name, (statement, code) in negative_cases.items():
        result = client("START TRANSACTION;\n" + statement + "\nROLLBACK;")
        if result.returncode == 0 or f"ERROR {code}" not in result.stderr:
            raise AssertionError(
                f"Constraint case {name} did not reject with MySQL error {code}: {result.stderr}"
            )
    after = {name: int(query(f"SELECT COUNT(*) FROM `{name}`;")[0]) for name in TABLES}
    if after != counts:
        raise AssertionError("Constraint probes must leave all seeded counts unchanged")
    # CREATE OR REPLACE VIEW must remain repeatable.
    result = client((ROOT / "sql/03_views.sql").read_text())
    if result.returncode:
        raise RuntimeError(result.stderr)
    return {
        "engine": query("SELECT VERSION();")[0],
        "row_counts": counts,
        "view_rows": views,
        "member_count_reconciles": True,
        "rejected_constraint_cases": list(negative_cases),
        "transaction_probes_left_seed_unchanged": True,
        "view_recreation": "passed",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--container",
        required=True,
        help="Disposable MySQL container, never a production service",
    )
    parser.add_argument(
        "--initialize-demo",
        action="store_true",
        help="Recreate the demo schema inside that container",
    )
    parser.add_argument(
        "--output", type=Path, default=Path("reports/local/mysql-contract.json")
    )
    args = parser.parse_args()
    if not os.environ.get("MYSQL_PWD"):
        parser.error("Set MYSQL_PWD to the disposable container's root password")
    report = verify(args.container, args.initialize_demo)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
