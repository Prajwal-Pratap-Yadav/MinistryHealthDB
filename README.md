# MinistryHealthDB

<p align="center">
  <img src="docs/assets/ministryhealthdb.svg" alt="MinistryHealthDB — relational health ministry database" width="760">
</p>

<p align="center">
  <strong>A normalized MySQL model for ministry leadership, organizational divisions, and service administration.</strong>
</p>

<p align="center">
  <img alt="MySQL 8+" src="https://img.shields.io/badge/MySQL-8.0%2B-4479A1?style=flat-square">
  <img alt="Schema" src="https://img.shields.io/badge/schema-normalized-0F766E?style=flat-square">
  <img alt="Validation" src="https://img.shields.io/badge/validation-SQL_smoke_test-7C3AED?style=flat-square">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-16A34A?style=flat-square">
</p>

## What this project demonstrates

MinistryHealthDB is an **educational relational-database project** focused on turning a repeated departmental schema into a maintainable, normalized model.

The maintained schema separates people, roles, leadership assignments, divisions, and division membership. The original `Code.sql` remains as historical material; maintained development happens under `sql/`.

### Model at a glance

```text
Official ──< OfficialRole >── Role
   │
   ├── Minister ──< Secretary
   │
   └──< DivisionMember >── Division
                 │
                 └── Secretary (optional owner)
```

## Quick start

```bash
git clone https://github.com/Prajwal-Pratap-Yadav/MinistryHealthDB.git
cd MinistryHealthDB

mysql -u root -p < sql/01_schema.sql
mysql -u root -p ministry_health < sql/02_seed.sql
mysql -u root -p ministry_health < sql/03_views.sql
mysql -u root -p ministry_health < sql/04_validation.sql
```

The validation script is read-only.

## Why the maintained model is different

| Legacy pattern | Maintained model |
|---|---|
| One table per division | One `division` catalog + `division_member` bridge |
| Person/position repeated everywhere | Central `official` + `role` |
| Relationships inferred from names | Explicit foreign keys |
| Ad-hoc reports | Reusable views |
| No repeatable integrity check | Dedicated validation script |
| Schema and demo data mixed | Schema, seed, views, validation separated |

## Core tables

| Table | Responsibility |
|---|---|
| `official` | Person/official master data |
| `role` | Controlled role vocabulary |
| `official_role` | Role assignments |
| `minister` | Minister leadership assignment |
| `secretary` | Secretary assignment under a minister |
| `division` | Organizational division catalog |
| `division_member` | Division staffing and optional secretary ownership |

## Reporting surfaces

```sql
SELECT * FROM vw_ministry_directory
ORDER BY division_code, full_name;

SELECT * FROM vw_division_summary
ORDER BY member_count DESC, division_code;

SELECT * FROM vw_secretary_workload
ORDER BY direct_reports DESC, secretary_name;
```

## Validation contract

```bash
mysql -u root -p ministry_health < sql/04_validation.sql
```

A healthy seeded database should have zero orphan counts, zero duplicate names/codes, no empty divisions, and populated reporting views.

## Data note

Sample names are synthetic examples carried forward from the original project. They are not presented as current real-world ministry records.

## Historical source material

The repository keeps the original `Code.sql`, EER diagram PDF, and documentation PDF for provenance. The maintained model improves the schema without silently rewriting those artifacts.

## Repository structure

```text
.
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   ├── 03_views.sql
│   └── 04_validation.sql
├── docs/
│   ├── README.md
│   ├── setup.md
│   ├── database_design.md
│   ├── queries.md
│   ├── validation.md
│   └── assets/ministryhealthdb.svg
├── Code.sql
├── Government Health System EER Diagram.pdf
├── MinistryHealthDB_Documentation.pdf
├── CONTRIBUTING.md
├── CHANGELOG.md
└── LICENSE
```

## License

MIT.
