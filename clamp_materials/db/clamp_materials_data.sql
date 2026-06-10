-- Generated clamp materials data import.

begin;

truncate table public.clamp_materials restart identity;

insert into public.clamp_materials (
  material_category,
  material_scope,
  component_type,
  material_code,
  basic_material,
  standard_colour,
  tensile_e_module,
  notch_impact_strength,
  low_temperature_notch_impact_strength,
  tensile_strength_at_yield,
  ball_indentation_hardness,
  shore_hardness,
  temperature_resistance_min_max,
  weak_acids,
  solvents,
  benzine,
  mineral_oils,
  other_oils,
  alcohols,
  seawater,
  approvals_properties
) values
  ('Standard Clamp Body Materials', 'standard', 'clamp_body', 'PP', 'Copolymeric Polypropylene', 'Green', '1073 N/mm² (ISO 527)', '8 kJ/m² at +23°C / +73.4°F (Charpy/ISO 179/1eU)', '3 kJ/m² at -20°C / -4°F (Charpy/ISO 179/1eU)', '26 MPa (ISO 527-2)', '45.4 MPa (ISO 2039-1)', NULL, '-30°C ... +90°C / -22°F ... +194°F', 'conditionally consistent', 'conditionally consistent', 'conditionally consistent', 'conditionally consistent', 'consistent', 'consistent', 'consistent', NULL),
  ('Standard Clamp Body Materials', 'standard', 'clamp_body', 'PA', 'Polyamide', 'Black', '>1400 N/mm² (ISO 527)', '>15 kJ/m² at +23°C / +73.4°F (Charpy/ISO 179/1eU)', '>3 kJ/m² at -30°C / -22°F (Charpy/ISO 179/1eU)', '>55 MPa (ISO 527)', '>65 MPa (ISO 2039-1)', NULL, '-40°C ... +120°C / -40°F ... +248°F (Brief exposure up to +140°C / +284°F)', 'conditionally consistent', 'conditionally consistent', 'consistent', 'consistent', 'consistent', 'consistent', 'consistent', NULL),
  ('Standard Clamp Body Materials', 'standard', 'clamp_body', 'AL', 'Aluminium AlSi12', 'Natural', '>65000 N/mm²', NULL, NULL, '>240 MPa (ISO EN 10002)', '>70 HBS', NULL, 'up to +300°C / up to +572°F', 'conditionally consistent', 'conditionally consistent', 'consistent', 'consistent', 'consistent', 'consistent', 'consistent', NULL),
  ('Standard Clamp Body Materials', 'standard', 'clamp_body', 'SA', 'Thermoplastic Elastomer', 'Black', '113 N/mm² at +23°C / +73.4°F (ASTM D412)', NULL, NULL, '15.9 MPa (ASTM D412)', NULL, '87 A (ISO 868). Alternative hardnesses available upon request.', '-40°C ... +125°C / -40°F ... +257°F', 'consistent', 'conditionally consistent', 'conditionally consistent', 'conditionally consistent', 'consistent', 'consistent', 'consistent', NULL),
  ('Standard Clamp Insert Materials', 'standard', 'clamp_insert', 'SA', 'Thermoplastic Elastomer', 'Black', '16 N/mm² at +23°C / +73.4°F (ASTM D412)', NULL, NULL, '8.3 MPa (ASTM D412)', NULL, '73 A (ISO 868). Alternative hardnesses available upon request.', '-40°C ... +125°C / -40°F ... +257°F', 'consistent', 'conditionally consistent', 'conditionally consistent', 'conditionally consistent', 'consistent', 'consistent', 'consistent', NULL),
  ('Standard Clamp Insert Materials', 'standard', 'clamp_insert', 'EPDM', 'Ethylene Propylene Diene Monomer', 'Black', NULL, NULL, NULL, '9.0 MPa (DIN 53504)', NULL, '70 A (DIN 53505). Alternative hardnesses available upon request.', '-50°C ... +120°C / -58°F ... +248°F', 'consistent', 'consistent', 'conditionally consistent', 'conditionally consistent', 'conditionally consistent', 'consistent', 'consistent', NULL),
  ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'special', 'clamp_body', 'PA-V0-BK', 'Polyamide', 'Black (PA-V0-BK)', '1500 MPa (ISO 527-2)', '35 kJ/m² at +23°C / +73.4°F (Charpy/ISO179/1eU)', NULL, '45 MPa (ISO 527-2)', '100 N/mm² (ISO 2039-1)', NULL, '-30°C ... +120°C / -22°F ... +248°F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Tested and approved acc. to UL94¹
