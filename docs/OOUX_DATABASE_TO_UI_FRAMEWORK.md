# EJBL Bigasan — Object-Oriented UX (OOUX) Database-to-UI Framework

**Purpose:** Guarantees 1-to-1 alignment between EJBL's verified Supabase PostgreSQL schema (`001`–`003`) and the Flutter & Dart UI (**Android + Web PWA**, online-only).  
**Visual Map:** [ooux_db_to_ui_map.png](./diagrams/ooux_db_to_ui_map.png)  
**Interactive Clickable Explorer:** Open `docs/ooux_interactive_prototype.html` in Chrome/Edge to test every role (`Staff`, `Manager`, `Admin`), device mode (`Android` / `Web PWA`), and live DB/RPC Inspector.

---

## 1. Core OOUX Rule: Every Database Relationship Dictates a UI Pattern

| Relationship Type | Database Example | Mandatory UI/UX Pattern |
| :--- | :--- | :--- |
| **1 : N (Parent → Children)** | `rice_varieties` → `stock_batches` | Parent summary card; tapping opens child list drawer ordered logically (FIFO oldest-first). |
| **1 : N (Order → Lines/Payments)** | `sales` → `sale_items`, `sale_payments` | Single Transaction Detail sheet with stacked sections (`Items`, `Payments`, `FIFO Cost` for Mgr/Admin). |
| **1 : 1 (Atomic Auto-Link)** | `stock_batches.expense_id` ↔ `expenses.id` | Bidirectional clickable pill chip (`"Auto-linked from Restock"` / `"View COGS Expense"`); blocks direct COGS voiding with explanation. |
| **1 : 1 (Owner Withdrawal Link)** | `capital_entries.linked_expense_id` ↔ `expenses.id` | Recording `PERSONAL_WITHDRAWAL` (Admin only) automatically mirrors in `Capital` tab with linked reference chip. |
| **Immutable Audit Snapshot** | `sales`/`expenses` → `void_audit_logs` | No Delete icon anywhere. Manager/Admin tap `Void` → mandatory Reason sheet → original row gets `VOIDED` badge; full frozen `JSONB` snapshot appears in Owner's Audit Timeline. |
| **Conditional Ledger Rule** | `sales.invoice_type` (`SI` vs `NSI`) → `bir_ledger_entries` | `SI` sales display a green `"Posted to BIR"` badge; `NSI` sales display a neutral `"Cashbook Only"` badge so there is zero confusion about BIR scope. |

---

## 2. Complete 1-to-1 Mapping (All 14 Tables + 2 Views + 6 RPCs)

