# EJBL Capstone Project Workspace (`AGENTS.md`)

Prepared for **Earl James Benagua**, Diploma in Information Technology (DIT), Polytechnic University of the Philippines (PUP).  
**Project:** EJBL System for EJBL Bigasan  
**Last Updated:** November 20, 2026

> **Evidence Notice:** Project facts below are user-provided context, not proof that a feature is built, tested, deployed, or that a research activity has occurred. Content from `CAPSTONE_SAMPLE_TEMPLATE.docx` is a structural reference only and must never be copied as EJBL content.

---

## 1. Project Context

### 1.1 Identity & People
- **Student:** Earl James Benagua, Diploma in Information Technology (Section 3, Group 1), Polytechnic University of the Philippines (Philippines).
- **Group Members (from Google Doc):** John Rey Castro Sobrepeña, Earl James Benagua, Jersen Nyco Menancio (Nyco Menancio), Nikki Alversado, Yancey Nicole Handang.
- **Research Adviser:** Jonnalyn B. Apsay.
- **Group Role:** Earl owns the **Project Design and Solution** section of the group proposal.
- **Proposal / Capstone Title:** *"EJBL: An Integrated Sales, Expense Tracking, Basic Bookkeeping, and FIFO Inventory Management System for EJBL Bigasan"*
- **Active Google Doc:** ID `1Ptd4YiOiBRoI6srmeEL2dCtCqCMRYH0pQFiem5eJqTw`
  - Tab `t.0`: `Chapter 1 - 3`
  - Tab `t.dsxlc5gmf836`: `Project Proposal`
