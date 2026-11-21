-- =============================================================================
-- EJBL Bigasan — Reference Seed Data (Extracted directly from EJBL_BIGASAN.xlsx)
-- Status: Proposed seed script (verify current selling prices with owner before prod)
-- =============================================================================

INSERT INTO public.rice_varieties
  (code, name, sack_weight_kg, wholesale_sack_price, retail_sack_price, wholesale_kg_price, retail_kg_price, display_kg_price, ordering_point_kg)
VALUES
  ('CJ',  'COCO JAPONICA',          25.000, 1370.00, 1425.00, 54.80, 57.00, NULL,  50.000),
  ('CP',  'COCO PANDAN',            25.000, 1300.00, 1350.00, 52.00, 54.00, 55.00, 50.000),
  ('PH',  'PRINCESS HASMIN BLUE',   25.000, 1270.00, 1350.00, 50.80, 54.00, 54.00, 50.000),
  ('JR',  'JASMINE RED RC160',      25.000, 1200.00, 1250.00, 48.00, 50.00, 51.00, 50.000),
  ('GS',  'GOLDEN STAR',            25.000, 1100.00, 1150.00, 44.00, 46.00, 47.00, 50.000),
  ('HB',  'HB',                     25.000, 1250.00, 1250.00, 50.00, 50.00, 50.00, 50.000),
  ('SH',  'SWEET HASMINE',          25.000, 1250.00, 1250.00, 50.00, 50.00, 50.00, 50.000),
  ('RS',  'ROYAL SHEEP',            25.000, 1250.00, 1250.00, 50.00, 50.00, 50.00, 50.000),
  ('S',   'SAPPORO',                25.000, 1350.00, 1350.00, 54.00, 54.00, NULL,  50.000),
  ('JD',  'BATAAN JASMIN DINORADO', 25.000, 1300.00, 1350.00, 52.00, 54.00, 54.00, 50.000),
  ('MC',  'MAGIC CASTLE',           25.000, 1250.00, 1250.00, 50.00, 50.00, 50.00, 50.000),
  ('DR',  'DOGRICE',                25.000,  970.00,  970.00, 38.80, 38.80, NULL,  50.000),
  ('MD',  'MINDORO DENURADO',       25.000, 1300.00, 1330.00, 52.00, 53.20, NULL,  50.000),
  ('AM',  'AROMA MASTER CHEF',      25.000, 1250.00, 1325.00, 50.00, 53.00, 53.00, 50.000),
  ('MB',  'MLR BLUE',               25.000,  950.00,  950.00, 38.00, 38.00, 38.00, 50.000),
  ('MCL', 'MCL DENORADO',           25.000, 1400.00, 1450.00, 56.00, 58.00, 58.00, 50.000),
  ('SCB', 'SWEET COCO BLUE',        25.000, 1150.00, 1150.00, 46.00, 46.00, 46.00, 50.000),
  ('SJR', 'SUPER JASMINE RED',      25.000, 1230.00, 1250.00, 49.20, 50.00, 50.00, 50.000),
  ('O',   'OKOME',                  25.000, 1280.00, 1325.00, 51.20, 53.00, 53.00, 50.000),
  ('BP',  'BUCO PANDAN',            25.000, 1170.00, 1190.00, 46.80, 47.60, NULL,  50.000),
  ('SA',  'SUPER ALSA MASTER CHEF', 25.000, 1250.00, 1270.00, 50.00, 50.80, NULL,  50.000),
  ('PT',  'PLANTERS THAI',          25.000, 1250.00, 1270.00, 50.00, 50.80, NULL,  50.000),
  ('MO',  'MLR ORANGE',             25.000,  950.00,  950.00, 38.00, 38.00, NULL,  50.000)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.consignment_clients (business_name, payment_schedule, notes)
VALUES
  ('GA-RA-HE', 'Every Sunday', 'Seeded from EJBL_BIGASAN.xlsx SALES sheet'),
  ('CARIBBEAN GRILL', 'Every Sunday', 'Seeded from EJBL_BIGASAN.xlsx SALES sheet')
ON CONFLICT (business_name) DO NOTHING;