| # | DB Table / View | Primary UI Object & Screen | Foreign-Key Drill-Downs / Links | Write Trigger (RPC / Action) | Role Visibility & Locks (RLS) |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 1 | `profiles` | User Profile Badge (App Bar / Login Gate) | `1:1` to `auth.users` | Admin user management | Self read; Admin full. Controls visible tabs & locks. |
| 2 | `rice_varieties` | **Rice Chips** (Log In) & **Price Guide** sub-tab (Inventory) | `1:N` → `stock_batches`, `sale_items` | Manager/Admin edit prices & `ordering_point_kg` | All view; Staff locked; Manager/Admin edit. |
| 3 | `v_inventory_summary` *(View)* | **Stock Cards** (Inventory Tab) + Low-Stock KPI Card | Aggregates `rice_varieties` + active `stock_batches` | Read-only (`security_invoker`) | All view. Red `LOW STOCK` pill when `<= ordering_point_kg`. |
| 4 | `stock_batches` | **FIFO Batch Drawer** (tap any Rice Card) | `N:1` → `rice_varieties`, `suppliers`; `1:1` → `expenses` | **`receive_stock()`** via `+ Receive Stock` sheet | All view; Manager/Admin receive stock (no hard delete). |
| 5 | `suppliers` | Supplier picker dropdown (Receive Stock sheet) & Settings list | `1:N` → `stock_batches` | Manager/Admin CRUD | All read (for dropdowns); Manager/Admin edit. Internal table only. |
| 6 | `consignment_clients` | **B2B Client Cards** (Consignment Tab: `GA-RA-HE`, `CARIBBEAN GRILL`) | `1:N` → `sales` (`is_consignment = true`) | Manager/Admin CRUD | All read; Manager/Admin edit. Internal table only. |
| 7 | `sales` | **Log In Checkout** & **Transaction Feed Cards** | `1:N` → `sale_items`, `sale_payments`; `N:1` → `consignment_clients` | **`create_sale()`**, **`void_sale()`** | Staff: insert + view own; Manager/Admin: view all + edit/void. |
| 8 | `sale_items` | Cart rows (Log In) & Items section (Sale Detail Drawer) | `N:1` → `sales`, `rice_varieties`; `1:N` → `sale_fifo_allocations` | Created inside `create_sale()` | Price field locked for Staff (`price_overridden` blocked server-side). |
| 9 | `sale_fifo_allocations` | **FIFO Cost Breakdown** accordion inside Sale Detail Drawer | `N:1` → `sale_items`, `stock_batches` | Auto-created in `create_sale()`; restored in `void_sale()` | **Hidden from Staff** (RLS: Manager & Admin only). Shows exact batch `puhunan`. |
| 10 | `sale_payments` | **Payment Sheet** (Exact/GCash/Split) & **Collect Consignment** sheet | `N:1` → `sales` | `create_sale()` & **`record_consignment_payment()`** | Staff: insert + own; Manager/Admin: view all. Supports split Cash + GCash + Ref #. |
| 11 | `v_cashbook_entries` *(View)* | **Cashbook (In)** sub-tab in Business Records | Joins active `sale_payments` + `sales` + `consignment_clients` | Read-only (`security_invoker`) | Staff: no tab; Manager: **View-Only**; Admin: full view. Excludes unpaid consignments until collected. |
| 12 | `expenses` | **Log Out Form** & **Expenses (Out)** sub-tab in Business Records | `1:1` ← `stock_batches` (`COGS`), `1:1` → `capital_entries` (`DRAW`) | **`record_expense()`**, **`void_expense()`** | Staff: insert non-withdrawal + own; Manager: view all + void non-COGS; Admin: full + `PERSONAL_WITHDRAWAL`. |
| 13 | `daily_cash_reconciliations` | **EOD Cash Box Check** sub-tab in Business Records | Summarizes daily expected Cash/GCash vs counted | Admin save reconciliation | Staff: denied; Manager: **View-Only**; Admin: create/update. Auto-tags `Balanced` / `SOBRA` / `SHORT`. |
| 14 | `capital_entries` | **Capital** sub-tab inside BIR & More | `1:1` ← `expenses` (for `DRAW-xxx` withdrawals) | Admin direct entry + auto from `record_expense('PERSONAL_WITHDRAWAL')` | **Admin Only** (RLS blocks Staff & Manager). |
| 15 | `void_audit_logs` | **Void Audit Timeline** screen (inside BIR & More) | Stores frozen `original_snapshot` (JSONB) of voided `sales`/`expenses` | Append-only via `void_sale()` / `void_expense()` | **Immutable** (no edit/delete for anyone). Admin sees all; Manager sees own voids. |
| 16 | `bir_ledger_entries` | **4 BIR Books** (`GL`, `CRJ`, `CDJ`, `GJ`) inside BIR & More | `source_type` + `source_id` chip links back to originating `SI` sale/payment/expense/capital/void | Auto-posted (`SI` sales, expenses, capital, reversals) + Admin **`+ Manual Entry`** / Edit + **Export PDF** | **Admin Only** (RLS blocks Staff & Manager). Columns adaptable once Bookkeeper confirms BIR layouts. |

---

## 3. Constraint-to-UI Validation Mapping (Zero Invalid Submissions)
Every PostgreSQL `CHECK` constraint and RPC guard has a matching front-end UX rule:
1. `remaining_kg >= 0` & FIFO stock check → Disable/warn on Rice Chips with `0 kg`; display live max available kg before submit.
2. `price_overridden` Staff guard → Render unit price as read-only text with lock icon for Staff; show editable input + `"Overridden"` amber tag for Manager/Admin.
3. `chk_consignment_client` → Switching payment mode to **Consignment** requires picking a client from `consignment_clients` before enabling `Save Sale`.
4. Non-consignment full-payment check → Payment Sheet disables `Confirm` until `cash + online >= total_amount` (showing live remaining balance in Split Payment mode).
5. `void_audit_logs.reason` non-empty check → Void modal disables `Confirm Void` until a non-empty reason is entered.
6. Direct `COGS` void block → COGS expense rows show a locked `"Restock COGS — Adjust via Inventory"` badge instead of a Void button.
7. Online-only architecture → Display a clear top connectivity banner (`"Online connection required"`) with a `Retry` button on network failure; never fail silently.
