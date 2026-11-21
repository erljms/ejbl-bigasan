-- =============================================================================
-- EJBL Bigasan — Initial Supabase PostgreSQL Schema, RLS, and Atomic FIFO RPCs
-- Stack: Flutter & Dart (Android & Web / PWA, online-only) + Supabase
-- Status: Proposed migration (not yet executed against a live Supabase project)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- 1. ENUMS
-- -----------------------------------------------------------------------------
CREATE TYPE public.user_role AS ENUM ('staff', 'manager', 'admin');
CREATE TYPE public.invoice_type AS ENUM ('SI', 'NSI');
CREATE TYPE public.sale_unit AS ENUM ('SACK', 'KG');
CREATE TYPE public.fulfillment_type AS ENUM ('pickup', 'delivery');
CREATE TYPE public.payment_method AS ENUM ('cash', 'gcash', 'bank_transfer');
CREATE TYPE public.payment_status AS ENUM ('paid', 'partial', 'unpaid');
CREATE TYPE public.record_status AS ENUM ('active', 'voided');
CREATE TYPE public.expense_category AS ENUM (
  'COGS',
  'OPEX_FUEL',
  'OPEX_MARKETING',
  'OFFICE_SUPPLIES',
  'PERMIT',
  'EQUIPMENT',
  'SAFETY_EQUIPMENT',
  'TRANSPORTATION',
  'REPAIRS_MAINTENANCE',
  'SEALING_LICENSING',
  'FOOD_ALLOWANCE',
  'PERSONAL_WITHDRAWAL',
  'OTHER'
);
CREATE TYPE public.capital_entry_type AS ENUM (
  'opening_capital',
  'owner_contribution',
  'owner_withdrawal'
);
CREATE TYPE public.bir_book_type AS ENUM ('GL', 'CRJ', 'CDJ', 'GJ');
CREATE TYPE public.bir_source_type AS ENUM (
  'sale',
  'payment',
  'expense',
  'capital',
  'void_reversal',
  'manual'
);
CREATE TYPE public.void_record_type AS ENUM ('sale', 'expense', 'payment', 'capital');

-- -----------------------------------------------------------------------------
-- 2. SEQUENCES (Continuous SI from 1; Auto-generated NSI)
-- -----------------------------------------------------------------------------
CREATE SEQUENCE public.si_invoice_seq START WITH 1 INCREMENT BY 1 NO CYCLE;
CREATE SEQUENCE public.nsi_invoice_seq START WITH 1 INCREMENT BY 1 NO CYCLE;

-- -----------------------------------------------------------------------------
-- 3. CORE TABLES
-- -----------------------------------------------------------------------------

-- Internal user profiles linked 1:1 to Supabase auth.users
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  role public.user_role NOT NULL DEFAULT 'staff',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Rice varieties & integrated Price Guide (linked to Log & Inventory)
CREATE TABLE public.rice_varieties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE, -- e.g., CP, MC, PH, CJ, JR, GS
  name TEXT NOT NULL,        -- e.g., COCO PANDAN, MAGIC CASTLE
  sack_weight_kg NUMERIC(10,3) NOT NULL DEFAULT 25.000 CHECK (sack_weight_kg > 0),
  wholesale_sack_price NUMERIC(12,2) NOT NULL CHECK (wholesale_sack_price >= 0),
  retail_sack_price NUMERIC(12,2) NOT NULL CHECK (retail_sack_price >= 0),
  wholesale_kg_price NUMERIC(12,2) NOT NULL CHECK (wholesale_kg_price >= 0),
  retail_kg_price NUMERIC(12,2) NOT NULL CHECK (retail_kg_price >= 0),
  display_kg_price NUMERIC(12,2),
  ordering_point_kg NUMERIC(10,3) NOT NULL DEFAULT 50.000 CHECK (ordering_point_kg >= 0),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Internal reference table only (suppliers do not log in)
CREATE TABLE public.suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact_info TEXT,
  notes TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Internal reference table only (B2B consignment clients do not log in)
CREATE TABLE public.consignment_clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_name TEXT NOT NULL UNIQUE, -- e.g., GA-RA-HE, CARIBBEAN GRILL
  contact_info TEXT,
  payment_schedule TEXT,              -- e.g., Every Sunday
  notes TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Expenses (Log Out + Auto-populated Business Records Out + Auto COGS from Restock)
