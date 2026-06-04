-- Step 1: split combined STAUFF product tables into product-specific tables.
-- Scope: create and populate child tables only.
-- No validation, duplicate checks, all-null column cleanup, or parent table drops.

begin;

drop table if exists public."Weld Plate for Single Clamps (SPAL)";
drop table if exists public."Weld Plate for Double Clamps (SPAS)";
drop table if exists public."Elongated Weld Plate for Single Clamps (SPAL-DUEB)";
drop table if exists public."Elongated Weld Plate for Double Clamps (SPAS-DUEB)";
drop table if exists public."Cover Plate for Single Clamps (DPAL)";
drop table if exists public."Cover Plate for Double Clamps (DPAS)";
drop table if exists public."Hexagon Head Bolt (AS)";
drop table if exists public."Socket Cap Screw (IS)";
drop table if exists public."Safety Washer DIN 93 (SI)";
drop table if exists public."Safety Washer DIN 463 (SI)";
drop table if exists public."Safety Locking Plate (SIP)";
drop table if exists public."Stacking Bolt (AF)";

create table public."Weld Plate for Single Clamps (SPAL)" as
select *
from public."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)"
where product_type = 'SPAL';

create table public."Weld Plate for Double Clamps (SPAS)" as
select *
from public."Weld Plate for Single Clamps (SPAL) and Double Clamps (SPAS)"
where product_type = 'SPAS';

create table public."Elongated Weld Plate for Single Clamps (SPAL-DUEB)" as
select *
from public."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
where product_type = 'SPAL-DUEB';

create table public."Elongated Weld Plate for Double Clamps (SPAS-DUEB)" as
select *
from public."Elongated Weld Plates (SPAL-DUEB, SPAS-DUEB)"
where product_type = 'SPAS-DUEB';

create table public."Cover Plate for Single Clamps (DPAL)" as
select *
from public."Cover Plates (DPAL, DPAS)"
where product_type = 'DPAL';

create table public."Cover Plate for Double Clamps (DPAS)" as
select *
from public."Cover Plates (DPAL, DPAS)"
where product_type = 'DPAS';

create table public."Hexagon Head Bolt (AS)" as
select *
from public."Bolts and Screws (AS, IS)"
where product_type = 'AS';

create table public."Socket Cap Screw (IS)" as
select *
from public."Bolts and Screws (AS, IS)"
where product_type = 'IS';

create table public."Safety Washer DIN 93 (SI)" as
select *
from public."Safety Washers (SI DIN 93, SI DIN 463)"
where product_type = 'SI (DIN93)';

create table public."Safety Washer DIN 463 (SI)" as
select *
from public."Safety Washers (SI DIN 93, SI DIN 463)"
where product_type = 'SI (DIN463)';

create table public."Safety Locking Plate (SIP)" as
select *
from public."Safety Locking Plate & Stacking Bolt (SIP, AF)"
where product_type = 'SIP';

create table public."Stacking Bolt (AF)" as
select *
from public."Safety Locking Plate & Stacking Bolt (SIP, AF)"
where product_type = 'AF';

commit;