- **Research Locale:** EJBL Bigasan, Blk 9 Lot 1, Phase 5E, Verdantpoint, San Isidro, Rodriguez, Rizal, Philippines, 1860.
- **Current Staffing (confirmed Nov 20, 2026):** Currently operated primarily as a one-person operation (the owner), assisted by one cousin who helps with deliveries. The 3-role RBAC (Employee/Staff, Manager, Admin/Owner) is intentionally designed to support current delegation and future store expansion.
- **Confirmed Operational Pain Points (Nov 20, 2026):** Although EJBL Bigasan's Excel workbook already uses some formulas/functions for pricing and totals, the owner must still manually encode transactions across multiple separate Excel sheets. The primary operational problem is the lack of integrated bookkeeping—forcing the owner to manually transcribe financial records into four physical BIR ledger books (General Ledger, Cash Receipts Journal, Cash Disbursements Journal, General Journal).
- **Confirmed SDLC (Nov 20, 2026):** **Agile (Iterative-Incremental / Scrum)**.
- **Planned Evaluators & Instruments (Provisional as of Nov 20, 2026):** **ISO/IEC 25010:2011** (8 characteristics, matching the PUP doc) + **System Usability Scale (SUS)**. Planned evaluators include internal store user(s), tentatively 1 IT expert, and tentatively 1 bookkeeper (groupmate's relative, who may also consult an accountant colleague to verify the 4 BIR book formats).
- **Scope:** Internal-use mobile application for **EJBL Bigasan** (a rice retail business).
- **Separate Account Projects (Do Not Mix):** ECOSAFE, ILIGTAS, iPuntod, ParishPark, TRUBS, BarberOS, Jarvis assistant, classroom n8n workflow.

### 1.2 Confirmed Business & System Decisions (as of Nov 20, 2026)
- **Target Platforms:** **Android and Web (Progressive Web App / PWA)** — native iOS App Store builds are excluded from scope (iOS users can access via Web/PWA if needed).
- **Client Stack:** **Flutter & Dart** (updated from React Native on Nov 20, 2026).
- **Backend / Database:** **Supabase** (confirmed; PostgreSQL, Auth, Row Level Security, SQL RPC transactions).
- **Connectivity:** **Online-only** for now (offline support deferred/not active).
- **Internal-Only Context Diagram:** No B2B customers, suppliers, or CPA/bookkeeper as external system actors. Suppliers and customers (including consignment clients) exist only as internal tables/sections. The CPA/bookkeeper only evaluates the four BIR books and their format externally.
- **Four Integrated Modules:**
  1. **Log:** Daily transaction entry screen. **Log In** = sales (SI with receipt / NSI without receipt, multi-item invoices, walk-in vs. delivery, delivery fee as store income, cash / online [GCash, BPI, InstaPay] / split payments with ref nos.). **Log Out** = expenses. Automatically populates **Business Records**.
  2. **Business Records:** Cashbook (In: cash box, GCash/online, total money, overage/`sobra`, shortage/`short`, consignment tracking) and Expenses (Out: OPEX, COGS, permits, equipment, office supplies, personal withdrawals). Auto-populated from Log.
  3. **Inventory:** FIFO batch-costed rice inventory (beginning, received, issued, ending balance, unit cost/`puhunan` per kg, sacks, ordering point) plus Rice Name/Code/Price Guide (tiered walk-in/delivery wholesale & retail pricing). Linked to Log. Receiving stock (COGS) automatically creates the corresponding Expense / Cash Disbursement record.
  4. **BIR Books & Capital:** General Ledger, Cash Receipt Journal, Cash Disbursement Journal, and General Journal, plus Capital (opening capital, owner's contributions `OWN-xxx`, personal withdrawals `DRAW-xxx`). Auto-populated from **receipted (`SI`) sales**, expenses, and capital; **`NSI` (non-receipted) sales** remain tracked in Log, FIFO Inventory, and Business Records (Cashbook) rather than auto-posting to BIR books, so the Owner/Bookkeeper can review or post consolidated summary entries if required by BIR rules. Owner/Admin can edit/post manual entries and export the 4 BIR books to PDF. Exact BIR column formats are **pending CPA/bookkeeper confirmation**.
- **Pricing Rules:** Tiered price guide (1–2 sacks vs. 3+ sacks, Walk-in vs. Delivery). Only **Manager** and **Admin** may override guide prices during a sale (Staff cannot).
- **Consignment (B2B Credit):** No credit to individual walk-in customers; B2B consignment contracts (e.g., GA-RA-HE, Caribbean Grill) allow full or partial payments later. Stock deducts from **Inventory** immediately on delivery; **Cashbook / Cash Receipt Journal** records cash inflow only when payment is collected.
- **Invoice Numbering (confirmed Nov 20, 2026):**
  - `NSI` (no receipt, when customer declines a receipt): **auto-generated** continuously.
  - `SI` (with physical receipt): **continuous series** starting from 1 (matching the physical receipt booklet).
- **Void / Cancel Audit Trail (confirmed Nov 20, 2026):** Managers **void/cancel** Log records instead of permanently deleting them; every voided/cancelled record is stored and visible to the Admin/Owner for auditability.
- **PDF Export:** Scoped to the **4 BIR Books only** for now.

### 1.3 User Roles & Permissions
| Role | Permissions |
| :--- | :--- |
| **Employee / Staff** | Add and save records in Log; view Inventory. Cannot override guide prices. No access to Business Records, Capital, or BIR Books. |
| **Manager** | Add, edit, save, and **void/cancel** records in Log (voided records are retained for Owner review); full Inventory access; can override guide prices; **view-only** access to Business Records. No access to edit BIR Books or Capital. |
| **Admin / Owner** | Full access to everything, including Business Records, Capital, viewing all voided/cancelled records, editing/posting manual entries in the 4 BIR Books, and PDF export (BIR Books). |

### 1.4 Reference Files (`references/`)
- `CAPSTONE_SAMPLE_TEMPLATE.docx` — Primary PUP structural reference for Chapters 1–3 (headings, order, terminology). Never copy its ITECH LMS sample content, names, or references.
- `EJBL_BIGASAN.xlsx` — Business's existing 5-sheet workbook (`SALES`, `CASHBOOK`, `INVENTORY`, `EXPENSES`, `CAPITAL`). See `references/README.md`.

### 1.5 Current Progress & Open Items (as of Nov 21, 2026)
- **Completed & Verified:**
  - Google Doc ([Chapter 1 - 3](https://docs.google.com/document/d/1Ptd4YiOiBRoI6srmeEL2dCtCqCMRYH0pQFiem5eJqTw/edit?tab=t.0) + [Project Proposal](https://docs.google.com/document/d/1Ptd4YiOiBRoI6srmeEL2dCtCqCMRYH0pQFiem5eJqTw/edit?tab=t.dsxlc5gmf836)) updated and synced to **Flutter & Dart (Android & Web PWA, online-only)**, **SI-only BIR auto-posting**, 19 real verified RRLs, borderless 3-column PUP TOC, and **all 6 Chapter 3 figures embedded** (`Figures 1–6`).
  - Supabase backend live & verified: `001_initial_schema.sql`, `002_security_invoker_views.sql`, `003_bir_si_only_posting.sql`, `seed.sql` (23 rice varieties + 2 consignment clients), 3 test roles (`admin`, `manager`, `staff`), and **6/6 live RPC & RLS checks passed** via rollback test `supabase/tests/001_verify_rpcs_and_rls.sql`.
  - Flutter 3.50.1 app scaffolded in `app/` (`android` + `web` PWA) with `EjblBackendService`, `flutter analyze` (0 issues), `flutter test` (3/3 passed), live Chrome login verified, and team handoff files ready (`docs/BACKEND_API_CONTRACT.md`, `docs/UI_UX_USER_FLOW.md`, `docs/diagrams/ui_ux_screen_flow.png`).
- **Next Up / Open Items:**
  - Push workspace to GitHub (keeping `app/env.json` ignored) for frontend & UI/UX teammates.
  - Exact BIR column formats from the bookkeeper/accountant for the 4 BIR Books (pending).
  - Confirmation from PUP adviser (**Jonnalyn B. Apsay**) on `UREC 10 Ethics CIA` and final evaluator counts.
  - Build Sprint 1–4 Flutter UI screens once UI/UX designer reviews `ui_ux_screen_flow.png`.

### 1.6 Output Preferences
- Earl prefers concise, direct communication, simple code examples over verbose explanations, and plain text output over heavily formatted documents unless a deliverable is specifically required.
- For the group proposal: shorter proposal in plain text, headings not needed, one consolidated Project Design and Solution text.

---

## 2. Mandatory Mode Router

This workspace separates two distinct specialist roles via workspace skills. **Do not blend them.** At the start of each task, route to the appropriate skill:

1. **RESEARCH MODE** -> Read and follow `.agents/skills/pup-capstone-researcher/SKILL.md` (Part A) when the user asks for:
   - Capstone or thesis research writing, planning, or revision (including the Project Design and Solution proposal)
   - Chapter 1, Chapter 2, or Chapter 3
   - Introduction, background of the study, theoretical or conceptual framework, SOP, objectives, scope, significance, definition of terms
   - Review of Related Literature and Studies (RRL/RRS), research gaps, synthesis, citations, references, APA formatting
   - Research design, respondents, sampling, research instruments, data gathering, statistical treatment, ethical considerations
   - Academic evaluation of a proposed system or checking a manuscript against the PUP sample template
   - *Do not apply software implementation templates unless separately requested.*

2. **SOFTWARE ENGINEERING MODE** -> Read and follow `.agents/skills/ejbl-software-engineer/SKILL.md` (Part B) when the user asks for:
   - Building or modifying web, mobile, desktop, or PWA applications
   - Programming, coding, architecture, system design, database schema, or technology selection
   - React, React Native, Expo, Flutter, Kotlin, Swift, Node.js, Express.js, Supabase, PostgreSQL, MySQL, APIs, integrations
   - Debugging, code review, performance, auth, RLS, security, testing, deployment, CI/CD, Android/iOS builds
   - *Do not impose PUP chapter structures, APA citations, or research methodology sections on ordinary engineering work.*

3. **BOTH MODES (Integrated Check — Part C)** -> Only when the user explicitly asks to compare, align, or deliver both research documentation and software implementation together:
   - Keep academic research and engineering deliverables in separate headings or phases.
   - Describe what the study proposes/documents separately from what actual code/schema/tests show.
   - Never silently rewrite research claims to match code or alter code to match unapproved research statements.
   - Identify discrepancies explicitly and ask which approved direction controls.

4. **Ambiguous Requests:** If choosing the wrong mode would materially change the answer, ask one concise clarifying question. Otherwise pick the obvious mode and proceed.

---

## 3. Strict Separation & Conflict-Prevention Rules

These rules override any overlapping wording in either skill:
1. **Separate objectives:** Research Mode produces academically defensible documentation; Engineering Mode produces technically sound software. Never treat a working app as proof of research findings/user evaluations, and never treat a proposal/Chapter 3 plan as proof that a feature is built.
2. **Separate evidence standards:** Research claims require traceable academic/institutional sources. Engineering claims about EJBL require evidence from files, config, schema, logs, tests, or observed behavior. Never fabricate either.
3. **Shared project facts:** Reuse titles, intended users, roles, and requirements only as user-provided context—never as proof of completion.
4. **Mode-specific term meanings:**
   - *Methodology*: research design & data gathering (Research) vs. dev process & workflow (Engineering).
   - *Evaluation*: research instruments & respondents (Research) vs. software tests & QA (Engineering).
   - *System architecture*: documented proposed design (Research) vs. actual/planned technical architecture (Engineering).
   - *Results/findings*: collected research evidence (Research) vs. observed test/build/runtime outcomes (Engineering).
5. **No automatic blending:** Never append code advice to research writing or PUP/APA sections to engineering tasks unless requested.
6. **Label feature status separately:** Planned, implemented, tested, and released features must always be clearly distinguished.

---

## 4. Global Rules (Both Modes)
1. Be accurate, transparent, and clear.
2. Never invent facts, evidence, sources, test outcomes, respondent data, or project details.
3. Ask focused questions when essential information is missing.
4. Clearly label assumptions, estimates, proposals, and unverified information.
5. Preserve the user's intended meaning and existing work.
6. Explain important limitations and trade-offs.
7. Do not claim an action was completed unless it was actually completed and verified.
8. Protect confidential information, credentials, and personal data.
9. Follow the user's confirmed institutional, project, or technical requirements when applicable.
10. Keep outputs organized and appropriate to the active mode.
