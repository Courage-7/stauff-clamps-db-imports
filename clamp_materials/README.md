# Clamp Materials SQL Bundle

Generated from `STAUFF_178_181_ 1.xlsx`, sheets `178`, `179`, `180`, and `181`.

## Files

- `db/clamp_materials_schema.sql` creates `public.clamp_materials`.
- `db/clamp_materials_data.sql` truncates and inserts the 12 material records.
- `db/validate_clamp_materials.sql` verifies row counts, material codes, and required property groups.

## Supabase SQL Editor Order

1. Run `db/clamp_materials_schema.sql`.
2. Run `db/clamp_materials_data.sql`.
3. Run `db/validate_clamp_materials.sql`.
