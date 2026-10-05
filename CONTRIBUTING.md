# Contributing to MinistryHealthDB

Thank you for improving MinistryHealthDB.

## Development workflow

1. Fork the repository or create a feature branch.
2. Keep schema, seed data, views, and validation changes separated when practical.
3. Run the SQL scripts against a disposable MySQL 8+ database.
4. Run `sql/04_validation.sql` and verify zero integrity violations.
5. Update documentation when the data model or setup workflow changes.
6. Open a pull request with a concise description of the database change and verification performed.

## SQL standards

- Use explicit primary and foreign keys.
- Prefer `NOT NULL` when a field is required.
- Add indexes for foreign-key and common filtering paths.
- Use descriptive constraint/index names.
- Keep demo data synthetic.
- Avoid destructive changes outside the reproducible development schema.

## Pull requests

A good PR should explain:
- what changed;
- why the schema/query behavior changed;
- how it was validated;
- whether any migration or compatibility consideration exists.

## Scope

This is an educational database project, not a production government information system.
