# EJBL System Architecture & Database Design (Flutter + Supabase)

**Status:** Planned technical design (not yet deployed or tested against a live Supabase project).  
**Stack:** Flutter & Dart (**Android & Web / PWA**, online-only; native iOS excluded) + Supabase (PostgreSQL, Auth, Row Level Security, SQL RPC Functions).

---

## 1. System Architecture Overview

```mermaid
flowchart LR
  subgraph InternalUsers["Internal Users (Android & Web / PWA)"]
    Staff["Employee / Staff\n(Log In/Out, View Inventory)"]
    Manager["Manager\n(Log CRUD/Void, Price Override,\nFull Inventory, View Business Records)"]
    Admin["Admin / Owner\n(Full Access, Void Audit,\nCapital, 4 BIR Books + PDF)"]
  end

  subgraph FlutterApp["Flutter & Dart App (Android + Web PWA, Online-Only)"]
    UI["Role-Guarded Screens (go_router)\nLog | Inventory | Consignment |\nBusiness Records | Void Audit | BIR Books"]
    State["State & Repositories (flutter_riverpod)"]
    PDF["On-Device PDF Generator (pdf + printing)\n4 BIR Books Export Only"]
  end

  subgraph Supabase["Supabase Cloud Backend (HTTPS / TLS)"]
    Auth["Supabase Auth (Email/Password + JWT)"]
    RLS["PostgreSQL Row Level Security\n(current_user_role())"]
    RPC["Atomic SQL RPC Functions\nreceive_stock() | create_sale() |\nrecord_consignment_payment() | void_sale()"]
    DB[("PostgreSQL Database\n14 Tables + 2 Auto Views")]
  end

  Staff --> UI
  Manager --> UI
  Admin --> UI
  UI --> State
  Admin -.-> PDF
  UI --> PDF
  State -- "HTTPS + JWT (anon key only)" --> Auth
  State -- "HTTPS + JWT" --> RLS
  State -- "HTTPS + JWT" --> RPC
  Auth --> RLS
  RLS --> DB
  RPC --> DB
```

---

## 2. Entity Relationship Diagram (Core Tables)

```mermaid
erDiagram
  profiles ||--o{ sales : creates
  profiles ||--o{ expenses : creates
  profiles ||--o{ stock_batches : receives
  profiles ||--o{ void_audit_logs : voids
  profiles ||--o{ bir_ledger_entries : posts

  rice_varieties ||--o{ stock_batches : stocked_in
  rice_varieties ||--o{ sale_items : sold_as
  suppliers ||--o{ stock_batches : supplies
  expenses |o--o| stock_batches : auto_cogs_link

  consignment_clients ||--o{ sales : consignment_for
  sales ||--|{ sale_items : contains
  sales ||--o{ sale_payments : paid_by
  sale_items ||--|{ sale_fifo_allocations : deducts_from
  stock_batches ||--o{ sale_fifo_allocations : allocated_to

  expenses |o--o| capital_entries : withdrawal_link
```

---

## 3. Flutter Project Structure (Layered, Feature-First)

```text
app/lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/supabase_config.dart      # Env vars via --dart-define (never commit secrets)
│   ├── router/app_router.dart           # go_router with role-based route guards
│   ├── theme/app_theme.dart
│   └── utils/formatters.dart            # PHP currency, kg/sack helpers
├── features/
│   ├── auth/                            # Login, session provider, current_user_role
│   ├── log/                             # Log In (multi-item SI/NSI sales, split pay) & Log Out (expenses)
│   ├── inventory/                       # Stock summary, low-stock badge, FIFO batches, Receive Stock, Price Guide
│   ├── consignment/                     # B2B client accounts, unpaid/partial balances, record collection
│   ├── business_records/                # Auto Cashbook, Expenses, Daily Cash Box reconciliation (sobra/short)
│   ├── void_audit/                      # Immutable voided/cancelled log viewer for Owner/Admin
│   └── bir_books/                       # GL, CRJ, CDJ, GJ tabs + Capital + Owner manual edits + PDF export
```

---

## 4. Key Engineering Safeguards
1. **Server-Side RBAC (Never UI-Only):** Supabase RLS enforces `staff`, `manager`, and `admin` permissions at the database layer. Guide-price overrides are checked inside `create_sale()`.
2. **Atomic FIFO & Concurrency Safety:** `create_sale()` locks eligible `stock_batches` rows (`FOR UPDATE`) ordered by `received_date ASC, created_at ASC`, splits deductions across batches when needed, records exact `sale_fifo_allocations`, updates `sales`, inserts `sale_payments`, and posts to `bir_ledger_entries` inside one PostgreSQL transaction.
3. **Lossless Void / Cancel:** `void_sale()` never deletes rows—it marks the sale/payments `voided`, restores exact kilograms back to the exact original `stock_batches` via `sale_fifo_allocations`, appends a frozen JSONB snapshot to `void_audit_logs`, and posts reversing entries in `bir_ledger_entries`.
4. **Pending Bookkeeper Confirmation:** `bir_ledger_entries` uses a clean normalized ledger schema (`book_type`, `entry_date`, `reference_no`, `particulars`, `account_code`, `account_title`, `debit`, `credit`) so PDF column layouts can be adjusted in Flutter without rewriting the core transaction engine once the bookkeeper/accountant confirms exact BIR columns.
