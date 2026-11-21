# EJBL Local Setup Guide (Windows: Flutter + Supabase)

Follow these steps once on your Windows machine. Git (`2.54.0`) and VS Code are already installed.

---

## Step 1: Install Flutter SDK (Windows)

### Option A — Fastest (via VS Code, recommended)
1. Open **VS Code** → Extensions (`Ctrl+Shift+X`) → install the official **Flutter** extension (by Dart Code).
2. Press `Ctrl+Shift+P` → type `Flutter: New Project` → click **Download SDK** → pick `C:\dev\flutter` (avoid `Program Files` or paths with spaces).
3. Restart VS Code and any open terminals.

### Option B — Manual Zip
1. Download the stable Windows Flutter SDK zip from https://docs.flutter.dev/get-started/install/windows/mobile.
2. Extract to `C:\dev\flutter` (so `C:\dev\flutter\bin\flutter.bat` exists).
3. Add `C:\dev\flutter\bin` to your Windows **User `Path`** environment variable.
4. Open a **new** PowerShell terminal and verify:
   ```powershell
   flutter doctor
   ```

### Target Platforms
- **Web (PWA) — ready immediately:** Uses Chrome or Edge (`flutter run -d chrome`). You can start building and testing UI + Supabase right away without waiting for Android Studio.
- **Android (APK/AAB) — required for Android builds:**
  1. Install **Android Studio** (https://developer.android.com/studio).
  2. Open **SDK Manager → SDK Tools** and install **Android SDK Command-line Tools (latest)**.
  3. Run:
     ```powershell
     flutter doctor --android-licenses
     flutter doctor
     ```

---

## Step 2: Create & Initialize Supabase Project

1. Sign in at https://supabase.com and click **New Project**.
   - **Name:** `ejbl-bigasan`
   - **Region:** **Southeast Asia (Singapore)** *(lowest latency for the Philippines)*
   - Save your database password safely in a password manager (never commit it to Git or paste it in chat).
2. Open **SQL Editor → New Query**:
   - Paste and run `supabase/migrations/001_initial_schema.sql`.
   - Open a second query, paste and run `supabase/seed.sql`.
3. Create 3 test accounts in **Authentication → Users → Add User** (enable **Auto Confirm User**):
   - e.g. `admin@ejbl.local`, `manager@ejbl.local`, `staff@ejbl.local`
4. Copy each user's UUID from **Authentication → Users** and insert their roles in **SQL Editor**:
   ```sql
   INSERT INTO public.profiles (id, full_name, role) VALUES
     ('<ADMIN_UUID>',   'EJBL Owner',   'admin'),
     ('<MANAGER_UUID>', 'Store Manager', 'manager'),
     ('<STAFF_UUID>',   'Store Staff',   'staff');
   ```
5. In **Project Settings → API**, note ONLY:
   - **Project URL** (`SUPABASE_URL`)
   - **anon / publishable public key** (`SUPABASE_ANON_KEY`)
   - **NEVER** copy or put the `service_role` / secret key in the Flutter app.

---

## Step 3: Running the Flutter App (Once Scaffolded in `app/`)

Pass Supabase config via `--dart-define` (never hardcode keys in Dart files):

```powershell
# Web (PWA) in Chrome
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_YOUR_KEY

# Android device / emulator
flutter run -d android --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_YOUR_KEY
```
