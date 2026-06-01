---
name: stauff
description: Use when working in this project on STAUFF Clamps Excel workbooks, Supabase SQL files, catalogue overview rows, quoted catalogue table names, or workbook-to-Postgres imports.
---

# STAUFF Clamps Supabase

## Purpose

This project turns STAUFF catalogue Excel workbooks into Supabase/Postgres SQL under schema `stauff_clamps`. Default output is reviewable `.sql` files for the user to paste into Supabase SQL Editor.

## Ground Rules

- Use schema `stauff_clamps`.
- Use one physical table per catalogue/product page.
- Table names should be readable catalogue/product names, quoted in SQL, e.g. `stauff_clamps."Bolts and Screws (AS, IS)"`.
- Do not use `raw_page45`-style names.
- Postgres identifiers have a 63-byte limit; if a row-2 catalogue name is too long, use the shorter product label as the table name and retain the full text in `catalogue_name`.
- Generate SQL files locally; do not connect to or mutate Supabase unless the user explicitly asks for direct execution.
- For workbook parsing, use the bundled Python runtime and `openpyxl` when available.

## Current Project Files

- Main workbook bundle:
  - `db/stauff_clamps_schema.sql`
  - `db/clamps_data.sql`
  - `db/validate_stauff_clamps.sql`
  - `scripts/clamps_inserts.py`
- Page 44 bundle:
  - `db/page44_weld_plate_schema.sql`
  - `db/weld_plates_data.sql`
  - `db/validate_page44_weld_plate.sql`
  - `scripts/weld_plates_inserts.py`
- Utility SQL:
  - `db/list_stauff_clamps_tables.sql`
  - `db/drop_stauff_clamps_tables.sql`

## Table Design

### Catalogue Overview

Table: `stauff_clamps."Catalogue Overview"`

Keep this table minimal. Its business columns are:

- `catalogue_name`
- `products`
- `product_type`
- `permutations`

It has `id` and `imported_at` system columns in Supabase. Do not add back these removed overview columns:

- `source_file`
- `source_sheet`
- `catalogue_page_title`
- `permutation_summary`
- `section_title`
- `page`
- `sheet`

Add one overview row per product type. Example for page 44:

```sql
insert into stauff_clamps."Catalogue Overview"
  (catalogue_name, products, product_type, permutations)
values
  ('Heavy Series (DIN 3015, Part 2) - Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)', 'Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)', 'SPAL', '100'),
  ('Heavy Series (DIN 3015, Part 2) - Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)', 'Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)', 'SPAS', '100');
```

### Catalogue Page Tables

New page tables should keep row 1/2/3 metadata but should not include source-tracking columns.

Include:

- `id bigserial primary key`
- `catalogue_page_title` from row 1
- `catalogue_name` from row 2
- `permutation_summary` from row 3
- workbook data columns converted to clean snake_case names
- `imported_at timestamptz not null default now()`

Do not include:

- `source_file`
- `source_sheet`
- `source_row`

Create a unique index on `ordering_code` when the page has ordering codes.

## Workbook Import Workflow

1. Inspect workbook sheets, row 1, row 2, row 3, header row, row count, product type counts, and duplicate ordering codes.
2. Show the proposed table name and first 2 rows if the user asks for preview.
3. Create three SQL files:
   - `db/<page>_<name>_schema.sql`
   - `db/<page>_<name>_data.sql`
   - `db/validate_<page>_<name>.sql`
4. Prefer a small generator script in `scripts/` for large data inserts rather than hand-writing rows.
5. Data SQL should usually:
   - `begin;`
   - `truncate table <new table> restart identity;`
   - insert all page rows
   - delete existing matching overview rows
   - insert updated overview rows
   - `commit;`
6. Validation SQL should check:
   - expected row count
   - product type counts where applicable
   - no duplicate `ordering_code`
   - expected overview rows exist

## Supabase Paste Order

For each new catalogue page, tell the user to paste/run:

1. Schema SQL
2. Data SQL
3. Validation SQL

Use this query to list project tables:

```sql
select table_schema, table_name
from information_schema.tables
where table_schema = 'stauff_clamps'
  and table_type = 'BASE TABLE'
order by table_name;
```

Use this query to show table schemas:

```sql
select table_name, ordinal_position, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'stauff_clamps'
order by table_name, ordinal_position;
```

## Common Mistakes

- Looking for tables under `public`; they live under custom schema `stauff_clamps`.
- Forgetting quotes around table names with spaces and parentheses.
- Reintroducing `source_file`, `source_sheet`, or `source_row` to new page tables.
- Naming the overview table from its section heading; it must be `"Catalogue Overview"`.
- Using the full row-2 catalogue name as a physical table name when it exceeds Postgres identifier length.
