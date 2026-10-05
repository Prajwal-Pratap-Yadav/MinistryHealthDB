# Setup

## Requirements
- MySQL 8.0+
- MySQL client or MySQL Workbench

## Install
Run from the repository root:

```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p ministry_health < sql/02_seed.sql
mysql -u root -p ministry_health < sql/03_views.sql
mysql -u root -p ministry_health < sql/04_validation.sql
```

Run in order. `01_schema.sql` resets only the maintained development tables.

## Workbench
Open each SQL file in MySQL Workbench and execute them in order. Refresh the schema browser after the first script.

## Reset
For a local development reset:

```sql
DROP DATABASE IF EXISTS ministry_health;
```

Then rerun `01_schema.sql` through `04_validation.sql`.

## Quick verification

```sql
USE ministry_health;
SELECT * FROM vw_division_summary;
SELECT * FROM vw_secretary_workload;
SELECT * FROM vw_ministry_directory LIMIT 20;
```
