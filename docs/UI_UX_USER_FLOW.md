# EJBL Bigasan — UI/UX Designer Handoff & Screen Flow Guide

**Target Platforms:** Android (Mobile) + Web (Progressive Web App / PWA) built with **Flutter & Dart** (online-only with Supabase).  
**Visual Flowchart:** `docs/diagrams/ui_ux_screen_flow.png` (ready to drop directly into Figma / FigJam).  
**Backend Contract:** `docs/BACKEND_API_CONTRACT.md`

---

## 1. Core Design Principle: Task-First Cards, Not Spreadsheet Grids
Do **not** recreate EJBL Bigasan's Excel sheets as horizontal-scrolling grids on mobile.
- **Android (Phone):** Big tap targets (`min 48x48 dp`), bottom navigation tabs, rice variety chips, bottom sheets/modals for payments and voids.
- **Web (PWA on Laptop/Tablet):** Responsive `NavigationRail` on the left + wider data tables *only* on screens where owners/bookkeepers scan rows (**Business Records** and **4 BIR Books**).

---

## 2. Role-Adaptive Navigation Shell

| Role | Visible Primary Tabs | Special Badges / Guards |
| :--- | :--- | :--- |
| **Employee / Staff** | `Log` \| `Inventory` | Prices locked in Log In; no `Receive Stock`, no `Void`, no `Business Records`, no `BIR`. |
| **Manager** | `Log` \| `Inventory` \| `Consignment` \| `Business Records` | Can override prices & void Log records (reason required); **View-Only banner** on Business Records; no `BIR`/`Capital`. |
| **Admin / Owner** | `Home` \| `Log` \| `Inventory` \| `Business Records` \| `BIR & More` | Full control, Void Audit Log review, Capital, Manual BIR entries/edits, BIR PDF export. |

---

## 3. Screen-by-Screen Designer Specs & Backend RPC Mapping

### Screen 1: Login (`auth`)
- **Fields:** Email, Password (show/hide toggle), `Sign In` button.
- **States:** Loading spinner on button; inline red error for invalid login or offline network.

### Screen 2: Home / Daily Pulse *(Admin & Manager)*
- **4 KPI Cards:** Today's Sales (Cash vs. GCash/Bank split), Today's Expenses, Total Unpaid Consignment, Low-Stock Varieties count (red badge when `<= ordering_point_kg`).
- **Quick Action Row:** `+ New Sale`, `+ Expense`, `+ Receive Stock`.

### Screen 3: Log (`Log In` / `Log Out` Segmented Toggle)
- **Log In (Quick Rice POS — `create_sale()`):**
  1. Tap **Rice Chips** (`CP`, `MC`, `PH`...) displaying live remaining sacks right on each chip.
  2. Pick **`SACK (25kg)`** or **`KG`** + stepper / decimal keypad (supports fractional kg like `6.8`).
  3. Toggle **`Pick Up`** vs **`Delivery`** → auto-fills tiered guide price (`1–2 sacks` walk-in = wholesale, delivery = retail; `3+ sacks` = wholesale). Delivery reveals optional **`Delivery Fee (₱)`** field (store income).
  4. **Price field:** Locked icon for `Staff`; editable with amber `"Overridden"` chip for `Manager`/`Admin`.
  5. Toggle **`SI (With Receipt)`** (continuous from 1; auto-posts to BIR Books) vs **`NSI (No Receipt)`** (auto-generated; tracked in Business Records & Inventory only — does not auto-post to BIR Books).
  6. Tap **`Proceed to Payment`** → **Payment Bottom Sheet**:
     - `Exact Cash`
     - `GCash / Bank` (requires Ref No.)
     - `Split Payment` (Cash + Online; auto-computes remaining balance)
     - `Consignment` (pick B2B client e.g., `GA-RA-HE` / `CARIBBEAN GRILL` → saves Unpaid, deducts FIFO stock immediately).
  7. Success snackbar displays the assigned `SI` or `NSI` number.
