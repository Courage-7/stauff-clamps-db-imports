-- Validation checks for the seven-table STAUFF Clamps import.

do $$
declare
  bad_count integer;
begin
  with expected(table_name, expected_rows) as (
    values
      ('Catalogue Overview', 25),
      ('Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)', 200),
      ('Cover Plates (DPAL, DPAS)', 103),
      ('Bolts and Screws (AS, IS)', 112),
      ('Safety Washers (SI DIN 93, SI DIN 463)', 24),
      ('Safety Locking Plate & Stacking Bolt (SIP, AF)', 120),
      ('Material code reference', 6)
  ),
  actual as (
    select 'Catalogue Overview' as table_name, count(*)::integer as actual_rows
    from stauff_clamps."Catalogue Overview"
    union all
    select 'Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)', count(*)::integer
    from stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
    union all
    select 'Cover Plates (DPAL, DPAS)', count(*)::integer
    from stauff_clamps."Cover Plates (DPAL, DPAS)"
    union all
    select 'Bolts and Screws (AS, IS)', count(*)::integer
    from stauff_clamps."Bolts and Screws (AS, IS)"
    union all
    select 'Safety Washers (SI DIN 93, SI DIN 463)', count(*)::integer
    from stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)"
    union all
    select 'Safety Locking Plate & Stacking Bolt (SIP, AF)', count(*)::integer
    from stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)"
    union all
    select 'Material code reference', count(*)::integer
    from stauff_clamps."Material code reference"
  )
  select count(*) into bad_count
  from expected e
  join actual a using (table_name)
  where a.actual_rows <> e.expected_rows;

  if bad_count > 0 then
    raise exception 'STAUFF Clamps row-count validation failed.';
  end if;
end $$;

do $$
declare
  duplicate_count integer;
begin
  with all_codes as (
    select ordering_code from stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
    union all select ordering_code from stauff_clamps."Cover Plates (DPAL, DPAS)"
    union all select ordering_code from stauff_clamps."Bolts and Screws (AS, IS)"
    union all select ordering_code from stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)"
    union all select ordering_code from stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)"
  )
  select count(*) into duplicate_count
  from (
    select ordering_code
    from all_codes
    where ordering_code is not null
    group by ordering_code
    having count(*) > 1
  ) duplicates;

  if duplicate_count > 0 then
    raise exception 'STAUFF Clamps duplicate ordering-code validation failed.';
  end if;
end $$;

do $$
declare
  missing_material_count integer;
begin
  with all_material_codes as (
    select material_code from stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
    union all select material_code from stauff_clamps."Cover Plates (DPAL, DPAS)"
    union all select material_code from stauff_clamps."Bolts and Screws (AS, IS)"
    union all select material_code from stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)"
    union all select material_code from stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)"
  )
  select count(*) into missing_material_count
  from (
    select distinct material_code
    from all_material_codes
    where material_code is not null
      and material_code <> '—'
      and material_code not in (
        select code from stauff_clamps."Material code reference"
      )
  ) missing;

  if missing_material_count > 0 then
    raise exception 'STAUFF Clamps material-code validation failed.';
  end if;
end $$;

do $$
declare
  missing_metadata_count integer;
begin
  with all_page_rows as (
    select source_sheet, source_row, catalogue_page_title, catalogue_name, permutation_summary
    from stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
    union all
    select source_sheet, source_row, catalogue_page_title, catalogue_name, permutation_summary
    from stauff_clamps."Cover Plates (DPAL, DPAS)"
    union all
    select source_sheet, source_row, catalogue_page_title, catalogue_name, permutation_summary
    from stauff_clamps."Bolts and Screws (AS, IS)"
    union all
    select source_sheet, source_row, catalogue_page_title, catalogue_name, permutation_summary
    from stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)"
    union all
    select source_sheet, source_row, catalogue_page_title, catalogue_name, permutation_summary
    from stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)"
  )
  select count(*) into missing_metadata_count
  from all_page_rows
  where catalogue_page_title is null
     or catalogue_name is null
     or permutation_summary is null;

  if missing_metadata_count > 0 then
    raise exception 'STAUFF Clamps page metadata validation failed.';
  end if;
end $$;

select 'row_counts' as check_name, *
from (
  select 'Catalogue Overview' as table_name, count(*)::integer as rows
  from stauff_clamps."Catalogue Overview"
  union all
  select 'Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)', count(*)::integer
  from stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
  union all
  select 'Cover Plates (DPAL, DPAS)', count(*)::integer
  from stauff_clamps."Cover Plates (DPAL, DPAS)"
  union all
  select 'Bolts and Screws (AS, IS)', count(*)::integer
  from stauff_clamps."Bolts and Screws (AS, IS)"
  union all
  select 'Safety Washers (SI DIN 93, SI DIN 463)', count(*)::integer
  from stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)"
  union all
  select 'Safety Locking Plate & Stacking Bolt (SIP, AF)', count(*)::integer
  from stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)"
  union all
  select 'Material code reference', count(*)::integer
  from stauff_clamps."Material code reference"
) counts
order by table_name;

select 'total_page_ordering_codes' as check_name, count(*)::integer as rows
from (
  select ordering_code from stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
  union all select ordering_code from stauff_clamps."Cover Plates (DPAL, DPAS)"
  union all select ordering_code from stauff_clamps."Bolts and Screws (AS, IS)"
  union all select ordering_code from stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)"
  union all select ordering_code from stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)"
) all_codes;

select *
from (
  select source_sheet, source_row, ordering_code, product_type, material_code, catalogue_name
  from stauff_clamps."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
  union all
  select source_sheet, source_row, ordering_code, product_type, material_code, catalogue_name
  from stauff_clamps."Cover Plates (DPAL, DPAS)"
  union all
  select source_sheet, source_row, ordering_code, product_type, material_code, catalogue_name
  from stauff_clamps."Bolts and Screws (AS, IS)"
  union all
  select source_sheet, source_row, ordering_code, product_type, material_code, catalogue_name
  from stauff_clamps."Safety Washers (SI DIN 93, SI DIN 463)"
  union all
  select source_sheet, source_row, ordering_code, product_type, material_code, catalogue_name
  from stauff_clamps."Safety Locking Plate & Stacking Bolt (SIP, AF)"
) all_page_rows
where ordering_code = 'AS-M10x45-W1';
