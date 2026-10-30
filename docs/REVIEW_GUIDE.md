# MinistryHealthDB relational model: review guide

Review normalization and constraints through synthetic fixtures, reporting views, and real MySQL rejection cases.

## Follow the implementation

| Start here | File | What to inspect |
| --- | --- | --- |
| Schema | [sql/01_schema.sql](../sql/01_schema.sql) | Seven normalized tables, keys, and referential actions. |
| Synthetic seed | [sql/02_seed.sql](../sql/02_seed.sql) | Small educational fixtures. |
| Reporting views | [sql/03_views.sql](../sql/03_views.sql) | Reusable organizational reports. |
| Engine verifier | [scripts/verify_database.py](../scripts/verify_database.py) | Real constraint failures, view reconciliation, and rollback checks. |
| Validation contract | [docs/validation.md](../docs/validation.md) | How disposable MySQL CI differs from read-only SQL inspection. |

## Run the checks

Run from the repository root after the setup described in the [README](../README.md). Review fixtures and recorded evidence before starting any full experiment.

```bash
# Use the disposable-container instructions in docs/validation.md.
# CI creates MySQL 8.4 and runs:
python scripts/verify_database.py --container YOUR_DEMO_CONTAINER --initialize-demo
```

## Interpret the evidence

The initialization option recreates demo tables in the explicitly selected container. Use only a disposable local instance, with MYSQL_PWD set as documented. Names are synthetic examples. This schema does not represent current ministry staffing or patient records.

The linked reports retain their original experiment dates and protocols. A new passing CI run verifies its named checks; it does not silently refresh historical measurements.

## Discuss the design

- Which invariants belong in foreign keys rather than application code?
- How can a failing SQL statement be tested without changing the seed fixtures?
