# Database design

## Design goal

The original SQL repeated person and position columns across multiple division tables. The maintained schema normalizes those concepts into shared entities and a membership relationship.

## Entities

- **official** — person/official master data.
- **role** — controlled role vocabulary.
- **official_role** — many-to-many role assignment.
- **minister** — minister leadership assignment and portfolio.
- **secretary** — secretary assignment under a minister.
- **division** — organizational division catalog.
- **division_member** — staffing relationship with an optional secretary owner.

## Integrity choices

- Surrogate integer primary keys provide stable row identity.
- Unique constraints protect master-data names and division codes.
- Core hierarchy deletion is restricted.
- Division membership can survive a secretary reassignment via `SET NULL`.
- Foreign-key paths are explicitly indexed.
- `utf8mb4` is used for text compatibility.

The original `Code.sql` remains the historical artifact. New work should use `sql/`.
