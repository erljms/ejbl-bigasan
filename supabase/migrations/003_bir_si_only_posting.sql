-- =============================================================================
-- Migration 003: Restrict Automated BIR Sales Posting to Receipted (SI) Only
-- Rule:
--   - SI (Sales Invoice / with receipt): auto-posts to bir_ledger_entries
--     (CRJ/GL on payment collection, GJ/GL on consignment AR, GJ/GL on void).
--   - NSI (No Sales Invoice): still deducts FIFO Inventory and populates
--     Business Records (v_cashbook_entries), but does NOT auto-post to
--     bir_ledger_entries. NSI totals remain tracked in Business Records so the
--     Owner/Bookkeeper can review or post a consolidated summary entry if needed.
-- =============================================================================

-- 1. Update create_sale() -> auto-post BIR entries ONLY when p_invoice_type = 'SI'
CREATE OR REPLACE FUNCTION public.create_sale(
  p_sale_date DATE,
  p_invoice_type public.invoice_type,
  p_fulfillment_type public.fulfillment_type,
  p_delivery_fee NUMERIC,
  p_is_consignment BOOLEAN,
  p_consignment_client_id UUID,
  p_items JSONB,
  p_payments JSONB DEFAULT '[]'::JSONB,
  p_notes TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role public.user_role := public.current_user_role();
  v_uid UUID := auth.uid();
  v_invoice_no TEXT;
  v_sale_id UUID;
  v_item JSONB;
  v_pay JSONB;
  v_variety RECORD;
  v_qty_kg NUMERIC(10,3);
  v_guide_price NUMERIC(12,4);
  v_applied_price NUMERIC(12,4);
  v_overridden BOOLEAN;
  v_line_total NUMERIC(12,2);
  v_rice_subtotal NUMERIC(12,2) := 0;
  v_sale_item_id UUID;
  v_needed_kg NUMERIC(10,3);
  v_take_kg NUMERIC(10,3);
  v_batch RECORD;
  v_item_cogs NUMERIC(12,4);
  v_total_paid NUMERIC(12,2) := 0;
  v_total_amount NUMERIC(12,2);
  v_pay_status public.payment_status;
  v_payment_id UUID;
BEGIN
  IF v_role NOT IN ('staff', 'manager', 'admin') THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  IF jsonb_array_length(p_items) = 0 THEN
    RAISE EXCEPTION 'Sale must include at least one item';
  END IF;

  -- Continuous SI from 1; auto-generated NSI
  IF p_invoice_type = 'SI' THEN
    v_invoice_no := nextval('public.si_invoice_seq')::TEXT;
  ELSE
    v_invoice_no := 'NSI-' || LPAD(nextval('public.nsi_invoice_seq')::TEXT, 3, '0');
  END IF;

  INSERT INTO public.sales (
    sale_date, invoice_type, invoice_no, fulfillment_type, delivery_fee,
    rice_subtotal, is_consignment, consignment_client_id,
    payment_status, amount_paid, notes, created_by
  ) VALUES (
    p_sale_date, p_invoice_type, v_invoice_no, p_fulfillment_type, COALESCE(p_delivery_fee, 0),
    0, p_is_consignment, p_consignment_client_id,
    'unpaid', 0, p_notes, v_uid
  ) RETURNING id INTO v_sale_id;

  -- Process each line item + atomic FIFO batch deduction
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    SELECT * INTO v_variety FROM public.rice_varieties
    WHERE id = (v_item->>'rice_variety_id')::UUID AND is_active = TRUE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Rice variety not found or inactive';
    END IF;

    IF (v_item->>'unit') = 'SACK' THEN
      v_qty_kg := (v_item->>'qty_input')::NUMERIC * v_variety.sack_weight_kg;
      IF (v_item->>'qty_input')::NUMERIC >= 3 OR p_fulfillment_type = 'pickup' THEN
        v_guide_price := ROUND(v_variety.wholesale_sack_price / v_variety.sack_weight_kg, 4);
      ELSE
        v_guide_price := ROUND(v_variety.retail_sack_price / v_variety.sack_weight_kg, 4);
      END IF;
    ELSE
      v_qty_kg := (v_item->>'qty_input')::NUMERIC;
      v_guide_price := v_variety.retail_kg_price;
    END IF;

    v_applied_price := COALESCE((v_item->>'applied_price_per_kg')::NUMERIC, v_guide_price);
    v_overridden := (ABS(v_applied_price - v_guide_price) > 0.009);

    IF v_overridden AND v_role = 'staff' THEN
      RAISE EXCEPTION 'Staff are not authorized to override guide prices';
    END IF;

    v_line_total := ROUND(v_qty_kg * v_applied_price, 2);
    v_rice_subtotal := v_rice_subtotal + v_line_total;

    INSERT INTO public.sale_items (
      sale_id, rice_variety_id, qty_input, unit, qty_kg,
      guide_price_per_kg, applied_price_per_kg, price_overridden, line_total
    ) VALUES (
      v_sale_id, v_variety.id, (v_item->>'qty_input')::NUMERIC, (v_item->>'unit')::public.sale_unit,
      v_qty_kg, v_guide_price, v_applied_price, v_overridden, v_line_total
    ) RETURNING id INTO v_sale_item_id;

    v_needed_kg := v_qty_kg;
    v_item_cogs := 0;

    FOR v_batch IN
      SELECT id, remaining_kg, unit_cost_per_kg
      FROM public.stock_batches
      WHERE rice_variety_id = v_variety.id AND remaining_kg > 0
      ORDER BY received_date ASC, created_at ASC
      FOR UPDATE
    LOOP
      EXIT WHEN v_needed_kg <= 0;
      v_take_kg := LEAST(v_needed_kg, v_batch.remaining_kg);

      UPDATE public.stock_batches
      SET remaining_kg = remaining_kg - v_take_kg
      WHERE id = v_batch.id;

      INSERT INTO public.sale_fifo_allocations (sale_item_id, stock_batch_id, deducted_kg, unit_cost_per_kg)
      VALUES (v_sale_item_id, v_batch.id, v_take_kg, v_batch.unit_cost_per_kg);

      v_item_cogs := v_item_cogs + ROUND(v_take_kg * v_batch.unit_cost_per_kg, 4);
      v_needed_kg := v_needed_kg - v_take_kg;
    END LOOP;

    IF v_needed_kg > 0 THEN
      RAISE EXCEPTION 'Insufficient FIFO stock for rice code % (short by % kg)', v_variety.code, v_needed_kg;
    END IF;

    UPDATE public.sale_items SET total_fifo_cogs = v_item_cogs WHERE id = v_sale_item_id;
  END LOOP;

  v_total_amount := v_rice_subtotal + COALESCE(p_delivery_fee, 0);

  -- Record payments (Cashbook auto-updates for BOTH SI and NSI)
  FOR v_pay IN SELECT * FROM jsonb_array_elements(COALESCE(p_payments, '[]'::JSONB))
  LOOP
    INSERT INTO public.sale_payments (
      sale_id, payment_date, method, amount, reference_no, recorded_by
    ) VALUES (
      v_sale_id, p_sale_date, (v_pay->>'method')::public.payment_method,
      (v_pay->>'amount')::NUMERIC, v_pay->>'reference_no', v_uid
    ) RETURNING id INTO v_payment_id;

    v_total_paid := v_total_paid + (v_pay->>'amount')::NUMERIC;

    -- Auto-post to BIR Cash Receipts Journal & General Ledger ONLY for SI (receipted) sales
    IF p_invoice_type = 'SI' THEN
      INSERT INTO public.bir_ledger_entries
        (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
      VALUES
        ('CRJ', p_sale_date, v_invoice_no, 'Sale Payment (' || (v_pay->>'method') || ')', CASE WHEN (v_pay->>'method') = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, (v_pay->>'amount')::NUMERIC, 0, 'payment', v_payment_id, v_uid),
        ('CRJ', p_sale_date, v_invoice_no, 'Sale Revenue / Collection', CASE WHEN p_is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Sales Revenue' END, 0, (v_pay->>'amount')::NUMERIC, 'payment', v_payment_id, v_uid),
        ('GL',  p_sale_date, v_invoice_no, 'Sale Payment (' || (v_pay->>'method') || ')', CASE WHEN (v_pay->>'method') = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, (v_pay->>'amount')::NUMERIC, 0, 'payment', v_payment_id, v_uid),
        ('GL',  p_sale_date, v_invoice_no, 'Sale Revenue / Collection', CASE WHEN p_is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Sales Revenue' END, 0, (v_pay->>'amount')::NUMERIC, 'payment', v_payment_id, v_uid);
    END IF;
  END LOOP;

  IF NOT p_is_consignment AND v_total_paid < v_total_amount THEN
    RAISE EXCEPTION 'Non-consignment sales must be fully paid (due: %, paid: %)', v_total_amount, v_total_paid;
  END IF;

  IF v_total_paid >= v_total_amount THEN
    v_pay_status := 'paid';
  ELSIF v_total_paid > 0 THEN
    v_pay_status := 'partial';
  ELSE
    v_pay_status := 'unpaid';
  END IF;

  UPDATE public.sales
  SET rice_subtotal = v_rice_subtotal,
      amount_paid = v_total_paid,
      payment_status = v_pay_status
  WHERE id = v_sale_id;

  -- For receipted (SI) consignment deliveries, post Accounts Receivable to GJ & GL
  IF p_is_consignment AND p_invoice_type = 'SI' THEN
    INSERT INTO public.bir_ledger_entries
      (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
    VALUES
      ('GJ', p_sale_date, v_invoice_no, 'B2B Consignment Delivery', 'Accounts Receivable - Consignment', v_total_amount, 0, 'sale', v_sale_id, v_uid),
      ('GJ', p_sale_date, v_invoice_no, 'B2B Consignment Delivery', 'Sales Revenue', 0, v_total_amount, 'sale', v_sale_id, v_uid),
      ('GL', p_sale_date, v_invoice_no, 'B2B Consignment Delivery', 'Accounts Receivable - Consignment', v_total_amount, 0, 'sale', v_sale_id, v_uid),
      ('GL', p_sale_date, v_invoice_no, 'B2B Consignment Delivery', 'Sales Revenue', 0, v_total_amount, 'sale', v_sale_id, v_uid);
  END IF;

  RETURN v_sale_id;
END;
$$;

-- 2. Update record_consignment_payment() -> auto-post BIR CRJ/GL ONLY if parent sale is SI
CREATE OR REPLACE FUNCTION public.record_consignment_payment(
  p_sale_id UUID,
  p_payment_date DATE,
  p_method public.payment_method,
  p_amount NUMERIC,
  p_reference_no TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role public.user_role := public.current_user_role();
  v_uid UUID := auth.uid();
  v_sale RECORD;
  v_new_paid NUMERIC(12,2);
  v_new_status public.payment_status;
  v_payment_id UUID;
BEGIN
  IF v_role NOT IN ('staff', 'manager', 'admin') THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'Payment amount must be greater than zero';
  END IF;

  SELECT * INTO v_sale FROM public.sales WHERE id = p_sale_id FOR UPDATE;
  IF NOT FOUND OR v_sale.status <> 'active' OR NOT v_sale.is_consignment THEN
    RAISE EXCEPTION 'Active consignment sale not found';
  END IF;

  v_new_paid := v_sale.amount_paid + p_amount;
  IF v_new_paid > v_sale.total_amount THEN
    RAISE EXCEPTION 'Payment exceeds remaining balance (remaining: %)', (v_sale.total_amount - v_sale.amount_paid);
  END IF;

  v_new_status := CASE WHEN v_new_paid >= v_sale.total_amount THEN 'paid' ELSE 'partial' END;

  INSERT INTO public.sale_payments (
    sale_id, payment_date, method, amount, reference_no, notes, recorded_by
  ) VALUES (
    p_sale_id, p_payment_date, p_method, p_amount, p_reference_no, p_notes, v_uid
  ) RETURNING id INTO v_payment_id;

  UPDATE public.sales
  SET amount_paid = v_new_paid,
      payment_status = v_new_status,
      updated_at = NOW()
  WHERE id = p_sale_id;

  -- Post to BIR CRJ/GL ONLY when parent consignment sale has an SI receipt
  IF v_sale.invoice_type = 'SI' THEN
    INSERT INTO public.bir_ledger_entries
      (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
    VALUES
      ('CRJ', p_payment_date, v_sale.invoice_no, 'Consignment Collection (' || p_method || ')', CASE WHEN p_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, p_amount, 0, 'payment', v_payment_id, v_uid),
      ('CRJ', p_payment_date, v_sale.invoice_no, 'Consignment Collection', 'Accounts Receivable - Consignment', 0, p_amount, 'payment', v_payment_id, v_uid),
      ('GL',  p_payment_date, v_sale.invoice_no, 'Consignment Collection (' || p_method || ')', CASE WHEN p_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, p_amount, 0, 'payment', v_payment_id, v_uid),
      ('GL',  p_payment_date, v_sale.invoice_no, 'Consignment Collection', 'Accounts Receivable - Consignment', 0, p_amount, 'payment', v_payment_id, v_uid);
  END IF;

  RETURN v_payment_id;
END;
$$;

-- 3. Update void_sale() -> post BIR GJ/GL reversal ONLY if voided sale was SI
CREATE OR REPLACE FUNCTION public.void_sale(
  p_sale_id UUID,
  p_reason TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role public.user_role := public.current_user_role();
  v_uid UUID := auth.uid();
  v_sale RECORD;
  v_snapshot JSONB;
  v_alloc RECORD;
BEGIN
  IF v_role NOT IN ('manager', 'admin') THEN
    RAISE EXCEPTION 'Only Manager or Admin can void sales';
  END IF;
  IF LENGTH(TRIM(COALESCE(p_reason, ''))) = 0 THEN
    RAISE EXCEPTION 'A void/cancel reason is required';
  END IF;

  SELECT * INTO v_sale FROM public.sales WHERE id = p_sale_id FOR UPDATE;
  IF NOT FOUND OR v_sale.status = 'voided' THEN
    RAISE EXCEPTION 'Active sale not found';
  END IF;

  SELECT jsonb_build_object(
    'sale', to_jsonb(v_sale),
    'items', COALESCE((SELECT jsonb_agg(to_jsonb(si)) FROM public.sale_items si WHERE si.sale_id = p_sale_id), '[]'::JSONB),
    'payments', COALESCE((SELECT jsonb_agg(to_jsonb(sp)) FROM public.sale_payments sp WHERE sp.sale_id = p_sale_id), '[]'::JSONB)
  ) INTO v_snapshot;

  FOR v_alloc IN
    SELECT sfa.stock_batch_id, sfa.deducted_kg
    FROM public.sale_fifo_allocations sfa
    JOIN public.sale_items si ON si.id = sfa.sale_item_id
    WHERE si.sale_id = p_sale_id
  LOOP
    UPDATE public.stock_batches
    SET remaining_kg = remaining_kg + v_alloc.deducted_kg
    WHERE id = v_alloc.stock_batch_id;
  END LOOP;

  UPDATE public.sales SET status = 'voided', updated_at = NOW() WHERE id = p_sale_id;
  UPDATE public.sale_payments SET status = 'voided' WHERE sale_id = p_sale_id;

  -- Always record immutable void audit snapshot (for BOTH SI and NSI)
  INSERT INTO public.void_audit_logs (record_type, record_id, original_snapshot, reason, voided_by)
  VALUES ('sale', p_sale_id, v_snapshot, TRIM(p_reason), v_uid);

  -- Post reversing entry in BIR GJ/GL ONLY when voided sale was SI (receipted)
  IF v_sale.invoice_type = 'SI' THEN
    INSERT INTO public.bir_ledger_entries
      (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
    VALUES
      ('GJ', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), 'Sales Returns & Allowances / Void', v_sale.total_amount, 0, 'void_reversal', p_sale_id, v_uid),
      ('GJ', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), CASE WHEN v_sale.is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Cash on Hand' END, 0, v_sale.total_amount, 'void_reversal', p_sale_id, v_uid),
      ('GL', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), 'Sales Returns & Allowances / Void', v_sale.total_amount, 0, 'void_reversal', p_sale_id, v_uid),
      ('GL', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), CASE WHEN v_sale.is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Cash on Hand' END, 0, v_sale.total_amount, 'void_reversal', p_sale_id, v_uid);
  END IF;
END;
$$;
