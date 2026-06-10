-- STAUFF clamp materials workbook import schema.

create table if not exists public.clamp_materials (
  id bigserial primary key,
  material_category text not null,
  material_scope text not null check (material_scope in ('standard', 'special')),
  component_type text not null check (component_type in ('clamp_body', 'clamp_insert')),
  material_code text not null,
  basic_material text,
  standard_colour text,
  tensile_e_module text,
  notch_impact_strength text,
  low_temperature_notch_impact_strength text,
  tensile_strength_at_yield text,
  ball_indentation_hardness text,
  shore_hardness text,
  temperature_resistance_min_max text,
  weak_acids text,
  solvents text,
  benzine text,
  mineral_oils text,
  other_oils text,
  alcohols text,
  seawater text,
  approvals_properties text,
  imported_at timestamptz not null default now(),
  unique (material_category, component_type, material_code)
);

create index if not exists clamp_materials_material_code_idx
  on public.clamp_materials (material_code);

create index if not exists clamp_materials_category_component_idx
  on public.clamp_materials (material_category, component_type);

create index if not exists clamp_materials_basic_material_idx
  on public.clamp_materials (basic_material);

comment on table public.clamp_materials is 'STAUFF clamp body and insert material properties from workbook sheets 178-181.';
comment on column public.clamp_materials.material_category is 'Workbook category title, for example Standard Clamp Body Materials.';
comment on column public.clamp_materials.material_scope is 'Material group: standard or special.';
comment on column public.clamp_materials.component_type is 'Component group: clamp_body or clamp_insert.';
