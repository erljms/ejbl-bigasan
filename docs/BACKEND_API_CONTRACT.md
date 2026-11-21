# EJBL Backend API Contract (Supabase + Flutter)

This document defines every Supabase table, view, RLS permission rule, and SQL RPC function available to the Flutter frontend (`Android` + `Web PWA`).

---

## 1. Environment Configuration (Never Commit Keys)

Pass these via `--dart-define` (or a local gitignored launch config):
- `SUPABASE_URL`: Your Supabase Project URL (`https://<ref>.supabase.co`)
- `SUPABASE_ANON_KEY`: Your Supabase **Publishable key** (`sb_publishable_...`)

> **NEVER** use the `Secret key` (`sb_secret_...` / `service_role`) in Flutter.

---

## 2. Role Permissions Matrix (Enforced by PostgreSQL RLS + RPCs)

| Capability | `staff` | `manager` | `admin` |
| :--- | :---: | :---: | :---: |
| Sign in & view own `profiles` row | ✅ | ✅ | ✅ |
| View `v_inventory_summary`, `rice_varieties`, `suppliers`, `consignment_clients` | ✅ | ✅ | ✅ |
| Manage `rice_varieties` (Price Guide), `suppliers`, `consignment_clients` | ❌ | ✅ | ✅ |
| Call `receive_stock()` (Receive inventory + auto COGS) | ❌ | ✅ | ✅ |
| Call `create_sale()` (guide price only) | ✅ | ✅ | ✅ |
| Call `create_sale()` with overridden price | ❌ *(server blocks)* | ✅ | ✅ |
| Call `record_consignment_payment()` | ✅ | ✅ | ✅ |
| Call `record_expense()` (non-withdrawal categories) | ✅ | ✅ | ✅ |
| Call `record_expense()` (`PERSONAL_WITHDRAWAL`) | ❌ | ❌ | ✅ |
| Call `void_sale()` / `void_expense()` (reason required) | ❌ | ✅ | ✅ |
| View `v_cashbook_entries`, `expenses`, `daily_cash_reconciliations` | Own only (`expenses`) / ❌ | ✅ *(View-Only)* | ✅ *(Full)* |
| View `void_audit_logs` | ❌ | Own voids only | ✅ *(All voids)* |
| Access `capital_entries` & `bir_ledger_entries` (4 BIR Books) | ❌ | ❌ | ✅ *(Full + PDF)* |

---

## 3. Read Views & Key Tables

### `v_inventory_summary` (SELECT)
Returns live FIFO stock per active rice variety:
- `rice_variety_id`, `code`, `name`, `sack_weight_kg`
- `wholesale_sack_price`, `retail_sack_price`, `wholesale_kg_price`, `retail_kg_price`
- `ordering_point_kg`, `total_remaining_kg`, `remaining_sacks`, `is_low_stock`

### `v_cashbook_entries` (SELECT — Manager & Admin)
Auto-populated from active `sale_payments` joined with active `sales`:
- `payment_id`, `entry_date`, `invoice_type`, `invoice_no`, `is_consignment`, `consignment_client`
- `cash_amount`, `online_amount`, `total_amount`, `method`, `reference_no`, `delivery_fee`, `notes`, `recorded_by`

### `void_audit_logs` (SELECT — Admin all, Manager own)
Immutable log of every cancelled sale/expense:
- `id`, `record_type` (`sale` | `expense`), `record_id`, `original_snapshot` (JSONB), `reason`, `voided_by`, `voided_at`

### `bir_ledger_entries` (SELECT / INSERT / UPDATE — Admin only)
- `id`, `book_type` (`GL` | `CRJ` | `CDJ` | `GJ`), `entry_date`, `reference_no`, `particulars`, `account_code`, `account_title`, `debit`, `credit`, `source_type`, `source_id`, `is_manual`, `is_edited`, `notes`

---

## 4. Atomic SQL RPC Contracts (`supabase.rpc(...)`)

