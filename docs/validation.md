# Validation on a real MySQL engine

The maintained SQL is MySQL8, not SQLite. The CI workflow starts a disposable
MySQL8.4 container, loads schema/seed/views, and runs
[`scripts/verify_database.py`](../scripts/verify_database.py).

| Contract | Verification |
|---|---|
| Seven core tables and three views are populated | Actual engine row counts |
| Division membership is counted once | Summary totals reconcile to the bridge table |
| Relationships reject missing people | Foreign-key error1452 |
| Names and composite role assignments are unique | Duplicate-key error1062 |
| Official names are mandatory | Null-value error1048 |
| Referenced officials cannot be deleted | Referential error1451 |
| Failed probes do not alter sample data | Transactions and before/after counts |
| View definitions are repeatable | Reapply03_views.sql successfully |

The `mysql-contract` Actions artifact records the engine version, counts and
constraint cases from that run. A green run is required before claiming that
the engine checks passed. This is a synthetic demonstration, not an audit of
real ministry records or a production migration.

`sql/01_schema.sql` drops and recreates maintained demo tables. Use a disposable
database for the setup commands. The ordinary `sql/04_validation.sql` file only
reads data; its printed counts by themselves do not make a CI job fail.

For a container you created solely for this test, set its test password through
`MYSQL_PWD`, then run:

```bash
python scripts/verify_database.py --container YOUR_DISPOSABLE_CONTAINER --initialize-demo
```
