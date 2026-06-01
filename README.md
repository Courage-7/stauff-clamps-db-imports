# STAUFF Clamps Database Import

Convert STAUFF clamps Excel workbooks into SQL import bundles for Postgres/Supabase. This project parses product catalogues and generates migration-ready `.sql` files without connecting directly to your database.

**What it does:**
- Reads STAUFF clamps Excel workbooks
- Extracts product data, metadata, and permutation summaries
- Generates reviewable SQL files for safe import into Postgres/Supabase
- Retains source file metadata for audit trails

## Project Structure

```
├── data/                      # Source Excel workbooks
├── scripts/                   # Python import generators
│   ├── clamps_inserts.py                # Main importer (7-table bundle)
│   └── weld_plates_inserts.py           # Page 44 specialized importer
├── db/                        # Generated SQL (git-tracked)
│   ├── stauff_clamps_schema.sql         # Table definitions
│   ├── clamps_data.sql                  # Generated data inserts (pages 45-53)
│   ├── weld_plates_data.sql             # Generated weld plate inserts (page 44)
│   └── validate_stauff_clamps.sql       # Row count validation
├── requirements.txt           # Python dependencies
├── README.md
└── SKILL.md                   # Project context for AI tools
```

## Database Design

The schema uses **7 physical tables**, one per workbook sheet, named from catalogue labels:

## Tables

All tables live under schema `stauff_clamps`:

- `"Catalogue Overview"` — Product index with permutation counts
- `"Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"` — Page 45 data (200 rows)
- `"Cover Plates (DPAL, DPAS)"` — Page 50 data (103 rows)
- `"Bolts and Screws (AS, IS)"` — Page 51 data (112 rows)
- `"Safety Washers (SI DIN 93, SI DIN 463)"` — Page 52 data (24 rows)
- `"Safety Locking Plate & Stacking Bolt (SIP, AF)"` — Page 53 data (120 rows)
- `"Material code reference"` — Page 54 materials (6 rows)

Postgres has a 63-byte identifier limit, so full catalogue names are stored in the `catalogue_name` column rather than used as physical table names.

Each table includes source metadata for audit trails:
- `source_file` — The Excel filename
- `source_sheet` — Sheet name in workbook
- `source_row` — Row number in sheet
- `catalogue_page_title` — Row 1 of sheet
- `catalogue_name` — Row 2 of sheet (full catalogue label)
- `permutation_summary` — Row 3 of sheet (when present)
- `section_title` — Row 4 of sheet (Overview sheet only)

## Setup

1. **Install dependencies:**
   ```powershell
   pip install -r requirements.txt
   ```

2. **Add workbooks to `data/` folder:**
   - Main bundle: `STAUFF_pages_45_50_51_52_53_ordering_codes - Copy.xlsx`
   - Optional page 44: `!STAUFF_page44_ordering_codes(Ordering Codes).xlsx`

## Usage

### Generate SQL from main workbook

Run the importer from the project root:

```powershell
python scripts/clamps_inserts.py
```

This generates `db/clamps_data.sql` with INSERT statements.

**Dry-run mode** (validate parsing without writing SQL):
```powershell
python scripts/clamps_inserts.py --dry-run
```

### Generate SQL for Page 44 (Weld Plates)

```powershell
python scripts/weld_plates_inserts.py
```

Generates `db/weld_plates_data.sql` (200 weld plate rows).

## Import Into Postgres/Supabase

### Option 1: Via psql (local Postgres)

Set your database connection:
```powershell
$env:DATABASE_URL = "postgresql://user:password@localhost:5432/database"
```

Then run the migrations in order:
```powershell
psql "$env:DATABASE_URL" -f db/stauff_clamps_schema.sql
psql "$env:DATABASE_URL" -f db/stauff_clamps_data.sql
psql "$env:DATABASE_URL" -f db/validate_stauff_clamps.sql
```

### Option 2: Via Supabase SQL Editor

Copy and paste into [Supabase SQL Editor](https://supabase.com/dashboard/project/_/sql/new):

1. **Create schema and tables:**
   - Copy contents of `db/stauff_clamps_schema.sql`

2. **Load data:**
   - Copy contents of `db/stauff_clamps_data.sql`

3. **Validate import:**
   - Copy contents of `db/validate_stauff_clamps.sql`

### Verify Import

List all STAUFF tables:
```sql
select table_schema, table_name
from information_schema.tables
where table_schema = 'stauff_clamps'
  and table_type = 'BASE TABLE'
order by table_name;
```

Expected row counts:
- `"Catalogue Overview"`: 25 rows
- `"Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"`: 200 rows
- `"Cover Plates (DPAL, DPAS)"`: 103 rows
- `"Bolts and Screws (AS, IS)"`: 112 rows
- `"Safety Washers (SI DIN 93, SI DIN 463)"`: 24 rows
- `"Safety Locking Plate & Stacking Bolt (SIP, AF)"`: 120 rows
- `"Material code reference"`: 6 rows
- **Page 44 (Weld Plates):** 200 additional rows

**Total:** 559 product rows + 25 overview = 584 rows

### Cleanup

Drop all STAUFF tables:

```powershell
$env:DATABASE_URL = "your_connection_string"
psql "$env:DATABASE_URL" -c "drop schema if exists stauff_clamps cascade;"
```

Or in Supabase SQL Editor:
```sql
drop schema if exists stauff_clamps cascade;
```

## Development

### Scripts Overview

| Script | Purpose | Input | Output |
|--------|---------|-------|--------|
| `clamps_inserts.py` | Parse main workbook (pages 45-53) | `data/*.xlsx` | `db/clamps_data.sql` |
| `weld_plates_inserts.py` | Parse page 44 weld plates | `data/*.xlsx` | `db/weld_plates_data.sql` |

### Adding New Workbooks

1. Place Excel file in `data/` folder
2. Update the script to reference the new file
3. Run importer to generate SQL
4. Review generated `.sql` file before importing

All metadata is preserved in the `catalogue_page_title`, `catalogue_name`, and `source_*` columns for full traceability.
