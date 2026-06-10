-- Validation checks for the STAUFF clamp materials import.

do $$
declare
  actual_rows integer;
begin
  select count(*)::integer into actual_rows
  from public.clamp_materials;

  if actual_rows <> 12 then
    raise exception 'Clamp materials row-count validation failed. Expected 12, got %.', actual_rows;
  end if;
end $$;

do $$
declare
  bad_count integer;
begin
  with expected(material_category, component_type, expected_rows) as (
    values
      ('Standard Clamp Body Materials', 'clamp_body', 4),
      ('Standard Clamp Insert Materials', 'clamp_insert', 2),
      ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'clamp_body', 6)
  ),
  actual as (
    select material_category, component_type, count(*)::integer as actual_rows
    from public.clamp_materials
    group by material_category, component_type
  )
  select count(*) into bad_count
  from expected e
  left join actual a using (material_category, component_type)
  where coalesce(a.actual_rows, 0) <> e.expected_rows;

  if bad_count > 0 then
    raise exception 'Clamp materials category/component count validation failed.';
  end if;
end $$;

do $$
declare
  missing_count integer;
begin
  with expected(material_category, component_type, material_code) as (
    values
      ('Standard Clamp Body Materials', 'clamp_body', 'PP'),
      ('Standard Clamp Body Materials', 'clamp_body', 'PA'),
      ('Standard Clamp Body Materials', 'clamp_body', 'AL'),
      ('Standard Clamp Body Materials', 'clamp_body', 'SA'),
      ('Standard Clamp Insert Materials', 'clamp_insert', 'SA'),
      ('Standard Clamp Insert Materials', 'clamp_insert', 'EPDM'),
      ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'clamp_body', 'PA-V0-BK'),
      ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'clamp_body', 'PP-DA'),
      ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'clamp_body', 'PA-GF30-USR'),
      ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'clamp_body', 'PP6853'),
      ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'clamp_body', 'PP-V0'),
      ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'clamp_body', 'SA-V0')
  )
  select count(*) into missing_count
  from expected e
  left join public.clamp_materials c
    on c.material_category = e.material_category
   and c.component_type = e.component_type
   and c.material_code = e.material_code
  where c.id is null;

  if missing_count > 0 then
    raise exception 'Clamp materials expected material-code validation failed.';
  end if;
end $$;

do $$
declare
  duplicate_count integer;
begin
  select count(*) into duplicate_count
  from (
    select material_category, component_type, material_code
    from public.clamp_materials
    group by material_category, component_type, material_code
    having count(*) > 1
  ) duplicates;

  if duplicate_count > 0 then
    raise exception 'Clamp materials duplicate key validation failed.';
  end if;
end $$;

do $$
declare
  source_sheet_columns integer;
begin
  select count(*) into source_sheet_columns
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'clamp_materials'
    and column_name = 'source_sheet';

  if source_sheet_columns > 0 then
    raise exception 'Clamp materials source_sheet column should not exist.';
  end if;
end $$;

do $$
declare
  missing_chemical_count integer;
begin
  select count(*) into missing_chemical_count
  from public.clamp_materials
  where material_scope = 'standard'
    and component_type in ('clamp_body', 'clamp_insert')
    and (
      weak_acids is null or solvents is null or benzine is null or mineral_oils is null
      or other_oils is null or alcohols is null or seawater is null
    );

  if missing_chemical_count > 0 then
    raise exception 'Clamp materials chemical property validation failed.';
  end if;
end $$;

do $$
declare
  missing_approval_count integer;
begin
  select count(*) into missing_approval_count
  from public.clamp_materials
  where material_scope = 'special'
    and component_type = 'clamp_body'
    and approvals_properties is null;

  if missing_approval_count > 0 then
    raise exception 'Clamp materials approvals validation failed.';
  end if;
end $$;

select 'row_count' as check_name, count(*)::integer as rows
from public.clamp_materials;

select 'category_component_counts' as check_name, material_category, component_type, count(*)::integer as rows
from public.clamp_materials
group by material_category, component_type
order by material_category, component_type;

select 'material_codes' as check_name, material_category, component_type, string_agg(material_code, ', ' order by material_code) as material_codes
from public.clamp_materials
group by material_category, component_type
order by material_category, component_type;
