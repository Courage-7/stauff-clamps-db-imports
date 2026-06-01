-- STAUFF Clamps workbook import schema.
-- Seven physical tables only, named from the workbook/overview catalogue labels.
-- Note: Postgres identifiers are limited to 63 bytes, so full row-2 names are
-- retained in catalogue_name while table names use the shorter product labels.

create schema if not exists stauff_clamps;

create table if not exists stauff_clamps."Catalogue Overview" (
  id bigserial primary key,
  source_row integer not null,
  catalogue_name text,
  products text,
  product_type text,
  permutations text,
  imported_at timestamptz not null default now(),
  unique (source_row)
);

create table if not exists stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)" (
  id bigserial primary key,
  source_file text not null,
  source_sheet text not null,
  source_row integer not null,
  catalogue_page_title text,
  catalogue_name text,
  permutation_summary text,
  ordering_code text,
  product_type text,
  product_description text,
  stauff_groups text,
  din_groups text,
  thread_code text,
  thread text,
  size_d1 text,
  modifier text,
  material_code text,
  material_description text,
  notes text,
  imported_at timestamptz not null default now(),
  unique (source_sheet, source_row)
);

create table if not exists stauff_clamps."Cover Plates (DPAL, DPAS)" (
  id bigserial primary key,
  source_file text not null,
  source_sheet text not null,
  source_row integer not null,
  catalogue_page_title text,
  catalogue_name text,
  permutation_summary text,
  ordering_code text,
  product_type text,
  product_description text,
  stauff_groups text,
  din_groups text,
  thread_code text,
  thread text,
  size_d1 text,
  modifier text,
  material_code text,
  material_description text,
  notes text,
  imported_at timestamptz not null default now(),
  unique (source_sheet, source_row)
);

create table if not exists stauff_clamps."Bolts and Screws (AS, IS)" (
  id bigserial primary key,
  source_file text not null,
  source_sheet text not null,
  source_row integer not null,
  catalogue_page_title text,
  catalogue_name text,
  permutation_summary text,
  ordering_code text,
  product_type text,
  product_description text,
  stauff_groups text,
  din_groups text,
  thread_code text,
  thread text,
  size_d1 text,
  modifier text,
  material_code text,
  material_description text,
  notes text,
  imported_at timestamptz not null default now(),
  unique (source_sheet, source_row)
);

create table if not exists stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)" (
  id bigserial primary key,
  source_file text not null,
  source_sheet text not null,
  source_row integer not null,
  catalogue_page_title text,
  catalogue_name text,
  permutation_summary text,
  ordering_code text,
  product_type text,
  product_description text,
  stauff_groups text,
  din_groups text,
  thread_code text,
  thread text,
  size_d1 text,
  modifier text,
  material_code text,
  material_description text,
  notes text,
  imported_at timestamptz not null default now(),
  unique (source_sheet, source_row)
);

create table if not exists stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)" (
  id bigserial primary key,
  source_file text not null,
  source_sheet text not null,
  source_row integer not null,
  catalogue_page_title text,
  catalogue_name text,
  permutation_summary text,
  ordering_code text,
  product_type text,
  product_description text,
  stauff_groups text,
  din_groups text,
  thread_code text,
  thread text,
  size_d1 text,
  modifier text,
  material_code text,
  material_description text,
  notes text,
  imported_at timestamptz not null default now(),
  unique (source_sheet, source_row)
);

create table if not exists stauff_clamps."Material code reference" (
  id bigserial primary key,
  source_file text not null,
  source_sheet text not null,
  source_row integer not null,
  catalogue_page_title text,
  catalogue_name text,
  permutation_summary text,
  code text,
  material text,
  used_on_products text,
  imported_at timestamptz not null default now(),
  unique (source_sheet, source_row)
);

create index if not exists stauff_clamps_permutations_source_row_idx
  on stauff_clamps."Catalogue Overview" (source_row);

create index if not exists stauff_clamps_material_code_idx
  on stauff_clamps."Material code reference" (code);

create index if not exists stauff_clamps_elongated_ordering_code_idx
  on stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)" (ordering_code);

create index if not exists stauff_clamps_cover_plates_ordering_code_idx
  on stauff_clamps."Cover Plates (DPAL, DPAS)" (ordering_code);

create index if not exists stauff_clamps_bolts_screws_ordering_code_idx
  on stauff_clamps."Bolts and Screws (AS, IS)" (ordering_code);

create index if not exists stauff_clamps_safety_washers_ordering_code_idx
  on stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)" (ordering_code);

create index if not exists stauff_clamps_safety_locking_ordering_code_idx
  on stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)" (ordering_code);

comment on schema stauff_clamps is 'STAUFF Clamps catalogue workbook import. One table per workbook sheet.';

comment on table stauff_clamps."Catalogue Overview" is 'Workbook sheet: Overview.';
comment on table stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)" is 'Workbook sheet: Page45. Full row-2 catalogue name is stored in catalogue_name.';
comment on table stauff_clamps."Cover Plates (DPAL, DPAS)" is 'Workbook sheet: Page50. Full row-2 catalogue name is stored in catalogue_name.';
comment on table stauff_clamps."Bolts and Screws (AS, IS)" is 'Workbook sheet: Page51. Full row-2 catalogue name is stored in catalogue_name.';
comment on table stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)" is 'Workbook sheet: Page52. Full row-2 catalogue name is stored in catalogue_name.';
comment on table stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)" is 'Workbook sheet: Page53. Full row-2 catalogue name is stored in catalogue_name.';
comment on table stauff_clamps."Material code reference" is 'Workbook sheet: Materials.';
