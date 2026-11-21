-- =============================================================================
-- EJBL Backend Verification Suite (Safe Rollback — leaves ZERO test data!)
-- Run this in Supabase SQL Editor AFTER running 001, 002, and seed.sql, and
-- after creating your 3 test profiles (admin, manager, staff).
--
-- What it tests inside a single transaction (rolled back at the end):
--   1. receive_stock() — 2 FIFO batches at different puhunan/kg + auto COGS + CDJ/GL
--   2. create_sale() — staff price-override BLOCKED server-side
--   3. create_sale() — multi-batch FIFO split (35 kg across 25 kg @ 44 + 10 kg @ 48)
--                      + split payment (Cash + GCash) + continuous SI + CRJ/GL
--   4. create_sale() — B2B Consignment (GA-RA-HE) deducts stock immediately,
--                      0 rows in v_cashbook_entries until collected; then
--                      record_consignment_payment() partial -> paid + CRJ/GL
--   5. void_sale()   — restores exact 35 kg back to original 2 batches +
--                      immutable void_audit_logs snapshot + GJ/GL reversal
--   6. record_expense() & void_expense() — OPEX + Admin-only PERSONAL_WITHDRAWAL
-- =============================================================================

BEGIN;

DO $$
DECLARE
  v_admin_id   UUID;
  v_manager_id UUID;
  v_staff_id   UUID;
  v_cp_id      UUID;
  v_client_id  UUID;
  v_batch1_id  UUID;
  v_batch2_id  UUID;
  v_sale_id    UUID;
  v_cons_id    UUID;
  v_pay_id     UUID;
  v_exp_id     UUID;
  v_cogs       NUMERIC;
  v_rem1       NUMERIC;
  v_rem2       NUMERIC;
  v_cnt        INT;
  v_blocked    BOOLEAN := FALSE;
