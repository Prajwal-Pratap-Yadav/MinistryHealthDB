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

## Directory row meaning

`vw_ministry_directory` has one row per division appointment, with the role
stored on `division_member`. A global `official_role` without a matching
division appointment appears once with a null division and joining date.
Matching global roles do not add another copy of a division appointment.
The portfolio and secretary-office columns describe the person, not the
role assigned within a division.

Global roles and division roles may differ. For example, the synthetic seed
gives Rohan a global Finance Minister role and a Deputy Secretary appointment
in PAEM. The directory retains those as two distinct rows. Joining every
global role to every division would mislabel appointments and multiply rows.
