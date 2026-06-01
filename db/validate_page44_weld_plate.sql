-- Validation checks for STAUFF Clamps page 44.

do $$
declare
  row_count integer;
begin
  select count(*)::integer
  into row_count
  from stauff_clamps."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)";

  if row_count <> 200 then
    raise exception 'Page 44 row-count validation failed. Expected 200, got %.', row_count;
  end if;
end $$;

do $$
declare
  duplicate_count integer;
begin
  select count(*)::integer
  into duplicate_count
  from (
    select ordering_code
    from stauff_clamps."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)"
    where ordering_code is not null
    group by ordering_code
    having count(*) > 1
  ) duplicates;

  if duplicate_count <> 0 then
    raise exception 'Page 44 duplicate ordering-code validation failed.';
  end if;
end $$;

do $$
declare
  overview_count integer;
begin
  select count(*)::integer
  into overview_count
  from stauff_clamps."Catalogue Overview"
  where products = 'Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)'
    and (
      (product_type = 'SPAL' and permutations = '100')
      or (product_type = 'SPAS' and permutations = '100')
    );

  if overview_count <> 2 then
    raise exception 'Page 44 Catalogue Overview validation failed. Expected 2 matching rows, got %.', overview_count;
  end if;
end $$;

select 'page44_rows' as check_name, count(*)::integer as rows
from stauff_clamps."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)";

select product_type, count(*)::integer as rows
from stauff_clamps."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)"
group by product_type
order by product_type;

select product_type, permutations
from stauff_clamps."Catalogue Overview"
where products = 'Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)'
order by product_type;