CREATE TABLE public.expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  invoice_no TEXT,
  category public.expense_category NOT NULL,
  description TEXT NOT NULL,
  payment_method public.payment_method NOT NULL DEFAULT 'cash',
  reference_no TEXT,
  amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  payment_status public.payment_status NOT NULL DEFAULT 'paid',
  status public.record_status NOT NULL DEFAULT 'active',
  notes TEXT,
  created_by UUID NOT NULL REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- FIFO Inventory Batches (tracks purchase cost / puhunan per kg per delivery)
CREATE TABLE public.stock_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rice_variety_id UUID NOT NULL REFERENCES public.rice_varieties(id) ON DELETE RESTRICT,
  supplier_id UUID REFERENCES public.suppliers(id) ON DELETE SET NULL,
  received_date DATE NOT NULL DEFAULT CURRENT_DATE,
  initial_kg NUMERIC(10,3) NOT NULL CHECK (initial_kg > 0),
  remaining_kg NUMERIC(10,3) NOT NULL CHECK (remaining_kg >= 0 AND remaining_kg <= initial_kg),
  unit_cost_per_kg NUMERIC(12,4) NOT NULL CHECK (unit_cost_per_kg >= 0), -- puhunan/kg
  total_cost NUMERIC(12,2) GENERATED ALWAYS AS (ROUND(initial_kg * unit_cost_per_kg, 2)) STORED,
  supplier_invoice_no TEXT,
  is_opening_balance BOOLEAN NOT NULL DEFAULT FALSE,
  expense_id UUID UNIQUE REFERENCES public.expenses(id) ON DELETE RESTRICT,
  notes TEXT,
  created_by UUID NOT NULL REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Fast FIFO batch lookup index (oldest available batch first)
CREATE INDEX idx_stock_batches_fifo
  ON public.stock_batches (rice_variety_id, received_date ASC, created_at ASC)
  WHERE remaining_kg > 0;

-- Sales Header (Log In — supports multi-item, SI/NSI, delivery fee income, consignment)
CREATE TABLE public.sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_date DATE NOT NULL DEFAULT CURRENT_DATE,
  invoice_type public.invoice_type NOT NULL,
  invoice_no TEXT NOT NULL,
  fulfillment_type public.fulfillment_type NOT NULL DEFAULT 'pickup',
  delivery_fee NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
  rice_subtotal NUMERIC(12,2) NOT NULL CHECK (rice_subtotal >= 0),
  total_amount NUMERIC(12,2) GENERATED ALWAYS AS (rice_subtotal + delivery_fee) STORED,
  is_consignment BOOLEAN NOT NULL DEFAULT FALSE,
  consignment_client_id UUID REFERENCES public.consignment_clients(id) ON DELETE RESTRICT,
  payment_status public.payment_status NOT NULL DEFAULT 'paid',
  amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (amount_paid >= 0),
  status public.record_status NOT NULL DEFAULT 'active',
  notes TEXT,
  created_by UUID NOT NULL REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_consignment_client CHECK (
    (is_consignment = FALSE AND consignment_client_id IS NULL) OR
    (is_consignment = TRUE AND consignment_client_id IS NOT NULL)
  )
);

-- Unique invoice numbers among active sales per type
CREATE UNIQUE INDEX uq_sales_active_invoice
  ON public.sales (invoice_type, invoice_no)
  WHERE status = 'active';

CREATE INDEX idx_sales_date_status ON public.sales (sale_date DESC, status);
CREATE INDEX idx_sales_consignment ON public.sales (consignment_client_id, payment_status)
  WHERE is_consignment = TRUE AND status = 'active';