(material thickness: 3 mm)
§ Classification: V-0 (Vertical Burning Test)

Tested and approved acc. to EN 45545-2
(material thickness: 3.5 mm)
§ Requirements set R22 / R23 / R24 / R26
§ Hazard level HL1 - HL3

Tested and approved acc. to DIN 5510, Part 2
(material thickness: 3 mm)
§ Combustibility classification: S4
§ Smoke development classification: SR2
§ Dripping classification: ST2

Tested and approved acc. to NF F 16-101
(material thickness: 3 mm)
§ Classification: I3 / F2

Low Smoke Zero Halogen (LSZH)'),
  ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'special', 'clamp_body', 'PP-DA', 'Polypropylene', 'White', '1614 N/mm² (ISO 527) at +23°C / +73.4°F: 50 mm/min', '13 kJ/m² at +23°C / +73.4°F (IZOD/ISO179/1eA)', '1.5 kJ/m² at -25°C / -13°F (IZOD/ISO179/1eA)', '12.4 MPa (ISO 527) at +23°C / +73.4°F: 50 mm/min', NULL, NULL, '-25°C ... +90°C / -13°F ... +194°F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Tested and approved acc. to UL94¹
(material thickness: 3 mm)
§ Classification: V-0 (Vertical Burning Test)

Tested and approved acc. to Def Stan 07-247
§ Assessment: category B

Approved by the UK Ministry of Defence (MoD)

Low Smoke Zero Halogen (LSZH)'),
  ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'special', 'clamp_body', 'PA-GF30-USR', 'Polyamide', 'Black', '8274 MPa (ASTM D638)', '15 kJ/m² (ASTM D256)', NULL, '131 MPa (ASTM D638)', NULL, NULL, '-30°C ... +120°C / -22°F ... +248°F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Tested and approved acc. to ASTM D638
(material thickness: 1.5 mm)
§ Classification: V-0 (Vertical Burning Test)

Tested and approved acc. to NFPA 130
(material thickness: 3 mm)
§ no burning dripping

Halogen Free Flame Retardant (HFFR)'),
  ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'special', 'clamp_body', 'PP6853', 'Polypropylene', 'White', '1264 MPa (ICE 60811-1-1)', '17 kJ/m² at +23°C / +73.4°F (IZOD/ISO179/1eA)', NULL, '25 MPa (ICE 60811-1-1)', NULL, NULL, '-25°C ... +90°C / -13°F ... +194°F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Tested and approved acc. to EN 45545-2
(material thickness: 3 mm)
§ Requirements set R22 / R23 / R24 / R26
§ Hazard level HL1 - HL3

Tested and approved acc. to BS 6853
§ Assessment: category 1a

Compliant to the requirements of London Underground / Metronet
(standard 2-01001-002: Fire Safety Performance of Materials)

Tested and approved acc. to DIN 5510, Part 2
(material thickness: 25 mm)
§ Combustibility classification: S4
§ Smoke development classification: SR2
§ Dripping classification: ST2

Tested and approved acc. to Def Stan 07-247
§ Assessment: category B

Compliant to the requirements of JRMA
§ Classification: extremely incombustible

Low Smoke Zero Halogen (LSZH)'),
  ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'special', 'clamp_body', 'PP-V0', 'Polypropylene', 'Black', NULL, '5 kJ/m² at +23°C / +73.4°F (ISO180/A)', NULL, '24 MPa (ISO 527)', NULL, NULL, '-25°C ... +90°C / -13°F ... +194°F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Tested and approved acc. to UL94¹
(material thickness: 3 mm)
§ Classification: V-0 (Vertical Burning Test)'),
  ('Special Clamp Body Materials (Selection) - Preventive Fire Protection', 'special', 'clamp_body', 'SA-V0', 'Thermoplastic Elastomer', 'Natural', '113 N/mm² at +23°C / +73.4°F (ASTM D412)', NULL, NULL, '15.9 MPa (ASTM D412)', NULL, '86 A (ISO 868)', '-55°C ... +90°C / -67°F ... +194°F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Tested and approved acc. to UL94¹
(material thickness: 3 mm)
§ Classification: V-0 (Vertical Burning Test)');

commit;