- **Log Out (Operating Expenses — `record_expense()`):**
  - Category chips (`Fuel`, `Office Supplies`, `Permit`, `Equipment`, `Marketing`, `Food Allowance`, `Personal Withdrawal` *[Admin only]*).
  - *Note to designer:* Show a small helper hint `"Restocking rice? Use Inventory -> Receive Stock so COGS & FIFO update automatically."`

### Screen 4: Inventory (`Stock Cards` | `Price Guide` Sub-tabs)
- **Stock Cards (`v_inventory_summary`):** Variety code badge, full name, color stock progress bar (kg + sacks), red `LOW STOCK` pill when `<= ordering_point_kg`.
- **Tap Card → FIFO Batches Drawer:** Lists active `stock_batches` oldest-first (`Date | Remaining kg | Puhunan ₱/kg`).
- **`+ Receive Stock` Sheet *(Manager/Admin)* (`receive_stock()`):** Variety, Supplier (optional), Qty (sacks or kg), Puhunan/kg, Payment Method, Supplier DR/Invoice #. Displays info banner: *"Automatically records a COGS expense and posts to CDJ/GL."*
- **Price Guide Sub-tab:** Read-only list for Staff; editable price fields & ordering points for Manager/Admin.

### Screen 5: Consignment *(Manager & Admin)*
- **Client Cards** (`GA-RA-HE`, `CARIBBEAN GRILL`): Payment schedule (`Every Sunday`), Total Unpaid Balance, list of Unpaid/Partial invoices.
- **`+ Collect Payment` Sheet (`record_consignment_payment()`):** Shows remaining balance, accepts partial or full amount, payment method + ref no., and confirms Cashbook & CRJ update immediately.

### Screen 6: Business Records *(Manager = View-Only | Admin = Full)*
- **Manager Banner:** Persistent subtle amber bar `"View-Only Access — Only Owner/Admin can reconcile Cash Box."`
- **Sub-tabs:**
  1. **Cashbook (In)** (`v_cashbook_entries`): Chronological collected payments (Cash vs. Online columns, Invoice #, Ref No., Delivery Fee).
  2. **Expenses (Out)** (`expenses`): Filterable by category (`COGS`, `OPEX`, `PERMIT`, `DRAW`).
  3. **EOD Cash Box Check** (`daily_cash_reconciliations`): Shows System Expected Cash & GCash side-by-side with Counted Cash Box & GCash inputs, immediately highlighting **`Balanced`**, **`SOBRA (+₱)`**, or **`SHORT (-₱)`**.

### Modal: Void / Cancel Transaction *(Manager & Admin)*
- Accessible from a transaction detail card on Log/Business Records (`void_sale()` / `void_expense()`).
- Requires non-empty **Reason** text field + red warning: *"Stock will be restored to original FIFO batches. This cancelled record will remain stored for Owner audit."*
- Direct `COGS` expenses show a disabled Void button with tooltip explaining FIFO protection.

### Screen 7: BIR Books, Capital & Void Audit *(Admin/Owner Only)*
- **Void Audit Log (`void_audit_logs`):** Chronological list showing Who voided, When, Record Type, Reason; tapping opens the frozen JSONB original transaction snapshot.
- **BIR Books & Capital (`bir_ledger_entries`, `capital_entries`):**
  - Top segmented tabs: `GL` | `CRJ` | `CDJ` | `GJ` | `Capital`.
  - Date range selector + clean accounting ledger layout (`Date | Ref # | Particulars | Account | Debit | Credit`) — exact column headings remain configurable pending bookkeeper confirmation.
  - **`+ Manual Entry`** / Edit button (Admin only) + **`Export PDF`** button (launches Flutter `printing` preview/download/share).

---

## 4. Universal UI States Checklist (Required on Every Screen)
1. **Loading:** Skeleton cards or centered progress indicator.
2. **Empty State:** Friendly icon + explanation + primary action button (e.g., *"No stock batches yet — tap Receive Stock"*).
3. **Offline / Network Error:** Online-only banner (`"No internet connection — EJBL requires an active connection"`) with a **`Retry`** button.
4. **Permission Locked:** Hide unauthorized tabs/buttons cleanly (and handle server RLS error messages gracefully if triggered).
5. **Confirmation & Feedback:** Show exact assigned `SI` / `NSI` number or updated balance in confirmation toasts.
