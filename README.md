# EJBL Bigasan — Internal Management System (PUP DIT Capstone — Group 1)

**Working Title:** *EJBL: An Integrated Sales, Expense Tracking, Basic Bookkeeping, and FIFO Inventory Management System for EJBL Bigasan*  
**Stack:** Flutter & Dart (**Android + Web PWA**, online-only) • Supabase (PostgreSQL, Auth, RLS, Atomic SQL RPCs)

---

## Project Structure

```text
ejbl-capstone/
├── app/                          # Flutter & Dart app (Android + Web PWA)
│   ├── lib/
│   │   ├── core/supabase_config.dart
│   │   ├── models/ejbl_models.dart
│   │   ├── services/ejbl_backend_service.dart  # Wraps all 6 Supabase RPCs & reads
│   │   └── main.dart
│   └── env.example.json          # Copy to env.json locally (gitignored)
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_security_invoker_views.sql
│   │   └── 003_bir_si_only_posting.sql
│   ├── seed.sql                  # 23 rice varieties + 2 consignment clients
│   └── tests/
│       └── 001_verify_rpcs_and_rls.sql
└── docs/
    ├── BACKEND_API_CONTRACT.md   # Frontend devs: tables, views, RLS & 6 RPC contracts
    ├── UI_UX_USER_FLOW.md        # UI/UX designer: screen-by-screen specs
    ├── SETUP_GUIDE.md            # Windows Flutter + Supabase setup
    └── diagrams/
        ├── ui_ux_screen_flow.png # Drop into Figma / FigJam
        └── fig1..fig6_*.png      # Chapter 3 capstone figures
```

---

## Quick Start for Teammates

1. **Install Flutter SDK** (stable 3.x) and verify `flutter doctor`.
2. **Clone this repository** and install Dart packages:
   ```powershell
   cd app
   flutter pub get
   ```
3. **Create your local `app/env.json`** (gitignored — **never commit this file**):
   ```powershell
   copy env.example.json env.json
   ```
   Ask the Backend Lead (Earl) for the shared **Supabase Project URL** and **Publishable key (`sb_publishable_...`)** and paste them into `app/env.json`.  
   > **Security rule:** Never put the Supabase `Secret` (`sb_secret_` / `service_role`) key or database password in `env.json` or any code file.
4. **Run the app locally:**
   ```powershell
   # Web (PWA) in Chrome
   flutter run -d chrome --dart-define-from-file=env.json

   # Android emulator or USB device
   flutter run -d android --dart-define-from-file=env.json
   ```

---

## Team Collaboration Rules (Git & GitHub)
- **Do not push directly to `main`** once collaboration starts — create a branch per task:
  - Example: `git checkout -b feat/ui-log-screen` or `git checkout -b feat/inventory-cards`
- Run `flutter analyze` and `flutter test` before opening a Pull Request.
- Frontend screens should call **`lib/services/ejbl_backend_service.dart`** rather than writing raw Supabase queries inside widgets. See `docs/BACKEND_API_CONTRACT.md` for all RPC parameters.
- All database schema or RLS changes must be added as numbered SQL migrations in `supabase/migrations/`.
