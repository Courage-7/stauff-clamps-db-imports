# STAUFF Clamps Database Import

This folder contains a local Postgres/Supabase import bundle for the STAUFF clamps workbooks.

**Project structure:**
- `data/` — Source Excel workbooks
- `scripts/` — Python importers
- `db/` — Generated SQL files and schema definitions

The database design is intentionally limited to **7 physical tables**: one table per workbook sheet. Tables are named from the workbook/overview catalogue labels.

## Tables

All tables live under schema `stauff_clamps`.

- `"Catalogue Overview"`
- `"Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"`
- `"Cover Plates (DPAL, DPAS)"`
- `"Bolts and Screws (AS, IS)"`
- `"Safety Washers (SI DIN 93, SI DIN 463)"`
- `"Safety Locking Plate & Stacking Bolt (SIP, AF)"`
- `"Material code reference"`

Postgres has a 63-byte identifier limit, so the full row-2 catalogue names with `-- Heavy Series (DIN 3015, Part 2)` are stored in `catalogue_name` instead of being used as physical table names.

Each table retains sheet data as text and includes source metadata:

- `source_file`
- `source_sheet`
- `source_row`
- `catalogue_page_title` from workbook row 1
- `catalogue_name` from workbook row 2
- `permutation_summary` from workbook row 3, when present

The `"Catalogue Overview"` table also includes `section_title` to retain the Overview sheet's row 4 value.

## Generate Data SQL

Run the importer from this folder:

```powershell
python scripts/import_stauff_clamps.py
```

That writes:

```text
db/stauff_clamps_data.sql
```

To validate workbook parsing without writing SQL:

```powershell
python scripts/import_stauff_clamps.py --dry-run
```

## Load Into Postgres/Supabase

Set `DATABASE_URL` to your Postgres/Supabase connection string, then run:

```powershell
psql "$env:DATABASE_URL" -f db/stauff_clamps_schema.sql
psql "$env:DATABASE_URL" -f db/stauff_clamps_data.sql
psql "$env:DATABASE_URL" -f db/validate_stauff_clamps.sql
```

To list the tables:

```powershell
psql "$env:DATABASE_URL" -f db/list_stauff_clamps_tables.sql
```

Or paste this into the Supabase SQL Editor:

```sql
select table_schema, table_name
from information_schema.tables
where table_schema = 'stauff_clamps'
  and table_type = 'BASE TABLE'
order by table_name;
```

To drop all STAUFF Clamps tables:

```powershell
psql "$env:DATABASE_URL" -f db/drop_stauff_clamps_tables.sql
```

Or paste this into the Supabase SQL Editor:

```sql
drop schema if exists stauff_clamps cascade;
```

Expected imported row counts:

- `"Catalogue Overview"`: 25
- `"Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"`: 200
- `"Cover Plates (DPAL, DPAS)"`: 103
- `"Bolts and Screws (AS, IS)"`: 112
- `"Safety Washers (SI DIN 93, SI DIN 463)"`: 24
- `"Safety Locking Plate & Stacking Bolt (SIP, AF)"`: 120
- `"Material code reference"`: 6

The page tables contain 559 total ordering-code rows.
