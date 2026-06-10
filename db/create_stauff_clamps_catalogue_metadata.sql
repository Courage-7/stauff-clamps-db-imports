-- Create and refresh the public STAUFF catalogue metadata table.
-- This file is safe to rerun. It rebuilds the metadata snapshot from the
-- current public base tables, excluding emails, legacy metadata, and this metadata table.

begin;

create table if not exists public."STAUFF Clamps Catalogue Metadata" (
  id bigserial primary key,
  table_name text not null unique,
  properties text not null,
  permutation_summary bigint not null,
  description text not null
);

comment on table public."STAUFF Clamps Catalogue Metadata"
  is 'Metadata snapshot for STAUFF public catalogue tables.';

truncate table public."STAUFF Clamps Catalogue Metadata" restart identity;

do $$
declare
  table_record record;
  table_row_count bigint;
  table_properties text;
  table_description text;
begin
  for table_record in
    select t.table_name
    from information_schema.tables t
    where t.table_schema = 'public'
      and t.table_type = 'BASE TABLE'
      and t.table_name not in ('emails', 'Metadata', 'STAUFF Clamps Catalogue Metadata')
    order by t.table_name
  loop
    execute format('select count(*)::bigint from public.%I', table_record.table_name)
      into table_row_count;

    select coalesce(string_agg(c.column_name, ' | ' order by c.ordinal_position), '')
    into table_properties
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = table_record.table_name
      and c.column_name not in ('imported_at', 'created_at', 'received_at');

    table_description := case table_record.table_name
      when 'Catalogue Overview' then
        'High-level catalogue index summarizing STAUFF product families, product types, and available ordering-code permutations.'
      when 'clamp_materials' then
        'Clamp body and insert material reference covering material categories, material codes, physical properties, temperature resistance, chemical resistance, and approvals.'
      when 'Cover Plate for Double Clamps (DPAS)' then
        'Ordering-code catalogue for DPAS cover plates for double clamps, including STAUFF groups, DIN groups, size details, material codes, and notes.'
      when 'Cover Plate for Single Clamps (DPAL)' then
        'Ordering-code catalogue for DPAL cover plates for single clamps, including STAUFF groups, DIN groups, size details, material codes, and notes.'
      when 'Elongated Weld Plate for Double Clamps (SPAS-DUEB)' then
        'Ordering-code catalogue for SPAS-DUEB elongated weld plates for double clamps, including group compatibility, thread details, size details, and materials.'
      when 'Elongated Weld Plate for Single Clamps (SPAL-DUEB)' then
        'Ordering-code catalogue for SPAL-DUEB elongated weld plates for single clamps, including group compatibility, thread details, size details, and materials.'
      when 'Hexagon Head Bolt (AS)' then
        'Ordering-code catalogue for AS hexagon head bolts, including STAUFF group coverage, DIN group coverage, thread style, bolt size, material codes, and notes.'
      when 'Material code reference' then
        'Reference table mapping STAUFF material codes to material descriptions and the product families where each material code is used.'
      when 'Requests' then
        'Customer support and product recommendation requests, including sender, company, subject, request details, and resolution status.'
      when 'Safety Locking Plate (SIP)' then
        'Ordering-code catalogue for SIP safety locking plates, including group coverage, size details, material codes, and catalogue notes.'
      when 'Safety Washer DIN 463 (SI)' then
        'Ordering-code catalogue for SI safety washers conforming to DIN 463, including applicable clamp groups, size details, material codes, and notes.'
      when 'Safety Washer DIN 93 (SI)' then
        'Ordering-code catalogue for SI safety washers conforming to DIN 93, including applicable clamp groups, size details, material codes, and notes.'
      when 'Socket Cap Screw (IS)' then
        'Ordering-code catalogue for IS socket cap screws, including STAUFF group coverage, DIN group coverage, thread style, screw size, material codes, and notes.'
      when 'Stacking Bolt (AF)' then
        'Ordering-code catalogue for AF stacking bolts, including group coverage, size details, material codes, and catalogue notes.'
      when 'Weld Plate for Double Clamps (SPAS)' then
        'Ordering-code catalogue for SPAS weld plates for double clamps, including group compatibility, DIN groups, thread details, material codes, and dimensional measurements.'
      when 'Weld Plate for Single Clamps (SPAL)' then
        'Ordering-code catalogue for SPAL weld plates for single clamps, including group compatibility, DIN groups, thread details, material codes, and dimensional measurements.'
      else
        format(
          'Metadata for public table %s, including listed columns and current record count.',
          table_record.table_name
        )
    end;

    insert into public."STAUFF Clamps Catalogue Metadata"
      (table_name, properties, permutation_summary, description)
    values
      (table_record.table_name, table_properties, table_row_count, table_description);
  end loop;
end $$;

commit;
