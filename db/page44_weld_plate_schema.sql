-- STAUFF Clamps page 44 schema.
-- Creates one table for Weld Plate for Single Clamps (SPAL)
-- and Double Clamps (SPAS).

create schema if not exists stauff_clamps;

create table if not exists stauff_clamps."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)" (
  id bigserial primary key,
  catalogue_page_title text,
  catalogue_name text,
  permutation_summary text,
  ordering_code text,
  product_type text,
  product_description text,
  stauff_group text,
  din_group text,
  thread_code text,
  thread text,
  material_code text,
  material text,
  l1_mm numeric,
  l2_mm numeric,
  b_b1_mm numeric,
  b2_mm numeric,
  d1_mm numeric,
  imported_at timestamptz not null default now()
);

create unique index if not exists stauff_clamps_page44_weld_plate_ordering_code_idx
  on stauff_clamps."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)" (ordering_code);

comment on table stauff_clamps."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)"
  is 'Workbook page 44: Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS).';