-- Sale Line Items (supports multiple rice varieties per single invoice)
CREATE TABLE public.sale_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
  rice_variety_id UUID NOT NULL REFERENCES public.rice_varieties(id) ON DELETE RESTRICT,
  qty_input NUMERIC(10,3) NOT NULL CHECK (qty_input > 0),
  unit public.sale_unit NOT NULL,
  qty_kg NUMERIC(10,3) NOT NULL CHECK (qty_kg > 0),
  guide_price_per_kg NUMERIC(12,4) NOT NULL CHECK (guide_price_per_kg >= 0),
  applied_price_per_kg NUMERIC(12,4) NOT NULL CHECK (applied_price_per_kg >= 0),
  price_overridden BOOLEAN NOT NULL DEFAULT FALSE,
  line_total NUMERIC(12,2) NOT NULL CHECK (line_total >= 0),
  total_fifo_cogs NUMERIC(12,4) NOT NULL DEFAULT 0 CHECK (total_fifo_cogs >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sale_items_sale ON public.sale_items (sale_id);

-- Exact FIFO Batch Deductions per Sale Item (enables exact COGS + clean void restoration)
CREATE TABLE public.sale_fifo_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_item_id UUID NOT NULL REFERENCES public.sale_items(id) ON DELETE CASCADE,
  stock_batch_id UUID NOT NULL REFERENCES public.stock_batches(id) ON DELETE RESTRICT,
  deducted_kg NUMERIC(10,3) NOT NULL CHECK (deducted_kg > 0),
  unit_cost_per_kg NUMERIC(12,4) NOT NULL CHECK (unit_cost_per_kg >= 0),
  cost_total NUMERIC(12,4) GENERATED ALWAYS AS (ROUND(deducted_kg * unit_cost_per_kg, 4)) STORED,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fifo_alloc_item ON public.sale_fifo_allocations (sale_item_id);
CREATE INDEX idx_fifo_alloc_batch ON public.sale_fifo_allocations (stock_batch_id);

-- Payments (supports cash, online, split payments, and partial/full consignment collections)
CREATE TABLE public.sale_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES public.sales(id) ON DELETE RESTRICT,
  payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  method public.payment_method NOT NULL,
  amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  reference_no TEXT, -- GCash / BPI / InstaPay ref no.
  status public.record_status NOT NULL DEFAULT 'active',
  notes TEXT,
  recorded_by UUID NOT NULL REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sale_payments_date ON public.sale_payments (payment_date DESC, status);
CREATE INDEX idx_sale_payments_sale ON public.sale_payments (sale_id);

-- Daily Cash Box & GCash Reconciliation (mirrors CASHBOOK CASH BOX / GCASH / SOBRA / SHORT)
CREATE TABLE public.daily_cash_reconciliations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recon_date DATE NOT NULL UNIQUE,
  expected_cash NUMERIC(12,2) NOT NULL DEFAULT 0,
  counted_cash_box NUMERIC(12,2) NOT NULL DEFAULT 0,
  expected_online NUMERIC(12,2) NOT NULL DEFAULT 0,
  counted_online NUMERIC(12,2) NOT NULL DEFAULT 0,
  variance NUMERIC(12,2) GENERATED ALWAYS AS (
    (counted_cash_box + counted_online) - (expected_cash + expected_online)
  ) STORED, -- positive = SOBRA, negative = SHORT
  notes TEXT,
  recorded_by UUID NOT NULL REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Owner Capital Section (Opening Capital, OWN-xxx Contributions, DRAW-xxx Withdrawals)
CREATE TABLE public.capital_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  reference_no TEXT,
  entry_type public.capital_entry_type NOT NULL,
  payment_method public.payment_method NOT NULL DEFAULT 'cash',
  amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  description TEXT NOT NULL,
  linked_expense_id UUID REFERENCES public.expenses(id) ON DELETE RESTRICT,
  status public.record_status NOT NULL DEFAULT 'active',
  created_by UUID NOT NULL REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Immutable Void / Cancel Audit Trail (visible to Admin/Owner)
CREATE TABLE public.void_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  record_type public.void_record_type NOT NULL,
  record_id UUID NOT NULL,
  original_snapshot JSONB NOT NULL,
  reason TEXT NOT NULL CHECK (LENGTH(TRIM(reason)) > 0),
  voided_by UUID NOT NULL REFERENCES public.profiles(id),
  voided_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_void_audit_date ON public.void_audit_logs (voided_at DESC);

-- 4 BIR Books (General Ledger, Cash Receipts Journal, Cash Disbursements Journal, General Journal)
-- Flexible column design pending final bookkeeper/CPA format confirmation
CREATE TABLE public.bir_ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_type public.bir_book_type NOT NULL,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  reference_no TEXT,
  particulars TEXT NOT NULL,
  account_code TEXT,
  account_title TEXT NOT NULL,
  debit NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (debit >= 0),
  credit NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (credit >= 0),
  source_type public.bir_source_type NOT NULL,
  source_id UUID,
  is_manual BOOLEAN NOT NULL DEFAULT FALSE,
  is_edited BOOLEAN NOT NULL DEFAULT FALSE,
  notes TEXT,
  created_by UUID NOT NULL REFERENCES public.profiles(id),
  updated_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_debit_or_credit CHECK (debit > 0 OR credit > 0)
);

CREATE INDEX idx_bir_book_date ON public.bir_ledger_entries (book_type, entry_date DESC);

