"""Run real MySQL contracts against an explicitly selected disposable Docker container."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

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
    missing_appointments = int(
        query("""
        SELECT COUNT(*) FROM division_member dm
        JOIN division d ON d.division_id = dm.division_id
        JOIN role r ON r.role_id = dm.role_id
        WHERE NOT EXISTS (
            SELECT 1 FROM vw_ministry_directory v
            WHERE v.official_id = dm.official_id
              AND v.division_code = d.division_code AND v.role_name = r.role_name
              AND v.joined_at = dm.joined_at
        );
    """)[0]
    )
    invented_appointments = int(
        query("""
        SELECT COUNT(*) FROM vw_ministry_directory v
        WHERE v.division_code IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM division_member dm
            JOIN division d ON d.division_id = dm.division_id
            JOIN role r ON r.role_id = dm.role_id
            WHERE dm.official_id = v.official_id
              AND d.division_code = v.division_code AND r.role_name = v.role_name
        );
    """)[0]
    )
    if missing_appointments or invented_appointments:
        raise AssertionError(
            f"Directory role/division mismatch: {missing_appointments} missing, "
            f"{invented_appointments} invented appointments"
        )
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
    # One connection keeps all fixture changes in a rollback-only transaction.
    # Exercise multiple roles/divisions instead of trusting populated row counts.
    view_probe_rows = query("""
        START TRANSACTION;
        INSERT INTO official(full_name) VALUES('__ci_member__');
        SET @member = LAST_INSERT_ID();
        INSERT INTO official(full_name) VALUES('__ci_secretary__');
        SET @secretary_official = LAST_INSERT_ID();
        INSERT INTO secretary(official_id, minister_id, office_title)
            SELECT @secretary_official, MIN(minister_id), 'Synthetic CI secretary'
            FROM minister;
        SET @secretary = LAST_INSERT_ID();
        SELECT 'empty_secretary', direct_reports = 0
            FROM vw_secretary_workload WHERE secretary_id = @secretary;
        INSERT INTO role(role_name)
            VALUES('__ci_role_a__'),('__ci_role_b__'),('__ci_global_role__');
        SET @role_a = (SELECT role_id FROM role WHERE role_name = '__ci_role_a__');
        SET @role_b = (SELECT role_id FROM role WHERE role_name = '__ci_role_b__');
        SET @global_role = (SELECT role_id FROM role WHERE role_name = '__ci_global_role__');
        INSERT INTO official_role VALUES
            (@member, @role_a, CURRENT_DATE()),
            (@member, @role_b, CURRENT_DATE()),
            (@member, @global_role, CURRENT_DATE());
        INSERT INTO division(division_code, division_name) VALUES
            ('__CI_A__', '__ci_division_a__'),
            ('__CI_B__', '__ci_division_b__'),
            ('__CI_EMPTY__', '__ci_empty_division__');
        SET @division_a = (SELECT division_id FROM division WHERE division_code = '__CI_A__');
        SET @division_b = (SELECT division_id FROM division WHERE division_code = '__CI_B__');
        INSERT INTO division_member VALUES
            (@division_a, @member, @role_a, @secretary, CURRENT_DATE()),
            (@division_b, @member, @role_b, @secretary, CURRENT_DATE());
        SELECT 'directory_role_division_pairs',
            COUNT(*) = 3
            AND COUNT(CASE WHEN role_name = '__ci_role_a__'
                AND division_code = '__CI_A__' THEN 1 END) = 1
            AND COUNT(CASE WHEN role_name = '__ci_role_b__'
                AND division_code = '__CI_B__' THEN 1 END) = 1
            AND COUNT(CASE WHEN role_name = '__ci_global_role__'
                AND division_code IS NULL AND joined_at IS NULL THEN 1 END) = 1
            FROM vw_ministry_directory WHERE official_id = @member;
        SELECT 'empty_division', member_count = 0
            FROM vw_division_summary WHERE division_code = '__CI_EMPTY__';
        SELECT 'one_membership_per_division', COUNT(*) = 2 AND SUM(member_count) = 2
            FROM vw_division_summary WHERE division_code IN ('__CI_A__', '__CI_B__');
        SELECT 'distinct_reports_across_divisions', direct_reports = 1
            FROM vw_secretary_workload WHERE secretary_id = @secretary;
        DELETE FROM secretary WHERE secretary_id = @secretary;
        SELECT 'secretary_delete_preserves_memberships',
            COUNT(*) = 2 AND COUNT(secretary_id) = 0
            FROM division_member WHERE official_id = @member;
        ROLLBACK;
    """)
    view_cases = {
        "empty_secretary",
        "directory_role_division_pairs",
        "empty_division",
        "one_membership_per_division",
        "distinct_reports_across_divisions",
        "secretary_delete_preserves_memberships",
    }
    observed = dict(row.split("\t") for row in view_probe_rows)
    if set(observed) != view_cases or any(value != "1" for value in observed.values()):
        raise AssertionError(f"Reporting view contracts failed: {observed}")
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
        "directory_appointments_reconcile": True,
        "passed_view_cases": sorted(view_cases),
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