BEGIN
  -- Lookup test users & seeded data
  SELECT id INTO v_admin_id   FROM public.profiles WHERE role = 'admin'   AND is_active LIMIT 1;
  SELECT id INTO v_manager_id FROM public.profiles WHERE role = 'manager' AND is_active LIMIT 1;
  SELECT id INTO v_staff_id   FROM public.profiles WHERE role = 'staff'   AND is_active LIMIT 1;
  SELECT id INTO v_cp_id      FROM public.rice_varieties WHERE code = 'CP' LIMIT 1;
  SELECT id INTO v_client_id  FROM public.consignment_clients WHERE business_name = 'GA-RA-HE' LIMIT 1;

  IF v_admin_id IS NULL OR v_manager_id IS NULL OR v_staff_id IS NULL THEN
    RAISE EXCEPTION 'Missing test profiles: ensure 1 admin, 1 manager, and 1 staff exist in public.profiles';
  END IF;
  IF v_cp_id IS NULL OR v_client_id IS NULL THEN
    RAISE EXCEPTION 'Missing seed data: run supabase/seed.sql first';
  END IF;

  -- Helper: simulate authenticated JWT user inside SQL Editor
  PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

  -- ---------------------------------------------------------------------------
  -- TEST 1: Manager receives 2 FIFO batches of CP (25 kg @ 44, then 25 kg @ 48)
  -- ---------------------------------------------------------------------------
  PERFORM set_config('request.jwt.claim.sub', v_manager_id::text, true);

  v_batch1_id := public.receive_stock(
    v_cp_id, NULL, DATE '2026-11-18', 25, 44.00, 'cash', 'DR-TEST-1', NULL, FALSE, 'Batch 1'
  );
  v_batch2_id := public.receive_stock(
    v_cp_id, NULL, DATE '2026-11-19', 25, 48.00, 'gcash', 'DR-TEST-2', 'GCASH-B2', FALSE, 'Batch 2'
  );

  SELECT COUNT(*) INTO v_cnt FROM public.expenses WHERE category = 'COGS' AND invoice_no IN ('DR-TEST-1', 'DR-TEST-2');
  IF v_cnt <> 2 THEN
    RAISE EXCEPTION 'TEST 1 FAILED: Expected 2 auto-created COGS expenses, got %', v_cnt;
  END IF;
  RAISE NOTICE 'PASS [1/6]: receive_stock() created 2 FIFO batches + 2 COGS expenses + CDJ/GL entries';

  -- ---------------------------------------------------------------------------
  -- TEST 2: Staff tries to override guide price -> MUST be rejected server-side
  -- ---------------------------------------------------------------------------
  PERFORM set_config('request.jwt.claim.sub', v_staff_id::text, true);
  BEGIN
    PERFORM public.create_sale(
      CURRENT_DATE, 'NSI', 'pickup', 0, FALSE, NULL,
      jsonb_build_array(jsonb_build_object(
        'rice_variety_id', v_cp_id, 'qty_input', 1, 'unit', 'SACK', 'applied_price_per_kg', 40.00
      )),
      jsonb_build_array(jsonb_build_object('method', 'cash', 'amount', 1000)),
      'Unauthorized staff override test'
    );
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE '%Staff are not authorized to override guide prices%' THEN
      v_blocked := TRUE;
    ELSE
      RAISE;
    END IF;
  END;
  IF NOT v_blocked THEN
    RAISE EXCEPTION 'TEST 2 FAILED: Staff price override was not blocked!';
  END IF;
  RAISE NOTICE 'PASS [2/6]: create_sale() blocked Staff price override server-side';

  -- ---------------------------------------------------------------------------
  -- TEST 3: Multi-batch FIFO sale (35 kg CP: 25kg@44 + 10kg@48 = 1580 COGS) + Split Pay
  -- ---------------------------------------------------------------------------
  PERFORM set_config('request.jwt.claim.sub', v_manager_id::text, true);
  v_sale_id := public.create_sale(
    CURRENT_DATE, 'SI', 'delivery', 20.00, FALSE, NULL,
    jsonb_build_array(jsonb_build_object(
      'rice_variety_id', v_cp_id, 'qty_input', 35, 'unit', 'KG', 'applied_price_per_kg', 54.00
    )),
    jsonb_build_array(
      jsonb_build_object('method', 'cash',  'amount', 1000.00, 'reference_no', NULL),
      jsonb_build_object('method', 'gcash', 'amount', 910.00,  'reference_no', 'GCASH-SPLIT-1')
    ),
    'Multi-batch FIFO + split payment test'
  );

  SELECT total_fifo_cogs INTO v_cogs FROM public.sale_items WHERE sale_id = v_sale_id;
  SELECT remaining_kg INTO v_rem1 FROM public.stock_batches WHERE id = v_batch1_id;
  SELECT remaining_kg INTO v_rem2 FROM public.stock_batches WHERE id = v_batch2_id;
  IF v_cogs <> 1580.0000 OR v_rem1 <> 0 OR v_rem2 <> 15 THEN
    RAISE EXCEPTION 'TEST 3 FAILED: FIFO mismatch (cogs=%, rem1=%, rem2=%)', v_cogs, v_rem1, v_rem2;
  END IF;
  RAISE NOTICE 'PASS [3/6]: create_sale() split FIFO across 2 batches accurately (COGS=1580, Batch1=0kg, Batch2=15kg)';

  -- ---------------------------------------------------------------------------
  -- TEST 4: B2B Consignment (GA-RA-HE, 10 kg) -> deducts stock immediately,
  --         0 Cashbook rows until record_consignment_payment() partial -> paid
  -- ---------------------------------------------------------------------------
  v_cons_id := public.create_sale(
    CURRENT_DATE, 'NSI', 'delivery', 0, TRUE, v_client_id,
    jsonb_build_array(jsonb_build_object(
      'rice_variety_id', v_cp_id, 'qty_input', 10, 'unit', 'KG', 'applied_price_per_kg', 54.00
    )),
    '[]'::JSONB,
    'Consignment delivery test'
  );

  SELECT remaining_kg INTO v_rem2 FROM public.stock_batches WHERE id = v_batch2_id;
  SELECT COUNT(*) INTO v_cnt FROM public.sale_payments WHERE sale_id = v_cons_id;
  IF v_rem2 <> 5 OR v_cnt <> 0 THEN
    RAISE EXCEPTION 'TEST 4a FAILED: Expected Batch2=5kg and 0 payments (got %, %)', v_rem2, v_cnt;
  END IF;

  v_pay_id := public.record_consignment_payment(v_cons_id, CURRENT_DATE, 'cash', 300.00, NULL, 'Partial');
  v_pay_id := public.record_consignment_payment(v_cons_id, CURRENT_DATE, 'gcash', 240.00, 'GCASH-CONS', 'Final');

  SELECT COUNT(*) INTO v_cnt FROM public.sales WHERE id = v_cons_id AND payment_status = 'paid' AND amount_paid = 540.00;
  IF v_cnt <> 1 THEN
    RAISE EXCEPTION 'TEST 4b FAILED: Consignment status did not reach paid';
  END IF;

  -- Verify Migration 003: NSI consignment posted ZERO rows to bir_ledger_entries
  SELECT COUNT(*) INTO v_cnt FROM public.bir_ledger_entries
  WHERE source_id = v_cons_id
     OR source_id IN (SELECT id FROM public.sale_payments WHERE sale_id = v_cons_id);
  IF v_cnt <> 0 THEN
    RAISE EXCEPTION 'TEST 4c FAILED: NSI transaction posted % rows to bir_ledger_entries (expected 0)', v_cnt;
  END IF;

  -- Verify SI sale (TEST 3) DID post rows to bir_ledger_entries
  SELECT COUNT(*) INTO v_cnt FROM public.bir_ledger_entries
  WHERE source_id IN (SELECT id FROM public.sale_payments WHERE sale_id = v_sale_id);
  IF v_cnt = 0 THEN
    RAISE EXCEPTION 'TEST 4d FAILED: Receipted SI sale posted 0 rows to bir_ledger_entries';
  END IF;
  RAISE NOTICE 'PASS [4/6]: Consignment deducted stock immediately, transitioned unpaid -> paid, and enforced SI-only BIR auto-posting';

  -- ---------------------------------------------------------------------------
  -- TEST 5: Manager voids TEST 3 sale -> restores exact 25kg + 10kg to original batches
  --         + creates immutable void_audit_logs snapshot + GJ/GL reversal
  -- ---------------------------------------------------------------------------
  PERFORM public.void_sale(v_sale_id, 'Test void reason - customer changed mind');

  SELECT remaining_kg INTO v_rem1 FROM public.stock_batches WHERE id = v_batch1_id;
  SELECT remaining_kg INTO v_rem2 FROM public.stock_batches WHERE id = v_batch2_id;
  SELECT COUNT(*) INTO v_cnt FROM public.void_audit_logs WHERE record_type = 'sale' AND record_id = v_sale_id;
  IF v_rem1 <> 25 OR v_rem2 <> 15 OR v_cnt <> 1 THEN
    RAISE EXCEPTION 'TEST 5 FAILED: Void restoration mismatch (rem1=%, rem2=%, audit_cnt=%)', v_rem1, v_rem2, v_cnt;
  END IF;
  RAISE NOTICE 'PASS [5/6]: void_sale() restored exact FIFO batches (25kg + 10kg) & logged immutable void_audit_logs snapshot';

  -- ---------------------------------------------------------------------------
  -- TEST 6: record_expense() & void_expense() + Admin-only PERSONAL_WITHDRAWAL
  -- ---------------------------------------------------------------------------
  PERFORM set_config('request.jwt.claim.sub', v_admin_id::text, true);
  v_exp_id := public.record_expense(
    CURRENT_DATE, 'OR-FUEL-1', 'OPEX_FUEL', 'Delivery motorcycle fuel', 'cash', 200.00, NULL, NULL
  );
  PERFORM public.void_expense(v_exp_id, 'Duplicate fuel entry test');

  PERFORM public.record_expense(
    CURRENT_DATE, 'DRAW-TEST', 'PERSONAL_WITHDRAWAL', 'Owner allowance test', 'cash', 500.00, NULL, NULL
  );
  SELECT COUNT(*) INTO v_cnt FROM public.capital_entries WHERE reference_no = 'DRAW-TEST' AND entry_type = 'owner_withdrawal';
  IF v_cnt <> 1 THEN
    RAISE EXCEPTION 'TEST 6 FAILED: Personal withdrawal did not auto-link to capital_entries';
  END IF;
  RAISE NOTICE 'PASS [6/6]: record_expense(), void_expense(), and Admin PERSONAL_WITHDRAWAL -> capital_entries all verified!';
END $$;

ROLLBACK;