-- -----------------------------------------------------------------------------
-- 4. VIEWS (Auto-Populated Inventory Summary & Business Records Cashbook)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW public.v_inventory_summary AS
SELECT
  rv.id AS rice_variety_id,
  rv.code,
  rv.name,
  rv.sack_weight_kg,
  rv.wholesale_sack_price,
  rv.retail_sack_price,
  rv.wholesale_kg_price,
  rv.retail_kg_price,
  rv.ordering_point_kg,
  COALESCE(SUM(sb.remaining_kg), 0) AS total_remaining_kg,
  ROUND(COALESCE(SUM(sb.remaining_kg), 0) / rv.sack_weight_kg, 2) AS remaining_sacks,
  (COALESCE(SUM(sb.remaining_kg), 0) <= rv.ordering_point_kg) AS is_low_stock
FROM public.rice_varieties rv
LEFT JOIN public.stock_batches sb ON sb.rice_variety_id = rv.id AND sb.remaining_kg > 0
WHERE rv.is_active = TRUE
GROUP BY rv.id;

-- Auto-populated Cashbook view (Business Records In) — only actual collected payments
CREATE OR REPLACE VIEW public.v_cashbook_entries AS
SELECT
  sp.id AS payment_id,
  sp.payment_date AS entry_date,
  s.invoice_type,
  s.invoice_no,
  s.is_consignment,
  cc.business_name AS consignment_client,
  CASE WHEN sp.method = 'cash' THEN sp.amount ELSE 0 END AS cash_amount,
  CASE WHEN sp.method IN ('gcash', 'bank_transfer') THEN sp.amount ELSE 0 END AS online_amount,
  sp.amount AS total_amount,
  sp.method,
  sp.reference_no,
  s.delivery_fee,
  sp.notes,
  sp.recorded_by
FROM public.sale_payments sp
JOIN public.sales s ON s.id = sp.sale_id
LEFT JOIN public.consignment_clients cc ON cc.id = s.consignment_client_id
WHERE sp.status = 'active' AND s.status = 'active';

-- -----------------------------------------------------------------------------
-- 5. ROW LEVEL SECURITY (RLS) HELPER & POLICIES
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS public.user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid() AND is_active = TRUE;
$$;

-- Enable RLS on every table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rice_varieties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consignment_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_fifo_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_cash_reconciliations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capital_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.void_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bir_ledger_entries ENABLE ROW LEVEL SECURITY;

-- Profiles: users read own profile; admin manages all
CREATE POLICY "profiles_select_self_or_admin" ON public.profiles
  FOR SELECT USING (id = auth.uid() OR public.current_user_role() = 'admin');
CREATE POLICY "profiles_admin_all" ON public.profiles
  FOR ALL USING (public.current_user_role() = 'admin');

-- Rice Varieties (Inventory / Price Guide): all active roles view; Manager & Admin manage
CREATE POLICY "rice_varieties_select_all" ON public.rice_varieties
  FOR SELECT USING (public.current_user_role() IN ('staff', 'manager', 'admin'));
CREATE POLICY "rice_varieties_write_mgr_admin" ON public.rice_varieties
  FOR ALL USING (public.current_user_role() IN ('manager', 'admin'));

-- Suppliers & Consignment Clients: all roles read for Log dropdowns; Manager & Admin manage
CREATE POLICY "suppliers_select_all" ON public.suppliers
  FOR SELECT USING (public.current_user_role() IN ('staff', 'manager', 'admin'));
CREATE POLICY "suppliers_write_mgr_admin" ON public.suppliers
  FOR ALL USING (public.current_user_role() IN ('manager', 'admin'));

CREATE POLICY "consignment_clients_select_all" ON public.consignment_clients
  FOR SELECT USING (public.current_user_role() IN ('staff', 'manager', 'admin'));
CREATE POLICY "consignment_clients_write_mgr_admin" ON public.consignment_clients
  FOR ALL USING (public.current_user_role() IN ('manager', 'admin'));

-- Stock Batches (Inventory): all view; Manager & Admin insert/update (no hard delete)
CREATE POLICY "stock_batches_select_all" ON public.stock_batches
  FOR SELECT USING (public.current_user_role() IN ('staff', 'manager', 'admin'));
CREATE POLICY "stock_batches_insert_mgr_admin" ON public.stock_batches
  FOR INSERT WITH CHECK (public.current_user_role() IN ('manager', 'admin'));
CREATE POLICY "stock_batches_update_mgr_admin" ON public.stock_batches
  FOR UPDATE USING (public.current_user_role() IN ('manager', 'admin'));

-- Sales, Sale Items, Sale Payments (Log + Business Records):
-- Staff can insert & view own recent Log entries; Manager & Admin read all & edit via RPC; NO hard DELETE
CREATE POLICY "sales_select_policy" ON public.sales
  FOR SELECT USING (
    public.current_user_role() IN ('manager', 'admin') OR
    (public.current_user_role() = 'staff' AND created_by = auth.uid())
  );