### 1. `receive_stock` *(Manager / Admin)*
Creates a FIFO batch, auto-creates a `COGS` expense (unless `p_is_opening_balance: true`), and posts balanced `CDJ` + `GL` entries.
```dart
await client.rpc('receive_stock', params: {
  'p_rice_variety_id': riceVarietyId,    // UUID
  'p_supplier_id': supplierId,           // UUID or null
  'p_received_date': '2026-11-20',       // YYYY-MM-DD
  'p_qty_kg': 250.0,                     // numeric > 0
  'p_unit_cost_per_kg': 44.80,           // puhunan per kg
  'p_payment_method': 'cash',            // cash | gcash | bank_transfer
  'p_supplier_invoice_no': 'DR-1024',    // optional
  'p_reference_no': null,                // optional GCash/bank ref
  'p_is_opening_balance': false,         // true only for initial Excel migration
  'p_notes': null,
});
// Returns: UUID (new stock_batches.id)
```

### 2. `create_sale` *(Staff / Manager / Admin)*
Assigns continuous `SI` (starting from 1) or auto-generated `NSI-001`, checks guide pricing (blocks `staff` price overrides), locks & deducts FIFO batches (`FOR UPDATE`), records split payments (updates Cashbook for both `SI` and `NSI`), and auto-posts `CRJ`/`GL` (or `GJ`/`GL` Accounts Receivable for consignment) **only when `p_invoice_type = 'SI'`**. (`NSI` totals remain tracked in Business Records for Owner/Bookkeeper review and optional summary posting.)
```dart
await client.rpc('create_sale', params: {
  'p_sale_date': '2026-11-20',
  'p_invoice_type': 'NSI',               // SI | NSI
  'p_fulfillment_type': 'pickup',        // pickup | delivery
  'p_delivery_fee': 0.0,                 // recorded as store income
  'p_is_consignment': false,
  'p_consignment_client_id': null,       // required UUID when p_is_consignment = true
  'p_items': [
    {
      'rice_variety_id': riceVarietyId,
      'qty_input': 1,
      'unit': 'SACK',                    // SACK | KG
      'applied_price_per_kg': 52.0,      // omit or match guide price for staff
    },
  ],
  'p_payments': [
    {'method': 'cash', 'amount': 1000.0, 'reference_no': null},
    {'method': 'gcash', 'amount': 300.0, 'reference_no': 'GCASH-123456'},
  ], // pass [] for unpaid consignment
  'p_notes': null,
});
// Returns: UUID (new sales.id)
```

### 3. `void_sale` *(Manager / Admin)*
Marks sale + payments `voided`, restores exact kg back to original FIFO `stock_batches`, saves immutable snapshot in `void_audit_logs`, and posts reversing entries in `GJ` + `GL`.
```dart
await client.rpc('void_sale', params: {
  'p_sale_id': saleId,
  'p_reason': 'Customer cancelled order before release',
});
```

### 4. `record_consignment_payment` *(Staff / Manager / Admin)*
Logs partial or full payment for an active consignment sale, updates `sales.amount_paid` & `payment_status` (`partial` | `paid`), and posts `CRJ` + `GL`.
```dart
await client.rpc('record_consignment_payment', params: {
  'p_sale_id': consignmentSaleId,
  'p_payment_date': '2026-11-22',
  'p_method': 'gcash',                   // cash | gcash | bank_transfer
  'p_amount': 2500.0,
  'p_reference_no': 'GCASH-998877',
  'p_notes': 'Weekly Sunday collection',
});
// Returns: UUID (new sale_payments.id)
```

### 5. `record_expense` *(Staff / Manager / Admin; `PERSONAL_WITHDRAWAL` Admin-only)*
Logs an operating expense (auto-links `PERSONAL_WITHDRAWAL` to `capital_entries`) and posts `CDJ` + `GL`.
```dart
await client.rpc('record_expense', params: {
  'p_expense_date': '2026-11-20',
  'p_invoice_no': 'OR-4410',
  'p_category': 'OPEX_FUEL',
  'p_description': 'Fuel for motorcycle delivery',
  'p_payment_method': 'cash',
  'p_amount': 250.0,
  'p_reference_no': null,
  'p_notes': null,
});
// Returns: UUID (new expenses.id)
```

### 6. `void_expense` *(Manager / Admin; `PERSONAL_WITHDRAWAL` Admin-only; blocks direct `COGS` void)*
Marks expense `voided`, writes immutable `void_audit_logs` snapshot, and posts `GJ` + `GL` reversal.
```dart
await client.rpc('void_expense', params: {
  'p_expense_id': expenseId,
  'p_reason': 'Duplicate fuel receipt entry',
});
```

---

## 5. Dart Service Wrapper
Frontend screens should import `lib/services/ejbl_backend_service.dart` instead of writing raw Supabase queries directly inside widgets.
