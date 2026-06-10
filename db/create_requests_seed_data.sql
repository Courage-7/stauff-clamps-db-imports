-- Rebuild the customer requests table and seed revised STAUFF request examples.
-- This script is intentionally destructive for public."Requests" and public.emails.

begin;

drop table if exists public."Requests";
drop table if exists public.emails;

create table public."Requests" (
  id bigserial primary key,
  sender text not null,
  company_name text not null,
  recipient text not null,
  subject text not null,
  request_details text not null,
  status text not null default 'pending',
  received_at timestamptz,
  created_at timestamptz not null default now(),
  constraint requests_status_check
    check (status in ('pending', 'unresolved', 'resolved'))
);

comment on table public."Requests"
  is 'Customer support and product recommendation requests for STAUFF catalogue items.';

comment on column public."Requests".request_details
  is 'Full customer inquiry text, including application context, known requirements, and requested recommendation.';

insert into public."Requests" (
  sender,
  company_name,
  recipient,
  subject,
  request_details,
  status,
  received_at
) values
  (
    'Luis Berghoff',
    'XYZ',
    'STAUFF Support Team',
    'Inquiry Regarding Plates for Heavy Series Double Clamp',
    'I need a weld plate for a Heavy Series double clamp installation. The clamp will mount two hydraulic tubes side by side. Current known requirement is Heavy Series Double Clamp with M10 mounting thread. Please advise the suitable plate and part number.',
    'unresolved',
    '2026-06-10 08:15:00+00'::timestamptz
  ),
  (
    'James Neski',
    '4th-IR',
    'STAUFF Support Team',
    'Inquiry Regarding Stacking Bolt for Heavy Series Clamp Installation',
    'A Heavy Series clamp installation is being configured for DIN Group 1 with a Safety Locking Plate (SIP). The requested thread is 3/8-16 UNC, with carbon steel and zinc/nickel finish preferred. Please recommend the correct stacking bolt and any additional mounting parts required.',
    'unresolved',
    '2026-06-10 08:42:00+00'::timestamptz
  ),
  (
    'Priya Nair',
    'Coastal Hydraulics Ltd',
    'STAUFF Support Team',
    'DPAS Cover Plate Recommendation for Salt-Spray Pump Skid',
    'For a coastal hydraulic power unit, the assembly uses Heavy Series double clamps, STAUFF group 3S / DIN group 1. Salt-spray exposure makes stainless V4A preferable. Can you confirm whether DPAS-3S-W5 is the correct double-clamp cover plate and advise availability for 48 pieces?',
    'pending',
    '2026-06-09 14:20:00+00'::timestamptz
  ),
  (
    'Henrik Madsen',
    'NordRail Maintenance',
    'STAUFF Support Team',
    'Clamp Body Material Review for Rail Tunnel Installation',
    'A rail tunnel retrofit needs clamp body material guidance. The operating range is roughly -25 C to +80 C, with occasional mineral oil exposure and a preference for improved fire behavior. Please compare PA-V0-BK, PP-DA, and PA-GF30-USR and advise which material is most suitable.',
    'pending',
    '2026-06-09 16:05:00+00'::timestamptz
  ),
  (
    'Amara Okonkwo',
    'Delta Marine Services',
    'STAUFF Support Team',
    'DIN 463 Safety Washer for Heavy Series Clamp Assembly',
    'Our maintenance crew is replacing locking hardware on a marine hydraulic manifold. The assembly uses AS hexagon head bolts with Heavy Series groups 3S to 5S. They requested a two-tab DIN 463 safety washer in V2A stainless and suggested SI-10.5-DIN463-W4. Please confirm the correct stainless option.',
    'pending',
    '2026-06-08 10:35:00+00'::timestamptz
  ),
  (
    'Tom Wallace',
    'TerraDrill Equipment',
    'STAUFF Support Team',
    'Urgent UNC Socket Cap Screw Replacement',
    'One drill rig is down after several socket cap screws were damaged during service. The clamp hardware appears to be Heavy Series group 3S with UNC thread, size 3/8-16UNCx1. Zinc/nickel-plated carbon steel is preferred if available. Is IS-3/8-16UNCx1-W3 the right replacement?',
    'pending',
    '2026-06-08 12:50:00+00'::timestamptz
  ),
  (
    'Mei Chen',
    'BrightForm Manufacturing',
    'STAUFF Support Team',
    'Elongated Weld Plate Drawing and Quote Request',
    'Please confirm SPAL-DUEB-3S-M-W3 for a welded bracket standardization project using Heavy Series single clamps, STAUFF group 3S, DIN group 1, M10 thread, and zinc/nickel-plated carbon steel. Dimensional drawing confirmation and pricing for 120 pieces are also needed.',
    'pending',
    '2026-06-07 09:10:00+00'::timestamptz
  ),
  (
    'Rafael Ortega',
    'Andes Mining Supply',
    'STAUFF Support Team',
    'Hardware Stack for Heavy Series Clamp Group 6S',
    'A mining conveyor hydraulic line needs a complete Heavy Series group 6S hardware stack. The team wants a cover plate, safety locking plate, and stacking bolt in zinc/nickel finish, but the thread and exact product codes are not yet confirmed. Please recommend the matching parts.',
    'pending',
    '2026-06-07 15:30:00+00'::timestamptz
  ),
  (
    'Emily Foster',
    'GreenLine OEM',
    'STAUFF Support Team',
    'Aluminium Cover Plate Availability for Lightweight Assembly',
    'Our design team is trying to reduce weight on a compact hydraulic assembly. They saw aluminium EN AW-6060 listed as W85 for DPAL cover plates and assumed it could be ordered for group 7S as DPAL-7S-W85. Please confirm whether that material and size combination is valid, or suggest the closest alternative.',
    'pending',
    '2026-06-06 11:25:00+00'::timestamptz
  ),
  (
    'Jonas Weber',
    'Helios Packaging Systems',
    'STAUFF Support Team',
    'Stainless Hexagon Head Bolt for Washdown Area',
    'For a food packaging washdown zone, AS hexagon head bolts are needed for Heavy Series group 3S. The design calls for M10x45, and purchasing asked whether AS-M10x45-W2 would be acceptable because it is already used on other clamp hardware. Please confirm the correct corrosion-resistant material code for this bolt.',
    'pending',
    '2026-06-06 13:45:00+00'::timestamptz
  ),
  (
    'Noura Haddad',
    'Gulf PetroChem Services',
    'STAUFF Support Team',
    'Clamp Insert Material Selection for Chemical Exposure',
    'The application involves clamp inserts for lines exposed to seawater, mineral oils, and occasional alcohol-based cleaning. Temperature range is about -40 C to +110 C. Please compare EPDM and SA inserts and advise which material is more suitable before the clamp specification is finalized.',
    'pending',
    '2026-06-05 10:05:00+00'::timestamptz
  ),
  (
    'Victor Stein',
    'Apex Hydraulic Retrofits',
    'STAUFF Support Team',
    'SIP and AF Hardware for Stacked Heavy Series Clamp',
    'An existing Heavy Series group 3S clamp location is being converted to a stacked assembly. The base thread is M10 and the preferred finish is zinc/nickel-plated carbon steel. Please confirm the matching SIP safety locking plate and AF stacking bolt part numbers, including whether AF-3S-M-W3 is appropriate.',
    'pending',
    '2026-06-05 16:40:00+00'::timestamptz
  );

commit;