CREATE POLICY "sales_insert_all" ON public.sales
  FOR INSERT WITH CHECK (public.current_user_role() IN ('staff', 'manager', 'admin'));
CREATE POLICY "sales_update_mgr_admin" ON public.sales
  FOR UPDATE USING (public.current_user_role() IN ('manager', 'admin'));

CREATE POLICY "sale_items_select_policy" ON public.sale_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.sales s WHERE s.id = sale_id)
  );
CREATE POLICY "sale_items_insert_all" ON public.sale_items
  FOR INSERT WITH CHECK (public.current_user_role() IN ('staff', 'manager', 'admin'));

CREATE POLICY "sale_fifo_select_mgr_admin" ON public.sale_fifo_allocations
  FOR SELECT USING (public.current_user_role() IN ('manager', 'admin'));

CREATE POLICY "sale_payments_select_policy" ON public.sale_payments
  FOR SELECT USING (
    public.current_user_role() IN ('manager', 'admin') OR
    (public.current_user_role() = 'staff' AND recorded_by = auth.uid())
  );
CREATE POLICY "sale_payments_insert_all" ON public.sale_payments
  FOR INSERT WITH CHECK (public.current_user_role() IN ('staff', 'manager', 'admin'));

-- Expenses (Log Out + Business Records Out):
-- Staff inserts & views own; Manager views all (Business Records view-only) & edits/voids Log Out; Admin full
CREATE POLICY "expenses_select_policy" ON public.expenses
  FOR SELECT USING (
    public.current_user_role() IN ('manager', 'admin') OR
    (public.current_user_role() = 'staff' AND created_by = auth.uid())
  );
CREATE POLICY "expenses_insert_all" ON public.expenses
  FOR INSERT WITH CHECK (public.current_user_role() IN ('staff', 'manager', 'admin'));
CREATE POLICY "expenses_update_mgr_admin" ON public.expenses
  FOR UPDATE USING (public.current_user_role() IN ('manager', 'admin'));

-- Daily Cash Reconciliations (Business Records): Manager view-only; Admin full
CREATE POLICY "recon_select_mgr_admin" ON public.daily_cash_reconciliations
  FOR SELECT USING (public.current_user_role() IN ('manager', 'admin'));
CREATE POLICY "recon_write_admin" ON public.daily_cash_reconciliations
  FOR ALL USING (public.current_user_role() = 'admin');

-- Capital Entries: Admin ONLY
CREATE POLICY "capital_admin_only" ON public.capital_entries
  FOR ALL USING (public.current_user_role() = 'admin');

-- Void Audit Logs: Admin reads all; Manager reads own voids; NO direct update/delete for anyone
CREATE POLICY "void_audit_select_admin_or_own" ON public.void_audit_logs
  FOR SELECT USING (
    public.current_user_role() = 'admin' OR
    (public.current_user_role() = 'manager' AND voided_by = auth.uid())
  );

-- BIR Ledger Entries: Admin ONLY
CREATE POLICY "bir_entries_admin_only" ON public.bir_ledger_entries
  FOR ALL USING (public.current_user_role() = 'admin');

-- -----------------------------------------------------------------------------
-- 6. ATOMIC SERVER-SIDE RPC FUNCTIONS (FIFO + Auto-COGS + Void + BIR Posting)
-- -----------------------------------------------------------------------------

-- RPC 1: Receive Rice Stock -> creates FIFO batch + auto-creates COGS Expense + posts CDJ/GL
CREATE OR REPLACE FUNCTION public.receive_stock(
  p_rice_variety_id UUID,
  p_supplier_id UUID,
  p_received_date DATE,
  p_qty_kg NUMERIC,
  p_unit_cost_per_kg NUMERIC,
  p_payment_method public.payment_method,
  p_supplier_invoice_no TEXT DEFAULT NULL,
  p_reference_no TEXT DEFAULT NULL,
  p_is_opening_balance BOOLEAN DEFAULT FALSE,
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
  v_variety RECORD;
  v_total_cost NUMERIC(12,2) := ROUND(p_qty_kg * p_unit_cost_per_kg, 2);
  v_expense_id UUID := NULL;
  v_batch_id UUID;
BEGIN
  IF v_role NOT IN ('manager', 'admin') THEN
    RAISE EXCEPTION 'Only Manager or Admin can receive inventory stock';
  END IF;

  SELECT code, name INTO v_variety FROM public.rice_varieties WHERE id = p_rice_variety_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Rice variety not found';
  END IF;

  -- Auto-create COGS expense unless this is an initial opening stock load
  IF NOT p_is_opening_balance THEN
    INSERT INTO public.expenses (
      expense_date, invoice_no, category, description,
      payment_method, reference_no, amount, payment_status, notes, created_by
    ) VALUES (
      p_received_date, p_supplier_invoice_no, 'COGS',
      FORMAT('%s (%s) - %s KG @ %s/KG', v_variety.name, v_variety.code, p_qty_kg, p_unit_cost_per_kg),
      p_payment_method, p_reference_no, v_total_cost, 'paid', p_notes, v_uid
    ) RETURNING id INTO v_expense_id;

    -- Auto-post Cash Disbursements Journal & General Ledger entries
    INSERT INTO public.bir_ledger_entries
      (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
    VALUES
      ('CDJ', p_received_date, p_supplier_invoice_no, 'Rice Restock - ' || v_variety.code, 'Merchandise Inventory / Purchases', v_total_cost, 0, 'expense', v_expense_id, v_uid),
      ('CDJ', p_received_date, p_supplier_invoice_no, 'Rice Restock - ' || v_variety.code, CASE WHEN p_payment_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, 0, v_total_cost, 'expense', v_expense_id, v_uid),
      ('GL',  p_received_date, p_supplier_invoice_no, 'Rice Restock - ' || v_variety.code, 'Merchandise Inventory / Purchases', v_total_cost, 0, 'expense', v_expense_id, v_uid),
      ('GL',  p_received_date, p_supplier_invoice_no, 'Rice Restock - ' || v_variety.code, CASE WHEN p_payment_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, 0, v_total_cost, 'expense', v_expense_id, v_uid);
  END IF;

  INSERT INTO public.stock_batches (
    rice_variety_id, supplier_id, received_date, initial_kg, remaining_kg,
    unit_cost_per_kg, supplier_invoice_no, is_opening_balance, expense_id, notes, created_by
  ) VALUES (
    p_rice_variety_id, p_supplier_id, p_received_date, p_qty_kg, p_qty_kg,
    p_unit_cost_per_kg, p_supplier_invoice_no, p_is_opening_balance, v_expense_id, p_notes, v_uid
  ) RETURNING id INTO v_batch_id;

  RETURN v_batch_id;
END;
$$;

-- RPC 2: Create Sale -> atomic invoice numbering + FIFO deduction + split payments + BIR CRJ/GL posting
-- p_items JSONB: [{"rice_variety_id": "...", "qty_input": 1, "unit": "SACK", "applied_price_per_kg": 52.00}]
-- p_payments JSONB: [{"method": "cash", "amount": 1000, "reference_no": null}, ...] (empty [] for unpaid consignment)
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

  -- Create sale shell first (subtotal updated after validating items)
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
      -- Tiered sack guide price: 3+ sacks OR walk-in -> wholesale; 1-2 delivery -> retail
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

    -- Enforce server-side: only Manager and Admin may override guide prices
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

    -- FIFO stock deduction with row locks (FOR UPDATE) to prevent race conditions
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

  -- Record payments (supports split cash + GCash/bank; empty for unpaid consignment)
  FOR v_pay IN SELECT * FROM jsonb_array_elements(COALESCE(p_payments, '[]'::JSONB))
  LOOP
    INSERT INTO public.sale_payments (
      sale_id, payment_date, method, amount, reference_no, recorded_by
    ) VALUES (
      v_sale_id, p_sale_date, (v_pay->>'method')::public.payment_method,
      (v_pay->>'amount')::NUMERIC, v_pay->>'reference_no', v_uid
    ) RETURNING id INTO v_payment_id;

    v_total_paid := v_total_paid + (v_pay->>'amount')::NUMERIC;

    -- Auto-post Cash Receipts Journal & General Ledger ONLY for actual cash/online collected
    INSERT INTO public.bir_ledger_entries
      (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
    VALUES
      ('CRJ', p_sale_date, v_invoice_no, 'Sale Payment (' || (v_pay->>'method') || ')', CASE WHEN (v_pay->>'method') = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, (v_pay->>'amount')::NUMERIC, 0, 'payment', v_payment_id, v_uid),
      ('CRJ', p_sale_date, v_invoice_no, 'Sale Revenue / Collection', CASE WHEN p_is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Sales Revenue' END, 0, (v_pay->>'amount')::NUMERIC, 'payment', v_payment_id, v_uid),
      ('GL',  p_sale_date, v_invoice_no, 'Sale Payment (' || (v_pay->>'method') || ')', CASE WHEN (v_pay->>'method') = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, (v_pay->>'amount')::NUMERIC, 0, 'payment', v_payment_id, v_uid),
      ('GL',  p_sale_date, v_invoice_no, 'Sale Revenue / Collection', CASE WHEN p_is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Sales Revenue' END, 0, (v_pay->>'amount')::NUMERIC, 'payment', v_payment_id, v_uid);
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

  -- For consignment deliveries, record Accounts Receivable in General Journal / GL immediately
  IF p_is_consignment THEN
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

-- RPC 3: Void/Cancel a Sale (Manager or Admin) -> restores FIFO stock + writes immutable void_audit_logs + reverses BIR
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

  -- Build full immutable snapshot for Owner review
  SELECT jsonb_build_object(
    'sale', to_jsonb(v_sale),
    'items', COALESCE((SELECT jsonb_agg(to_jsonb(si)) FROM public.sale_items si WHERE si.sale_id = p_sale_id), '[]'::JSONB),
    'payments', COALESCE((SELECT jsonb_agg(to_jsonb(sp)) FROM public.sale_payments sp WHERE sp.sale_id = p_sale_id), '[]'::JSONB)
  ) INTO v_snapshot;

  -- Restore exact FIFO batch quantities
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

  -- Save immutable audit record
  INSERT INTO public.void_audit_logs (record_type, record_id, original_snapshot, reason, voided_by)
  VALUES ('sale', p_sale_id, v_snapshot, TRIM(p_reason), v_uid);

  -- Post reversing entry in General Journal & General Ledger
  INSERT INTO public.bir_ledger_entries
    (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
  VALUES
    ('GJ', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), 'Sales Returns & Allowances / Void', v_sale.total_amount, 0, 'void_reversal', p_sale_id, v_uid),
    ('GJ', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), CASE WHEN v_sale.is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Cash on Hand' END, 0, v_sale.total_amount, 'void_reversal', p_sale_id, v_uid),
    ('GL', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), 'Sales Returns & Allowances / Void', v_sale.total_amount, 0, 'void_reversal', p_sale_id, v_uid),
    ('GL', CURRENT_DATE, v_sale.invoice_no, 'VOID REVERSAL: ' || TRIM(p_reason), CASE WHEN v_sale.is_consignment THEN 'Accounts Receivable - Consignment' ELSE 'Cash on Hand' END, 0, v_sale.total_amount, 'void_reversal', p_sale_id, v_uid);
END;
$$;

-- RPC 4: Record B2B Consignment Payment (Partial or Full) -> updates sales + posts CRJ/GL
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

  -- Post to Cash Receipts Journal & General Ledger only upon actual collection
  INSERT INTO public.bir_ledger_entries
    (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
  VALUES
    ('CRJ', p_payment_date, v_sale.invoice_no, 'Consignment Collection (' || p_method || ')', CASE WHEN p_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, p_amount, 0, 'payment', v_payment_id, v_uid),
    ('CRJ', p_payment_date, v_sale.invoice_no, 'Consignment Collection', 'Accounts Receivable - Consignment', 0, p_amount, 'payment', v_payment_id, v_uid),
    ('GL',  p_payment_date, v_sale.invoice_no, 'Consignment Collection (' || p_method || ')', CASE WHEN p_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, p_amount, 0, 'payment', v_payment_id, v_uid),
    ('GL',  p_payment_date, v_sale.invoice_no, 'Consignment Collection', 'Accounts Receivable - Consignment', 0, p_amount, 'payment', v_payment_id, v_uid);

  RETURN v_payment_id;
END;
$$;

-- RPC 5: Record Expense (Log Out) -> inserts expenses + links PERSONAL_WITHDRAWAL to capital + posts CDJ/GL
CREATE OR REPLACE FUNCTION public.record_expense(
  p_expense_date DATE,
  p_invoice_no TEXT,
  p_category public.expense_category,
  p_description TEXT,
  p_payment_method public.payment_method,
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
  v_expense_id UUID;
  v_debit_account TEXT;
BEGIN
  IF v_role NOT IN ('staff', 'manager', 'admin') THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
  IF p_category = 'PERSONAL_WITHDRAWAL' AND v_role <> 'admin' THEN
    RAISE EXCEPTION 'Only Admin/Owner can record personal withdrawals';
  END IF;

  INSERT INTO public.expenses (
    expense_date, invoice_no, category, description,
    payment_method, reference_no, amount, payment_status, notes, created_by
  ) VALUES (
    p_expense_date, p_invoice_no, p_category, p_description,
    p_payment_method, p_reference_no, p_amount, 'paid', p_notes, v_uid
  ) RETURNING id INTO v_expense_id;

  IF p_category = 'PERSONAL_WITHDRAWAL' THEN
    INSERT INTO public.capital_entries (
      entry_date, reference_no, entry_type, payment_method, amount, description, linked_expense_id, created_by
    ) VALUES (
      p_expense_date, p_invoice_no, 'owner_withdrawal', p_payment_method, p_amount, p_description, v_expense_id, v_uid
    );
    v_debit_account := 'Owner Drawings';
  ELSE
    v_debit_account := 'Operating Expense - ' || p_category::TEXT;
  END IF;

  INSERT INTO public.bir_ledger_entries
    (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
  VALUES
    ('CDJ', p_expense_date, p_invoice_no, p_description, v_debit_account, p_amount, 0, 'expense', v_expense_id, v_uid),
    ('CDJ', p_expense_date, p_invoice_no, p_description, CASE WHEN p_payment_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, 0, p_amount, 'expense', v_expense_id, v_uid),
    ('GL',  p_expense_date, p_invoice_no, p_description, v_debit_account, p_amount, 0, 'expense', v_expense_id, v_uid),
    ('GL',  p_expense_date, p_invoice_no, p_description, CASE WHEN p_payment_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, 0, p_amount, 'expense', v_expense_id, v_uid);

  RETURN v_expense_id;
END;
$$;

-- RPC 6: Void/Cancel an Expense (Manager or Admin) -> immutable void_audit_logs + GJ/GL reversal
CREATE OR REPLACE FUNCTION public.void_expense(
  p_expense_id UUID,
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
  v_exp RECORD;
BEGIN
  IF v_role NOT IN ('manager', 'admin') THEN
    RAISE EXCEPTION 'Only Manager or Admin can void expenses';
  END IF;
  IF LENGTH(TRIM(COALESCE(p_reason, ''))) = 0 THEN
    RAISE EXCEPTION 'A void/cancel reason is required';
  END IF;

  SELECT * INTO v_exp FROM public.expenses WHERE id = p_expense_id FOR UPDATE;
  IF NOT FOUND OR v_exp.status = 'voided' THEN
    RAISE EXCEPTION 'Active expense not found';
  END IF;
  IF v_exp.category = 'COGS' THEN
    RAISE EXCEPTION 'COGS restock expenses must be adjusted via Inventory batch reversal to protect FIFO integrity';
  END IF;
  IF v_exp.category = 'PERSONAL_WITHDRAWAL' AND v_role <> 'admin' THEN
    RAISE EXCEPTION 'Only Admin/Owner can void personal withdrawals';
  END IF;

  UPDATE public.expenses SET status = 'voided', updated_at = NOW() WHERE id = p_expense_id;
  UPDATE public.capital_entries SET status = 'voided', updated_at = NOW() WHERE linked_expense_id = p_expense_id;

  INSERT INTO public.void_audit_logs (record_type, record_id, original_snapshot, reason, voided_by)
  VALUES ('expense', p_expense_id, to_jsonb(v_exp), TRIM(p_reason), v_uid);

  INSERT INTO public.bir_ledger_entries
    (book_type, entry_date, reference_no, particulars, account_title, debit, credit, source_type, source_id, created_by)
  VALUES
    ('GJ', CURRENT_DATE, v_exp.invoice_no, 'VOID EXPENSE REVERSAL: ' || TRIM(p_reason), CASE WHEN v_exp.payment_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, v_exp.amount, 0, 'void_reversal', p_expense_id, v_uid),
    ('GJ', CURRENT_DATE, v_exp.invoice_no, 'VOID EXPENSE REVERSAL: ' || TRIM(p_reason), 'Operating Expense - ' || v_exp.category::TEXT, 0, v_exp.amount, 'void_reversal', p_expense_id, v_uid),
    ('GL', CURRENT_DATE, v_exp.invoice_no, 'VOID EXPENSE REVERSAL: ' || TRIM(p_reason), CASE WHEN v_exp.payment_method = 'cash' THEN 'Cash on Hand' ELSE 'Cash in Bank / GCash' END, v_exp.amount, 0, 'void_reversal', p_expense_id, v_uid),
    ('GL', CURRENT_DATE, v_exp.invoice_no, 'VOID EXPENSE REVERSAL: ' || TRIM(p_reason), 'Operating Expense - ' || v_exp.category::TEXT, 0, v_exp.amount, 'void_reversal', p_expense_id, v_uid);
END;
$$;
