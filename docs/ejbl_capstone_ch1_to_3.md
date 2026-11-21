**EJBL: AN INTEGRATED SALES, EXPENSE TRACKING, BASIC BOOKKEEPING, AND FIFO INVENTORY MANAGEMENT SYSTEM FOR EJBL BIGASAN**

A Research/Capstone Project

Presented to the Faculty of the Institute of Technology

Polytechnic University of the Philippines

Sta. Mesa, Manila

In Partial Fulfillment of the Requirements for the

Diploma in Information Technology

by

**John Rey Castro Sobrepeña**

**Earl James Benagua**

**Nyco Menancio**

**Nikki Alversado**

**Yancey Nicole Handang**

Research Adviser: Jonnalyn B. Apsay

Academic Year 2026–2027

---

**TABLE OF CONTENTS**

| # | Section | Page |
| :---: | :--- | :---: |
|  |  | Page |
|  | Copyright Page | i |
|  | Title Page | ii |
|  | Certification and Approval Sheet | iii |
|  | Certification of Originality | iv |
|  | Acknowledgments | v |
|  | Abstract | vi |
|  | Table of Contents | vii |
|  | List of Tables | viii |
|  | List of Figures | ix |
| 1 | The Problem and Its Setting | TBD |
|  | Introduction | TBD |
|  | Background of the Study | TBD |
|  | Theoretical Framework | TBD |
|  | Conceptual Framework | TBD |
|  | Statement of the Problem | TBD |
|  | Objective of the Study | TBD |
|  | Scope and Limitations | TBD |
|  | Significance of the Study | TBD |
|  | Definition of Terms | TBD |
| 2 | Review of Related Literature and Studies | TBD |
|  | Retail and Rice Enterprise Digitalization and Sales-Inventory Management | TBD |
|  | First-In, First-Out (FIFO) Inventory Valuation and Control Systems | TBD |
|  | Digital Bookkeeping, Accounting Information Systems, and Tax Compliance in MSMEs | TBD |
|  | Internal Controls, Role-Based Access Control, Audit Trails, and Software Quality Evaluation | TBD |
|  | Research Gaps | TBD |
|  | Synthesis of the Reviewed Literature and Studies | TBD |
| 3 | Research Methodology | TBD |
|  | Research Design | TBD |
|  | Software Development Methodology (SDLC) | TBD |
|  | Sources of Data | TBD |
|  | Data Generation Procedure | TBD |
|  | Case Analysis Procedure | TBD |
|  | Locale and Population of Research | TBD |
|  | Research Instrument | TBD |
|  | Statistical Treatment of Research | TBD |
|  | Proposed System Architecture / Design Layout | TBD |
|  | System Diagrams and Logical Models | TBD |
|  | Cost-Benefit Analysis | TBD |
|  | Ethical Considerations | TBD |
|  | Gantt Chart | TBD |
| 4 | Results and Discussion (Planned) | TBD |
|  | Demographic Profile of Respondents | TBD |
|  | Technical Features and Functional Performance | TBD |
|  | Operational Time-Motion Variance and Workflow Tasks | TBD |
|  | Product Quality Evaluation and Usability Metrics According to ISO/IEC 25010 Standards and the System Usability Scale | TBD |
| 5 | Summary of Findings, Conclusions, and Recommendations (Planned) | TBD |
|  | Summary of Findings | TBD |
|  | Conclusions | TBD |
|  | Recommendations | TBD |
|  | References | TBD |
|  | Appendices | TBD |
|  | Appendix A: Approved Letter from UREC | TBD |
|  | Appendix B: Survey Questionnaires | TBD |
|  | Appendix C: Software Requirement Specification | TBD |
|  | Appendix D: Software Quality Tests | TBD |
|  | Appendix E: Form 17 Notarized Co-authorship | TBD |
|  | Appendix F: Form 18 Terminal Report with Received Copy | TBD |
|  | Appendix G: Copyright Certificate with Received Copy | TBD |
|  | Appendix H: Similarity Report Turnitin (10%–15%) Accepted | TBD |
|  | Appendix I: Grammarian Certificate from Grammarly | TBD |
|  | Appendix J: Statistical Validation | TBD |
|  | Appendix K: IMRAD Journal Publication Format | TBD |
|  | Appendix L: Photo Documentation During Testing and Survey | TBD |
|  | Appendix M: Photo Documentation During Final Defense | TBD |
|  | Appendix N: Curriculum Vitae | TBD |

---

**LIST OF TABLES**

| Number | Title | Page |
| --- | --- | --- |
| 1 | Input–Process–Output (IPO) Conceptual Paradigm of the Proposed EJBL System | TBD |
| 2 | Planned Agile Sprint Plan for EJBL System Development | TBD |
| 3 | Planned Locale, Population, and Provisional Evaluators of the Study | TBD |
| 4 | Five-Point Likert Scale Verbal Interpretation for ISO/IEC 25010 Evaluation | TBD |
| 5 | System Usability Scale (SUS) Adjective Rating Interpretation | TBD |
| 6 | Proposed Software and Hardware Requirements for EJBL | TBD |
| 7 | Proposed Core Database Entities and Relationships (ERD Summary) | TBD |
| 8 | Internal Role-Based Access Control (RBAC) and Use Case Matrix | TBD |
| 9 | Estimated Five-Month Development Cost Breakdown (Assumptions) | TBD |
| 10 | Planned Twenty-Week Agile Development Gantt Chart | TBD |

**LIST OF FIGURES**

| Number | Title | Page |
| --- | --- | --- |
| 1 | Conceptual Paradigm of the EJBL System (IPO Diagram — To Be Inserted) | TBD |
| 2 | Proposed System Architecture of EJBL (Flutter/Dart & Supabase — To Be Inserted) | TBD |
| 3 | Internal-Only Context Diagram and System Decomposition (To Be Inserted) | TBD |
| 4 | Data Flow Diagrams — Levels 0, 1, and 2 (To Be Inserted) | TBD |
| 5 | Entity Relationship Diagram (ERD — To Be Inserted After Schema Finalization) | TBD |
| 6 | Use Case Diagram and System Flowchart (To Be Inserted) | TBD |

---

# CHAPTER 1: THE PROBLEM AND ITS SETTING

## Introduction

Micro, small, and medium enterprises (MSMEs) serve as a cornerstone of local retail distribution in the Philippines, particularly in essential food staples such as rice. Running a retail rice store demands consistent coordination across daily sales recording, tiered sack and kilogram pricing, cash and digital payment tracking, supplier restocking with fluctuating acquisition costs, business-to-business credit or consignment monitoring, and statutory financial recordkeeping. When these interdependent tasks are managed through disconnected tools, small business owners face recurring administrative bottlenecks and reduced financial visibility.

Under Philippine tax regulations administered by the Bureau of Internal Revenue (BIR), business owners are required to maintain official books of accounts—commonly comprising the General Ledger, Cash Receipts Journal, Cash Disbursements Journal, and General Journal—through manual bound books, loose-leaf books with an approved Permit to Use (PTU), or a registered Computerized Accounting System (CAS) (Bureau of Internal Revenue, 2023, 2025). Research on Philippine micro and small enterprises confirms that systematic bookkeeping practices are directly linked to stronger tax compliance and financial performance, whereas manual or fragmented recordkeeping increases administrative burden and compliance risk (Cadiao, 2025). Similarly, studies on Philippine rice and general retail stores highlight persistent vulnerabilities in stock monitoring, formal recordkeeping, and inventory cost control (Gabriel, 2025; Gibo et al., 2026).

Information systems research establishes that technology improves operational performance only when its capabilities directly match the user's task structure (Goodhue & Thompson, 1995) and when reliable system quality and information quality translate into measurable user satisfaction and net benefits (DeLone & McLean, 2003). Addressing the operational realities of small rice retailers therefore requires an integrated recordkeeping platform tailored to their exact daily workflow rather than disconnected spreadsheets and manual ledger transcription.

## Background of the Study

EJBL Bigasan is a retail rice business located at Blk 9 Lot 1, Phase 5E, Verdantpoint, San Isidro, Rodriguez, Rizal, Philippines, 1860. At present, the store operates primarily as a one-person enterprise managed by the business owner, assisted by one cousin who helps with deliveries. Despite this lean staffing setup, daily store operations involve varied transaction rules: walk-in and delivery sales measured in 25-kilogram sacks or retail kilograms, tiered wholesale and retail pricing depending on sack quantity and fulfillment type, delivery fees recorded as separate store income, cash and online payments (GCash, BPI, InstaPay, and split cash-online payments with reference numbers), and business-to-business (B2B) consignment arrangements paid in full or through partial installments.

Currently, EJBL Bigasan documents daily transactions using a physical sales notebook alongside a five-sheet Microsoft Excel workbook consisting of SALES, CASHBOOK, INVENTORY, EXPENSES, and CAPITAL worksheets. While the existing Excel workbook already utilizes selected formulas and functions to automate certain pricing calculations and daily totals, the five sheets operate as separate manual tables. Consequently, the business owner must repeatedly encode transaction data across multiple sheets—recording sales in SALES and again in CASHBOOK, entering rice restocks as Cost of Goods Sold (COGS) in EXPENSES while separately updating INVENTORY, and manually reconciling cash box balances, GCash totals, overages (sobra), shortages (short), and B2B consignment accounts.

More critically, the primary operational challenge identified by the owner is the absence of integrated basic bookkeeping. Because the existing spreadsheets do not automatically post transactions into accounting ledgers, the owner must manually copy and transcribe financial information into four physical BIR books of accounts: the General Ledger, Cash Receipts Journal, Cash Disbursements Journal, and General Journal. Furthermore, because supplier purchase costs (puhunan per kilogram) vary across deliveries, manually tracking First-In, First-Out (FIFO) batch costs across disconnected spreadsheets is tedious and error-prone.

To address these confirmed operational and bookkeeping challenges, the proponents—Diploma in Information Technology students of the Polytechnic University of the Philippines—propose EJBL: An Integrated Sales, Expense Tracking, Basic Bookkeeping, and FIFO Inventory Management System for EJBL Bigasan. Built with Flutter and Dart for Android devices and web browsers as a Progressive Web App (PWA) and connected online to Supabase, the proposed internal-use mobile application unifies daily Log entry, automated Business Records, FIFO batch inventory costing, role-based access control with void audit retention, and automated posting into four structured BIR bookkeeping ledgers. This study aligns with the Polytechnic University of the Philippines Research Agenda—specifically Strategic Goal 4 (Intensified Research Innovation, Dissemination, and Utilization), Strategic Goal 5 (Strengthened Sustainable and Impactful Extension Program), and Strategic Goal 6 (Expanded Research and Extension Networks with Local, National, and International Partners)—and supports the United Nations Sustainable Development Goals on Decent Work and Economic Growth (SDG 8), Industry, Innovation, and Infrastructure (SDG 9), and Responsible Consumption and Production (SDG 12).

## Theoretical Framework

This study is anchored on two established information systems theories that explain why aligning software design with EJBL Bigasan's actual operational tasks leads to measurable quality and operational benefits.

**Task-Technology Fit (TTF) Theory. **Proposed by Goodhue and Thompson (1995), Task-Technology Fit Theory posits that an information system improves individual and organizational performance only to the degree that its functionalities fit the user's specific task portfolio. When small retail enterprises rely on general-purpose spreadsheets alongside handwritten statutory ledgers, a structural mismatch arises between interdependent financial workflows and disconnected tools. In this study, TTF guides the design of EJBL's four integrated modules so that a single daily Log entry automatically populates Business Records, incoming rice deliveries automatically update FIFO cost batches and COGS expenses, consignment deliveries deduct stock immediately while deferring cashbook income until payment collection, and verified transactions post automatically into the four BIR books.

**DeLone and McLean Information Systems Success Model. **Originally introduced in 1992 and updated by DeLone and McLean (2003), the Information Systems Success Model evaluates system effectiveness across six interrelated dimensions: System Quality, Information Quality, Service Quality, Intention to Use/Use, User Satisfaction, and Net Benefits. In EJBL, System Quality corresponds to technical reliability, responsiveness, usability, and role-based security enforced via Supabase Row Level Security (RLS), while Information Quality reflects accurate FIFO batch costing, consistent cashbook reconciliation, preserved void/cancel audit trails, and structured BIR ledger outputs. This model directly anchors the study's planned evaluation using ISO/IEC 25010:2011 product quality standards and the System Usability Scale (SUS).

## Conceptual Framework

The study adopts the Input–Process–Output (IPO) conceptual paradigm, paired with an evaluation and feedback loop, to map how EJBL Bigasan's operational data, technical architecture, and quality standards produce the proposed mobile system. Table 1 summarizes the IPO conceptual framework (Figure 1 visual diagram to be inserted upon finalization of system schematics).

*Table 1. Input–Process–Output (IPO) Conceptual Paradigm of the Proposed EJBL System*

| Input | Process | Output |
| --- | --- | --- |
| Operational & Business Data:
• Existing 5-sheet Excel records (SALES, CASHBOOK, INVENTORY, EXPENSES, CAPITAL)
• SI (continuous from 1) & auto-generated NSI sales rules
• Multi-item sack/kg orders, tiered walk-in/delivery prices, delivery fees
• Cash, online (GCash/BPI/InstaPay), & split payments
• B2B consignment contracts & partial/full collections
• Supplier rice restocks with batch puhunan/kg
• Owner capital contributions & personal withdrawals | Analysis & Agile Design:
• Requirements validation with EJBL Bigasan owner
• Relational PostgreSQL schema & FIFO batch logic design
• Supabase RBAC & void/cancel audit trail design
• External bookkeeper verification of 4 BIR book column layouts

Agile Iterative-Incremental Development:
• Sprint 1: Auth, RBAC, Inventory & Rice Price Guide
• Sprint 2: Log (In/Out), Auto Business Records, Void Audit
• Sprint 3: FIFO Batch Costing, Restock-to-COGS, Consignment
• Sprint 4: 4 BIR Books, Capital, Owner Manual Edit & PDF Export | Developed Application:
• EJBL: An Integrated Sales, Expense Tracking, Basic Bookkeeping, and FIFO Inventory Management System (Android & Web PWA application via Flutter/Dart + Supabase)

Key Operational & Research Outputs:
• Single-entry Log auto-populating Business Records
• Real-time FIFO batch stock & COGS valuation
• Preserved Manager void/cancel audit log for Owner review
• Auto-populated 4 BIR Books with PDF export |
| Technical & Evaluation Inputs:
• Flutter & Dart (Android & Web / PWA, online-only)
• Supabase (PostgreSQL, Auth, RLS, SQL RPC)
• ISO/IEC 25010:2011 product quality standard
• System Usability Scale (SUS)
• BIR Books of Accounts format guidelines | Testing & Planned Evaluation:
• Unit, integration, FIFO accuracy, & RLS security testing
• Planned ISO/IEC 25010:2011 evaluation (IT expert & internal users)
• Planned SUS usability evaluation
• External bookkeeper/accountant format verification & feedback loop | Verified Evaluation Results (Chapter 4 — Planned):
• ISO/IEC 25010 quality ratings
• SUS usability score & adjective rating
• External bookkeeping format validation feedback |

As shown in Table 1, EJBL Bigasan's actual operational records, pricing rules, and bookkeeping requirements constitute the primary inputs alongside the chosen Flutter/Dart and Supabase stack and standardized evaluation frameworks. Through Agile iterative-incremental development and testing, these inputs are transformed into an integrated internal-use mobile application whose quality, usability, and bookkeeping format alignment are validated through structured evaluation and feedback.

## Statement of the Problem

EJBL Bigasan currently relies on a sales notebook, disconnected Microsoft Excel worksheets, and manual handwriting into four physical BIR books of accounts, resulting in duplicate data encoding across sheets, difficulty tracking batch-level FIFO rice purchase costs, and time-consuming manual ledger transcription. Specifically, this study seeks to answer the following questions:

1. What operational, inventory costing, and bookkeeping challenges are experienced by EJBL Bigasan under its existing multi-sheet Excel and manual BIR ledger recording workflow?
1. How can an integrated mobile application be designed and developed to consolidate daily sales and expense logging, automated Business Records generation, FIFO batch inventory management, role-based access control with preserved void/cancel audit trails, and automated posting to the four BIR books?
1. What is the level of software product quality of the developed EJBL system as evaluated by IT evaluator(s) and internal users based on ISO/IEC 25010:2011 standards in terms of functional suitability, performance efficiency, compatibility, usability, reliability, security, maintainability, and portability?
1. What is the level of perceived usability of the developed system based on the System Usability Scale (SUS), and how accurately do the generated bookkeeping outputs conform to the required structure of the four BIR books as evaluated by an external bookkeeper or accountant?
## Objective of the Study

### General Objective

To design, develop, and evaluate EJBL: An Integrated Sales, Expense Tracking, Basic Bookkeeping, and FIFO Inventory Management System for EJBL Bigasan—an internal-use mobile application that unifies daily retail operations, FIFO inventory valuation, and basic bookkeeping preparation.

### Specific Objectives

1. To analyze EJBL Bigasan's existing sales recording, expense tracking, inventory costing, B2B consignment monitoring, and manual four-book BIR transcription processes to establish verified system requirements.
1. To design and develop an online cross-platform application for Android and Web (Progressive Web App / PWA) using Flutter, Dart, and Supabase composed of four integrated modules: (a) Log (Log In for sales with continuous SI numbering starting from 1, auto-generated NSI numbering for non-receipt transactions, multi-item sack/kg orders, tiered walk-in/delivery pricing, delivery fee income, and cash/online/split payments; Log Out for operating expenses) that automatically populates Business Records; (b) Business Records (auto-populated Cashbook and categorized Expenses ledger); (c) Inventory (FIFO batch costing tracking purchase cost per delivery, automated COGS expense creation upon receiving stock, immediate stock deduction on sales and consignment deliveries with payment-based income recognition, low-stock ordering points, and integrated rice variety code and price guide); and (d) BIR Books and Capital (auto-populated General Ledger, Cash Receipts Journal, Cash Disbursements Journal, and General Journal alongside Capital tracking, Owner manual entry/editing, and PDF export of the four BIR books).
1. To implement server-enforced role-based access control via Supabase Row Level Security across three internal user roles (Employee/Staff, Manager, and Admin/Owner), including Manager-level price overrides and a stored void/cancel audit log visible to the Owner rather than permanent record deletion.
1. To evaluate the software product quality of the developed system using ISO/IEC 25010:2011 standards and assess user-perceived usability using the System Usability Scale (SUS).
1. To validate the column structure and accounting format of the four auto-populated BIR books through external evaluation by a bookkeeper or accountant.
## Scope and Limitations

### Scope

- **Target Establishment and Locale: **Developed exclusively for the internal operations of EJBL Bigasan at Blk 9 Lot 1, Phase 5E, Verdantpoint, San Isidro, Rodriguez, Rizal, Philippines, 1860.
- **Platform and Connectivity: **Cross-platform application targeting Android devices and Web browsers (Progressive Web App / PWA) built with Flutter and Dart, operating online with a centralized Supabase backend (PostgreSQL, Authentication, Row Level Security, and atomic database functions).
- **Four Integrated Modules: **(1) Log (Log In sales with continuous SI starting from 1 and auto-generated NSI, multi-item orders, tiered walk-in/delivery pricing, delivery fee income, cash/online/split payments with reference numbers; Log Out expenses) auto-populating Business Records; (2) Business Records (Cashbook monitoring cash box, GCash/online balances, overages/shortages, and consignment collections, plus Expenses ledger); (3) Inventory (FIFO batch costing per delivery puhunan/kg, automatic COGS expense creation on restock, immediate stock deduction on sales and consignment deliveries, ordering-point monitoring, and integrated rice code/price guide); and (4) BIR Books and Capital (auto-populated General Ledger, Cash Receipts Journal, Cash Disbursements Journal, and General Journal, plus Capital tracking, Owner manual edits/entries, and PDF export).
- **Internal Role-Based Access Control: **Although EJBL Bigasan currently operates with one owner and one cousin assisting with deliveries, the system implements three internal roles to support current delegation and future expansion: Employee/Staff (add and save Log entries; view Inventory; no price overrides; no access to Business Records, Capital, or BIR Books); Manager (add, edit, save, and void/cancel Log entries with every void/cancellation preserved in an audit log; full Inventory management; authorized price overrides; view-only access to Business Records); and Admin/Owner (full access to all modules, including Business Records, Capital, review of all voided/cancelled records, manual entries/edits on the BIR Books, and PDF export).
- **System Boundary: **Internal use only. Suppliers and B2B consignment clients exist strictly as internal database records/tables rather than external system users. The bookkeeper or CPA serves solely as an external evaluator of the four BIR books and does not hold an operational system login.
### Limitations

- **Platform & Online-Only Operation: Native Apple iOS (App Store/IPA) builds are excluded from the current scope; iOS devices may access the system only via the web browser/PWA. **The application requires an active internet connection to communicate with Supabase. Offline transaction entry and local-to-cloud conflict synchronization are excluded from the current scope.
- **No External Portals or Payment Gateways: **The system does not include a customer-facing e-commerce storefront, delivery rider GPS tracker, supplier portal, automated payment gateway checkout, or external CPA login portal.
- **BIR Regulatory Compliance Boundary: **While EJBL structures and exports the four BIR books to PDF to assist bookkeeping preparation, the application is not a BIR-accredited Computerized Accounting System (CAS) and does not replace official BIR registration, Permit to Use (PTU) for loose-leaf books, Acknowledgement Certificate (AC) for computerized books, tax return computation, or eBIRForms/eFPS filing. Final column formats of the four BIR books depend on pending external confirmation from a bookkeeper or accountant.
- **PDF Export Scope: **PDF export is scoped exclusively to the four BIR books in the initial release; exporting Business Records or Inventory reports is excluded for now.
- **Evaluation Sample Size: **Operational evaluation is bounded by EJBL Bigasan's actual small-enterprise staffing (owner and delivery helper), supplemented by planned technical and bookkeeping evaluations from invited external IT and bookkeeping evaluators.
## Significance of the Study

- **Business Owner (Admin) of EJBL Bigasan: **Eliminates repetitive manual encoding across separate Excel worksheets and manual transcription into four physical BIR books, provides accurate batch-level FIFO cost and profit visibility, streamlines consignment and cashbox reconciliation, and protects financial integrity through a preserved void/cancel audit trail.
- **Store Personnel and Future Staff/Managers: **Simplifies daily transaction recording via an integrated rice code and tiered price guide while enforcing clear permission boundaries that reduce computation errors and accidental financial alterations.
- **External Bookkeeper / Accountant: **Receives organized, reconciled, PDF-exportable bookkeeping ledgers tied directly to underlying sales, expenses, and capital entries, reducing verification effort during periodic reviews.
- **Researchers (PUP DIT Students): **Strengthens applied competency in translating real-world retail accounting, FIFO inventory logic, and database-enforced security into a production-minded mobile information system.
- **Future Researchers: **Provides a documented reference architecture and empirical evaluation for integrated sales, FIFO inventory, and basic bookkeeping applications designed for Philippine micro and small retail enterprises.
## Definition of Terms

The following terms are defined conceptually and operationally for uniform understanding throughout the study:

- **Basic Bookkeeping: **Conceptually, the systematic recording and classification of financial transactions into journals and ledgers. Operationally, EJBL's module that automatically posts sales, expenses, owner contributions, and withdrawals into four BIR-aligned books with Owner manual adjustment and PDF export capabilities.
- **BIR Books of Accounts: **Conceptually, official accounting records mandated by the Bureau of Internal Revenue for registered businesses in the Philippines. Operationally, the four digital ledgers integrated in EJBL: General Ledger, Cash Receipts Journal, Cash Disbursements Journal, and General Journal.
- **Business Records: **Operationally, the consolidated financial tracking module in EJBL—auto-populated from Log entries—comprising the Cashbook and categorized Expenses ledger, accessible as view-only to Managers and fully editable by the Admin/Owner.
- **Consignment: **Conceptually, an arrangement in which goods are released to a buyer with payment deferred under agreed terms. Operationally, B2B credit deliveries at EJBL Bigasan where rice stock is deducted from Inventory immediately upon delivery, while cash inflow is recorded in the Cashbook and Cash Receipts Journal only upon full or partial payment collection.
- **First-In, First-Out (FIFO): **Conceptually, an inventory valuation method assuming the earliest acquired inventory is sold or issued first. Operationally, EJBL's batch-costing mechanism that tracks unit purchase cost (puhunan/kg) per supplier delivery and deducts outgoing sales from the oldest remaining stock batch.
- **ISO/IEC 25010:2011: **Conceptually, the international SQuaRE standard defining eight software product quality characteristics. Operationally, the standardized evaluation model used by IT evaluator(s) and internal users to rate EJBL's technical quality.
- **Log Module: **Operationally, EJBL's primary daily encoding screen divided into Log In (sales transactions) and Log Out (operating expenses) that automatically populates Business Records upon saving.
- **Non-Sales Invoice (NSI): **Operationally, an auto-generated sequential internal transaction reference assigned to sales where the customer declines a physical official receipt.
- **Puhunan: **Conceptually, a Filipino business term denoting capital or acquisition cost. Operationally, the unit purchase cost per kilogram of rice recorded for each incoming supplier delivery batch to compute FIFO Cost of Goods Sold.
- **Role-Based Access Control (RBAC): **Conceptually, an access control mechanism restricting system permissions according to assigned user roles (Sandhu et al., 1996). Operationally, Supabase Row Level Security policies separating Employee/Staff, Manager, and Admin/Owner privileges in EJBL.
- **Sales Invoice (SI): **Conceptually, a commercial receipt documenting the sale of goods. Operationally, a continuous receipt number starting from 1 corresponding to EJBL Bigasan's physical receipt booklet for sales issued with receipts.
- **System Usability Scale (SUS): **Conceptually, a standardized ten-item Likert questionnaire developed by Brooke (1996) to measure perceived usability on a 0–100 scale. Operationally, the usability instrument administered to EJBL users during evaluation.
- **Void/Cancel Audit Trail: **Operationally, EJBL's control mechanism that retains every Manager-voided or cancelled Log record—alongside user ID, timestamp, and reason—in a stored log visible to the Admin/Owner instead of permanently deleting financial records.
---

# CHAPTER 2: REVIEW OF RELATED LITERATURE AND STUDIES

This chapter reviews verified peer-reviewed literature, empirical studies, and institutional regulatory issuances that establish the theoretical and technical foundation for EJBL: An Integrated Sales, Expense Tracking, Basic Bookkeeping, and FIFO Inventory Management System for EJBL Bigasan. The reviewed works are organized thematically across four domains directly aligned with the study's objectives: (1) retail and rice enterprise digitalization and sales-inventory management; (2) First-In, First-Out (FIFO) inventory valuation and control systems; (3) digital bookkeeping, accounting information systems, and tax compliance in MSMEs; and (4) internal controls, role-based access control, audit trails, and software quality evaluation.

## Retail and Rice Enterprise Digitalization and Sales-Inventory Management

Small-scale retail and rice enterprises in the Philippines face recurring operational challenges rooted in informal recordkeeping and fragmented inventory tracking. Gibo et al. (2026) examined the selling strategies and business practices of rice retailers in a rural Philippine setting (Cabanglasan, Bukidnon) and found that despite competitive pricing and customer service efforts, small rice retailers remain vulnerable due to inadequate recordkeeping and the absence of systematic inventory tracking, which negatively affect financial stability and credit monitoring. Consistent with this finding, Gabriel (2025) assessed the inventory management practices of retailers—including rice retailers—in Santiago City, Philippines, reporting that while routine purchasing is widely practiced, formal recordkeeping, structured stock issuance, and systematic inventory monitoring are frequently neglected, exposing small stores to recurring operational and inventory discrepancies.

To address manual retail bottlenecks, Philippine researchers have increasingly developed integrated point-of-sale (POS) and inventory systems tailored for small and medium enterprises (SMEs). Domingo et al. (2026) designed QSUMeMarket, an integrated decision support framework bridging point-of-sale order processing and inventory management for Philippine SMEs, and evaluated its software quality using ISO/IEC 25010:2011 across performance efficiency, usability, security, compatibility, and reliability. Compared with Gibo et al. (2026) and Gabriel (2025), which diagnose the operational recordkeeping weaknesses of Philippine rice and general retailers, Domingo et al. (2026) demonstrate the viability of structured digital POS-inventory integration for local SMEs. However, whereas QSUMeMarket focuses primarily on customer order processing and general SME workflows, EJBL Bigasan requires an internal-use mobile workflow specifically adapted to rice retail conventions—including sack-versus-kilogram conversions, tiered walk-in and delivery pricing, SI/NSI receipt tracking, B2B consignment balances, and direct bookkeeping integration.

## First-In, First-Out (FIFO) Inventory Valuation and Control Systems

Systematic inventory management directly influences the operational efficiency and financial viability of small and medium enterprises. In a systematic review of inventory management and SME performance, Panigrahi et al. (2024) synthesized empirical findings demonstrating that structured inventory control mechanisms—including disciplined cost-flow valuation methods such as FIFO and digital stock tracking—mitigate overstocking, stockouts, and working-capital constraints in SMEs. Focusing specifically on retail operations in Indonesia, Aghniya et al. (2025) evaluated the implementation of the First-In, First-Out (FIFO) method in improving retail operational performance, confirming that enforcing FIFO stock rotation strengthens stock accuracy and operational control across high-turnover retail goods.

Recent software engineering studies further validate the practical implementation of FIFO algorithms within small-store information systems. Fadillah and Sutopo (2023) designed and built a web-based inventory information system applying the FIFO method to automate incoming and outgoing stock logic for a retail store, reducing manual stock-flow tracking errors. Extending this approach, Nabila et al. (2024) implemented a web-based FIFO inventory information system for a retail supply store to organize batch inflows, sequential stock deductions, and inventory reporting. While Panigrahi et al. (2024) establish the broader financial impact of inventory control and Fadillah and Sutopo (2023), Nabila et al. (2024), and Aghniya et al. (2025) demonstrate FIFO's operational value in general retail stores, these implementations primarily treat inventory as standalone web stock modules. EJBL builds directly on this body of work by embedding FIFO batch costing (tracking unit puhunan per kilogram per supplier delivery) inside a cross-platform mobile system where receiving rice stock automatically creates a Cost of Goods Sold expense entry and every sale or consignment delivery atomically deducts from the oldest available cost batch.

## Digital Bookkeeping, Accounting Information Systems, and Tax Compliance in MSMEs

Beyond stock tracking, accurate bookkeeping is critical for regulatory compliance and financial decision-making among micro and small enterprises. In the Philippine regulatory context, the Bureau of Internal Revenue (BIR) requires registered businesses to maintain official books of accounts—including the General Ledger, Cash Receipts Journal, Cash Disbursements Journal, and General Journal—and has modernized registration through the Online Registration and Update System (ORUS) under Revenue Memorandum Circular (RMC) No. 3-2023 and RMC No. 65-2025, which distinguish among Manual Books, Loose-Leaf Books of Accounts requiring a Permit to Use, and Computerized Books of Accounts requiring formal authorization (Bureau of Internal Revenue, 2023, 2025).

Empirical evidence in the Philippines underscores the direct relationship between bookkeeping practices and MSME compliance. Cadiao (2025) investigated tax knowledge, bookkeeping practices, and financial performance among Philippine micro-enterprises, establishing that stronger bookkeeping practices and tax awareness significantly support BIR compliance, reduce audit vulnerability, and improve financial visibility. Similarly, in the broader Southeast Asian MSME context, Rustendy et al. (2024) examined digital bookkeeping adoption among MSMEs in Indonesia using an extended Technology Acceptance Model, finding that perceived usefulness, ease of use, and user self-efficacy play decisive roles in transitioning micro-entrepreneurs from manual logs to digital bookkeeping applications. Together, Cadiao (2025), Rustendy et al. (2024), and BIR issuances (2023, 2025) directly validate EJBL Bigasan's primary operational problem: although basic spreadsheets assist with arithmetic, micro-enterprise owners still bear heavy administrative effort manually writing entries into statutory books of accounts, and user-friendly digital bookkeeping automation can substantially reduce that burden—provided the system respects regulatory boundaries and supports external professional review by a bookkeeper or CPA.

## Internal Controls, Role-Based Access Control, Audit Trails, and Software Quality Evaluation

Integrating sales, inventory, and financial ledgers into a multi-role digital system requires robust internal controls to preserve data integrity. Sandhu et al. (1996) formalized Role-Based Access Control (RBAC), establishing that assigning permissions to organizational roles rather than individual users simplifies administration and enforces least-privilege separation of duties. Recent empirical studies confirm the importance of pairing accounting information systems with strong internal controls in MSMEs. Tindage et al. (2025) investigated accounting information system implementation in MSMEs and demonstrated that system reliability, access security, and accurate reporting significantly strengthen internal control effectiveness. Likewise, Fitria et al. (2024) examined culinary-sector MSMEs and found that combining structured accounting information systems with internal controls supports business sustainability and financial accountability. These findings directly justify EJBL's server-enforced Supabase Row Level Security policies separating Employee/Staff, Manager, and Admin/Owner privileges, restricting guide-price overrides to Managers and Admin, and replacing permanent deletion with a preserved void/cancel audit trail visible to the Owner.

Finally, rigorous evaluation of an applied capstone information system requires combining technical product quality standards with user-centered usability metrics. ISO/IEC 25010:2011 defines eight standardized software product quality characteristics—functional suitability, performance efficiency, compatibility, usability, reliability, security, maintainability, and portability—widely applied in Philippine SME system evaluations (International Organization for Standardization, 2011; Domingo et al., 2026). Complementing expert technical evaluation, Brooke (1996) introduced the System Usability Scale (SUS), a reliable ten-item Likert instrument producing a 0–100 usability score, which Bangor et al. (2009) extended with an empirical adjective rating scale (ranging from Worst Imaginable to Best Imaginable) to make individual SUS scores interpretable for small-sample evaluations. Using ISO/IEC 25010:2011 alongside SUS provides both technical rigor and practical usability verification suited to EJBL Bigasan's small internal user base.

## Research Gaps

Based on the reviewed peer-reviewed studies and regulatory guidelines, four specific gaps remain insufficiently addressed in existing literature:

**1. Fragmentation Between Retail Inventory Systems and Statutory Basic Bookkeeping. **Existing retail FIFO software studies (Fadillah & Sutopo, 2023; Nabila et al., 2024) and Philippine SME POS frameworks (Domingo et al., 2026) focus primarily on sales and stock movement without automatically posting daily transactions, restock COGS entries, owner capital contributions, and personal withdrawals into the four BIR-aligned books of accounts (General Ledger, Cash Receipts Journal, Cash Disbursements Journal, and General Journal). Conversely, MSME bookkeeping studies (Cadiao, 2025; Rustendy et al., 2024) examine bookkeeping adoption and compliance but do not integrate batch-level FIFO stock costing. EJBL addresses this gap by linking daily sales/expense logging, FIFO inventory costing, and automated four-book ledger posting inside one workflow.

**2. Limited Software Tailoring to Philippine Neighborhood Rice Retail Mechanics. **Empirical assessments of Philippine rice and general retailers (Gibo et al., 2026; Gabriel, 2025) confirm persistent recordkeeping and stock-control gaps, yet general retail POS and FIFO systems rarely model neighborhood bigasan rules—specifically dual sack/kilogram units, tiered walk-in versus delivery sack pricing, continuous SI versus auto-generated NSI receipt series, delivery fees recorded as separate income, and B2B consignment deliveries where stock deducts immediately while cashbook income is recognized only upon full or partial collection. EJBL directly models these exact domain workflows.

**3. Under-Specified Audit Retention for Cancellations in Micro-Enterprise Systems. **While internal control studies (Tindage et al., 2025; Fitria et al., 2024) and RBAC theory (Sandhu et al., 1996) emphasize access separation and financial traceability, small-business software implementations often allow managers to hard-delete erroneous records, risking broken FIFO balances and missing audit trails. EJBL addresses this gap by enforcing server-side RBAC alongside mandatory void/cancel retention so every cancelled record remains auditable by the business owner.

**4. Lack of Applied Integration Validated Locally for EJBL Bigasan. **None of the reviewed systems has been specifically engineered, deployed, and evaluated for EJBL Bigasan in San Isidro, Rodriguez, Rizal using a combined ISO/IEC 25010:2011, SUS, and external bookkeeper format verification protocol.

## Synthesis of the Reviewed Literature and Studies

The reviewed literature converges on four principles that shape the design and methodology of the proposed EJBL system. First, Philippine rice and retail MSMEs face verified operational vulnerabilities when relying on manual or disconnected spreadsheet recordkeeping (Gibo et al., 2026; Gabriel, 2025), and unified POS-inventory platforms demonstrably improve operational control (Domingo et al., 2026). Second, implementing automated FIFO valuation improves stock rotation, cost accuracy, and SME performance (Panigrahi et al., 2024; Aghniya et al., 2025; Nabila et al., 2024; Fadillah & Sutopo, 2023). Third, systematic bookkeeping aligned with BIR books of accounts is essential for micro-enterprise compliance and financial clarity, and user-friendly digital adoption reduces manual transcription burden (Cadiao, 2025; Rustendy et al., 2024; Bureau of Internal Revenue, 2023, 2025). Fourth, coupling role-based access control and audit trails with standardized software evaluation (ISO/IEC 25010:2011 and SUS) ensures both financial accountability and measurable software quality (Sandhu et al., 1996; Tindage et al., 2025; Fitria et al., 2024; Brooke, 1996; Bangor et al., 2009). Together, these empirical and theoretical foundations establish a coherent justification for developing EJBL as an integrated, internal-use mobile platform for EJBL Bigasan.

---

# CHAPTER 3: RESEARCH METHODOLOGY

This chapter presents the research design, software development methodology, data sources, data generation and case analysis procedures, research locale and population, research instruments, statistical treatment, proposed system architecture and technical diagrams, cost-benefit estimates, ethical considerations, and planned project schedule. All development, data-gathering, and evaluation activities described herein represent planned procedures unless explicitly stated as already observed from EJBL Bigasan's existing operational records.

## Research Design

This study will employ a Descriptive-Developmental Research Design. The descriptive component systematically documents and analyzes EJBL Bigasan's existing multi-sheet Excel workflow, sales notebook practices, FIFO costing challenges, consignment handling, and manual four-book BIR transcription, and later describes the quantitative software quality (ISO/IEC 25010:2011) and usability (SUS) ratings gathered during evaluation. The developmental component governs the structured analysis, architectural design, database engineering, iterative mobile application development, and testing of the proposed EJBL system. This combined design directly supports all four Statement of the Problem questions by linking empirical problem diagnosis to software creation and standardized evaluation.

## Software Development Methodology (SDLC)

The proponents adopt the Agile (Iterative-Incremental / Scrum) Software Development Life Cycle methodology. Agile is selected over linear models such as Waterfall because EJBL Bigasan's requirements involve interdependent accounting logic—specifically FIFO batch costing, consignment partial payments, and the exact column formats of the four BIR books, which remain pending final confirmation from an external bookkeeper or accountant. Delivering functional increments across short, reviewable sprints allows the researchers to build and verify core operational modules early, demonstrate working screens to the store owner and external bookkeeper for timely feedback, and incorporate confirmed BIR formatting without disrupting completed modules. Table 2 outlines the planned four-sprint Agile cycle.

*Table 2. Planned Agile Sprint Plan for EJBL System Development*

| Sprint | Focus Modules & Core Activities | Planned Deliverables |
| --- | --- | --- |
| Sprint 1
(Weeks 1–5) | Requirements validation, PostgreSQL relational schema design, Supabase Auth & RLS setup, Inventory & Rice Code/Price Guide module. | Approved database schema, RBAC policies (Staff/Manager/Admin), Inventory screen & linked Price Guide. |
| Sprint 2
(Weeks 6–10) | Log module (Log In sales with continuous SI from 1 & auto-generated NSI; Log Out expenses), automatic Log-to-Business Records population, Manager void/cancel audit trail. | Working Log module, auto-populated Cashbook & Expenses (Business Records), Void/Cancel Audit Log screen. |
| Sprint 3
(Weeks 11–15) | FIFO batch costing engine (atomic SQL RPC stock deduction), automatic Restock-to-COGS expense creation, B2B consignment delivery & partial/full payment collection logic. | Verified FIFO valuation, consignment ledger with status tracking (Unpaid/Partial/Paid), low-stock alerts. |
| Sprint 4
(Weeks 16–20) | 4 BIR Books (General Ledger, Cash Receipts Journal, Cash Disbursements Journal, General Journal) & Capital auto-posting, Owner manual edits, BIR PDF export, testing & evaluation. | Bookkeeper-reviewed BIR Books module with PDF export, completed QA tests, ISO/IEC 25010 & SUS evaluation data. |

## Sources of Data

**Primary Sources: **Authorized operational records provided by EJBL Bigasan (specifically the five-sheet EJBL_BIGASAN.xlsx workbook covering SALES, CASHBOOK, INVENTORY, EXPENSES, and CAPITAL) and stakeholder consultations with the business owner; plus planned primary data to be collected through structured interviews, workflow observation, ISO/IEC 25010:2011 and SUS evaluation questionnaires, and external bookkeeper verification of the four BIR books. No survey responses or formal evaluation scores have been collected yet.

**Secondary Sources: **Verified peer-reviewed journal articles on Philippine rice retail practices, FIFO inventory systems, MSME bookkeeping, RBAC internal controls, and usability evaluation; official Bureau of Internal Revenue issuances (RMC No. 3-2023 and RMC No. 65-2025); the ISO/IEC 25010:2011 software quality standard; and official technical documentation for Flutter, Dart, and Supabase.

## Data Generation Procedure

The following planned steps will govern data collection and validation:

1. Authorization and Preparation: Secure formal consent from the owner of EJBL Bigasan and obtain PUP adviser approval for research instruments and ethical clearance requirements.
1. Baseline Workflow Analysis: Conduct structured interviews and review EJBL Bigasan's existing Excel workbook and physical BIR ledger workflow to finalize functional rules and capture baseline timing/process observations.
1. Bookkeeper Consultation (Planned): Coordinate with the external bookkeeper (and consulted accountant colleague, if confirmed) to validate the exact column layouts required for the four BIR books prior to finalizing Sprint 4.
1. Iterative Development and Technical Testing: Build each Agile sprint and execute unit, integration, FIFO calculation, and Supabase RLS security tests before user trials.
1. System Evaluation Administration (Planned): Orient internal users and invited evaluators, allow hands-on testing of EJBL across realistic store scenarios, and administer the ISO/IEC 25010:2011 questionnaire, SUS questionnaire, and BIR Books Format Verification Checklist.
1. Data Encoding and Analysis (Planned): Encode verified evaluation responses, compute statistical metrics, and compile validated findings for Chapter 4.
## Case Analysis Procedure

A structured before-and-after case analysis will be conducted on EJBL Bigasan's actual operational records. First, the researchers analyze the store's baseline five-sheet Excel workflow (SALES, CASHBOOK, INVENTORY, EXPENSES, CAPITAL) and manual handwriting process into the four physical BIR books—identifying redundant encoding steps, unlinked stock-to-expense entries, and manual FIFO cost tracking. After system development, representative sample transactions (walk-in/delivery multi-item sales, split payments, rice restocks, B2B consignment deliveries and partial collections, Manager voids, and owner withdrawals) will be processed inside EJBL to verify atomic accuracy across Log, Business Records, FIFO Inventory, and the four BIR Books.

## Locale and Population of Research

The study is conducted at EJBL Bigasan, located at Blk 9 Lot 1, Phase 5E, Verdantpoint, San Isidro, Rodriguez, Rizal, Philippines, 1860. Because EJBL Bigasan is currently operated by a single business owner assisted by one cousin who handles deliveries, the study employs purposive sampling covering all actual internal operational personnel supplemented by invited external domain evaluators. Table 3 presents the planned respondent composition; external evaluator counts are provisional and subject to final confirmation prior to data gathering.

*Table 3. Planned Locale, Population, and Provisional Evaluators of the Study*

| Respondent Group | Planned Count (Provisional) | Sampling Method | Evaluation Role |
| --- | --- | --- | --- |
| EJBL Bigasan Business Owner (Admin) | 1 | Purposive (Total Internal) | Operational walkthrough, ISO/IEC 25010 user criteria, SUS usability evaluation. |
| Store Delivery Helper (Staff Role) | 1 | Purposive (Total Internal) | Log entry & Inventory view walkthrough, SUS usability evaluation. |
| IT Expert Evaluator | 1 (Tentative) | Purposive | Full ISO/IEC 25010:2011 technical product quality evaluation (all 8 characteristics). |
| External Bookkeeper / Accountant | 1 (Tentative; + accountant consultation if confirmed) | Purposive | External format and structural verification of the four BIR books and PDF outputs. |

## Research Instrument

Three planned research instruments will be used during system evaluation (final copies to be attached in Appendix B upon adviser approval):

- **ISO/IEC 25010:2011 Software Product Quality Questionnaire: **A structured five-point Likert scale instrument assessing all eight standard product quality characteristics (Functional Suitability, Performance Efficiency, Compatibility, Usability, Reliability, Security, Maintainability, and Portability), administered to the IT expert evaluator and applicable user-facing items to internal store personnel.
- **System Usability Scale (SUS): **The standardized ten-item five-point Likert questionnaire developed by Brooke (1996) alternating positively and negatively worded items to measure perceived usability on a 0–100 composite scale without altering the instrument's validated wording or scoring rules.
- **BIR Books Format Verification Checklist: **A structured expert review form administered to the external bookkeeper/accountant to verify whether EJBL's auto-populated General Ledger, Cash Receipts Journal, Cash Disbursements Journal, General Journal, and exported PDFs conform to standard BIR manual/loose-leaf bookkeeping column structures.
## Statistical Treatment of Research

Because the planned evaluation involves a small purposive respondent group tailored to a single micro-enterprise, descriptive statistics will be used to analyze collected evaluation data:

- **Frequency and Percentage: **Used to summarize respondent profiles and categorical checklist verification outcomes (Formula: P = (f / N) × 100, where f is frequency and N is total respondents).
- **Weighted Mean: **Used to compute average ratings per ISO/IEC 25010:2011 quality characteristic (Formula: WM = Σ(w × f) / N, where w is scale weight 1 to 5, f is frequency per rating, and N is total respondents). Table 4 presents the planned verbal interpretation scale.
- **System Usability Scale (SUS) Scoring Formula: **Following Brooke (1996), for each respondent: subtract 1 from the raw score of odd-numbered items (1, 3, 5, 7, 9), subtract the raw score from 5 for even-numbered items (2, 4, 6, 8, 10), sum all ten adjusted values, and multiply by 2.5 to obtain an individual score from 0 to 100. Mean SUS scores will be interpreted using the Bangor et al. (2009) adjective scale shown in Table 5.
*Table 4. Five-Point Likert Scale Verbal Interpretation for ISO/IEC 25010 Evaluation*

| Scale Weight | Mean Range | Verbal Interpretation |
| --- | --- | --- |
| 5 | 4.50 – 5.00 | Strongly Agree / Excellent |
| 4 | 3.50 – 4.49 | Agree / Very Good |
| 3 | 2.50 – 3.49 | Neutral / Good |
| 2 | 1.50 – 2.49 | Disagree / Fair |
| 1 | 1.00 – 1.49 | Strongly Disagree / Poor |

*Table 5. System Usability Scale (SUS) Adjective Rating Interpretation (Bangor et al., 2009)*

| SUS Score Range | Adjective Rating | Acceptability Interpretation |
| --- | --- | --- |
| 85.0 – 100.0 | Best Imaginable / Excellent | Acceptable |
| 71.4 – 84.9 | Good to Excellent | Acceptable |
| 50.9 – 71.3 | OK / Marginal | Marginal |
| 0.0 – 50.8 | Poor to Worst Imaginable | Not Acceptable |

## Proposed System Architecture / Design Layout

The proposed EJBL system follows a two-tier cloud-backed mobile architecture designed strictly for online internal operation (Figure 2 diagram to be inserted after schema finalization):

- **Presentation / Mobile Client Layer: **Cross-platform client application built using Flutter and Dart targeting Android and Web (Progressive Web App / PWA), implementing role-aware navigation (go_router) and state management (flutter_riverpod) across Log, Business Records, Inventory, Void Audit Log, Capital, and BIR Books, plus on-device PDF generation (pdf and printing packages) for the four BIR books.
- **Authentication and Authorization Layer: **Supabase Auth manages email/password login and JSON Web Token (JWT) sessions; PostgreSQL Row Level Security (RLS) enforces role permissions server-side for Employee/Staff, Manager, and Admin/Owner so authorization never relies solely on hidden UI controls.
- **Database and Business Logic Layer: **Supabase managed PostgreSQL database storing relational tables for products, FIFO stock batches, sales invoices (SI/NSI), line items, split payments, consignment contracts, expenses, capital entries, void audit logs, and BIR ledger entries. Critical multi-table operations—specifically FIFO batch deduction, automatic Log-to-Business Records creation, Restock-to-COGS linkage, and BIR ledger posting—will execute inside atomic PostgreSQL RPC transactions so related updates succeed or fail together.
- **Network and Security Layer: **All client-to-Supabase requests communicate over HTTPS/TLS. Only the public Supabase anon key is bundled in the mobile client; privileged rules live strictly inside PostgreSQL RLS policies and security-definer RPC functions.
*Table 6. Proposed Software and Hardware Requirements for EJBL*

| Component | Development Specification | Deployment / User Specification |
| --- | --- | --- |
| Mobile Frontend | Flutter & Dart (Android + Web PWA) | Android 10+ smartphone or modern Web browser (PWA) |
| Backend & Database | Supabase (PostgreSQL, Auth, RLS, SQL RPC) | Supabase Cloud (HTTPS online connection) |
| PDF Export | Flutter pdf & printing packages | Android / Web browser PDF viewer, download, share, or print |
| Development Hardware | Existing student laptops (min. 8 GB RAM) & test phones | Store owner & personnel smartphones with Wi-Fi / mobile data |

## System Diagrams and Logical Models

All technical diagrams share consistent internal-only boundaries (three internal actors: Employee/Staff, Manager, Admin/Owner; no external customer, supplier, or CPA logins). Final rendered diagrams will be inserted once the Supabase schema is locked in Sprint 1.

### Context Diagram and System Decomposition (Figure 3 — Placeholder)

The Context Diagram places the EJBL System at the center interacting exclusively with three internal entities: (1) Employee/Staff sends daily sales/expense Log entries and queries Inventory; (2) Manager sends Log edits, void/cancel requests, price overrides, and Inventory restocks while viewing Business Records; and (3) Admin/Owner manages users, Business Records, Capital, Void Audit review, manual BIR Book entries, and receives exported BIR Book PDFs. Suppliers and B2B consignment clients appear solely as internal data records, while the external bookkeeper/CPA reviews exported PDFs outside the system boundary.

### Data Flow Diagrams: Levels 0, 1, and 2 (Figure 4 — Placeholder)

- **DFD Level 0: **Decomposes EJBL into five core processes—(1.0) Authentication & Role Verification, (2.0) Daily Log Encoding & Auto-Posting, (3.0) FIFO Inventory & Consignment Management, (4.0) Business Records & Void Audit Tracking, and (5.0) BIR Books Posting & PDF Export—connected to unified PostgreSQL data stores.
- **DFD Level 1: **Details sub-processes within Log In/Out (SI continuous numbering from 1, NSI auto-generation, tiered price lookup, split payment recording), Inventory (receiving stock with puhunan/kg auto-creating COGS expense), and Consignment (immediate stock deduction vs. payment-triggered cashbook posting).
- **DFD Level 2 (FIFO Stock Deduction & BIR Ledger Posting): **Traces the atomic transaction path: verifying available batch quantities ordered by oldest intake date, splitting deductions across batches when a sale exceeds the oldest batch, computing exact batch COGS, recording Cashbook/Consignment balances, and posting balanced debit/credit entries to the General Ledger and Journals.
### Entity Relationship Diagram (ERD) — Proposed Core Schema (Figure 5 — Placeholder)

Table 7 summarizes the proposed normalized PostgreSQL entities that will be finalized into the rendered ERD and Supabase SQL migrations.

*Table 7. Proposed Core Database Entities and Relationships (ERD Summary)*

| Entity / Table | Key Attributes | Primary Relationships |
| --- | --- | --- |
| users / profiles | id (PK, UUID), full_name, role (staff/manager/admin), is_active | 1:N to sales, expenses, stock_batches, void_audit_logs, bir_entries |
| rice_varieties | id (PK), code (unique, e.g., CP, MC), name, wholesale_sack_price, retail_sack_price, retail_kg_price, ordering_point_kg | 1:N to stock_batches, sale_items |
| stock_batches | id (PK), rice_variety_id (FK), supplier_id (FK), received_date, initial_kg, remaining_kg, unit_cost_per_kg (puhunan), expense_id (FK) | N:1 to rice_varieties & suppliers; 1:1 link to auto-created COGS expense |
| suppliers & consignment_clients | id (PK), name, contact_info, payment_terms (for B2B consignment) | Internal reference tables only; 1:N to stock_batches / consignment_contracts |
| sales & sale_items | id (PK), invoice_type (SI/NSI), invoice_no, sale_date, fulfillment_type (pickup/delivery), delivery_fee, total_amount, status (active/voided), created_by (FK) | 1:N sales to sale_items; linked to FIFO batch deductions & cashbook |
| sale_payments | id (PK), sale_id (FK), method (cash/gcash/bank), amount, reference_no, paid_at | Supports cash, online, split payments, & partial/full consignment collections |
| expenses | id (PK), expense_date, invoice_no, category (OPEX/COGS/PERMIT/DRAW), description, payment_method, amount, status, created_by (FK) | Auto-linked from stock_batches (COGS) & feeds Business Records + CDJ |
| void_audit_logs | id (PK), record_type, record_id, original_snapshot (JSONB), reason, voided_by (FK), voided_at | Immutable audit log visible to Admin/Owner for every Manager void/cancel |
| capital_entries & bir_ledger_entries | id (PK), book_type (GL/CRJ/CDJ/GJ), entry_date, account_title, debit, credit, source_ref, is_manual_entry, edited_by (FK) | Auto-posted from sales, payments, expenses, & capital; editable by Admin |

### Use Case Diagram, UML Models, and System Workflow (Figure 6 — Placeholder)

Table 8 defines the exact role-to-use-case matrix governing the Use Case Diagram, UML Activity/Class diagrams, and System Flowchart.

*Table 8. Internal Role-Based Access Control (RBAC) and Use Case Matrix*

| System Capability / Use Case | Employee / Staff | Manager | Admin / Owner |
| --- | --- | --- | --- |
| Log In (Add & Save Sales — SI/NSI, Split Pay, Consignment) | Allowed | Allowed | Allowed |
| Log Out (Add & Save Expenses) | Allowed | Allowed | Allowed |
| Edit Log Records & Override Guide Prices | Denied | Allowed | Allowed |
| Void / Cancel Log Records (Stored in Audit Log) | Denied | Allowed | Allowed |
| Inventory — View Stock & Price Guide | Allowed | Allowed | Allowed |
| Inventory — Receive Stock (Auto COGS) & Manage Guide | Denied | Allowed | Allowed |
| Business Records (Cashbook & Expenses) | Denied | View-Only | Full Access |
| Void / Cancel Audit Log Review | Denied | View Own (Optional) | Full Review |
| Capital Section & 4 BIR Books (Auto + Manual Edit + PDF Export) | Denied | Denied | Full Access |

## Cost-Benefit Analysis

Table 9 summarizes the estimated one-time development costs for the proposed five-month capstone development period, adapted from Group 1's Project Proposal. All figures are estimates based on stated assumptions: unpaid student researcher labor, existing team laptops and smartphones used for development/testing, Supabase Free Tier during development, and an approximate exchange rate of ₱62 per USD. Post-deployment recurring operational costs (such as internet/mobile data plans, potential Supabase Pro upgrades if database usage grows, or custom web domain renewals if adopted long-term) will be borne separately by the business if adopted beyond capstone piloting.

*Table 9. Estimated Five-Month Development Cost Breakdown (Assumptions)*

| Cost Item | Basis / Assumption | Estimated Cost (PHP) |
| --- | --- | --- |
| Google Play Developer Account | One-time USD 25 fee (if publishing Android build) | ₱1,550.00 |
| Web / PWA Hosting (Static Web Build) | Free static hosting tier (native iOS App Store excluded) | ₱0.00 |
| Internet & Electricity (5 Months) | Estimated ₱1,500/month during development | ₱7,500.00 |
| Printing, Binding & Documentation | Manuscript drafts, evaluation sheets, final bound copies | ₱3,000.00 |
| Testing, Survey & Store Travel | Site visits to EJBL Bigasan in San Isidro, Rodriguez, Rizal | ₱3,000.00 |
| Supabase Backend (Development) | Supabase Free Plan during capstone build & pilot | ₱0.00 |
| Subtotal |  | ₱15,050.00 |
| Contingency Reserve (10%) | Buffer for miscellaneous project expenses | ₱1,505.00 |
| Total Estimated Development Cost | One-time capstone development estimate | ₱16,555.00 |

Expected operational benefits include eliminating duplicate encoding across five Excel sheets, eliminating manual handwriting into four physical BIR books, improving FIFO cost-of-goods-sold visibility, clarifying B2B consignment balances, and establishing traceable void/cancel accountability. Actual quantitative time and error reductions will only be reported after empirical baseline and post-implementation testing—no assumed percentage savings are claimed prior to evaluation.

## Ethical Considerations

This study adheres to research ethics standards and the Philippine Data Privacy Act of 2012 (Republic Act No. 10173). Specifically, the researchers will observe the following safeguards (exact PUP University Research Ethics Center requirements—referenced in the sample template as 'UREC 10 Ethics CIA'—remain pending adviser verification prior to formal ethics filing; no ethics approval has been obtained yet):

- **Informed Consent and Voluntary Participation: **Written informed consent will be obtained from the business owner, store personnel, and external IT and bookkeeping evaluators before interviews, observations, or surveys; participation is strictly voluntary with the right to withdraw without penalty.
- **Confidentiality and Financial Data Protection: **EJBL Bigasan's actual sales totals, supplier prices, consignment client balances, and financial records will be anonymized or aggregated in academic reporting where sensitive, and stored exclusively inside secured Supabase PostgreSQL databases protected by HTTPS and Row Level Security.
- **Credential Security and Data Minimization: **No real production passwords, private keys, or personal identification numbers will appear in source code, screenshots, or capstone appendices.
- **Research Integrity: **All operational records, software test outcomes, evaluation scores, and academic citations will be reported truthfully without fabrication or selective alteration.
## Gantt Chart

Table 10 presents the planned twenty-week (five-month) Agile development and research schedule. Dates and milestones are planned estimates subject to PUP adviser approval.

*Table 10. Planned Twenty-Week Agile Development Gantt Chart*

| Phase / Agile Sprint | Activities | Weeks 1–4 | Weeks 5–8 | Weeks 9–12 | Weeks 13–16 | Weeks 17–20 |
| --- | --- | --- | --- | --- | --- | --- |
| Planning & Proposal | Problem validation, Excel audit, Chapters 1–3 drafting & approval | XXXX |  |  |  |  |
| Sprint 1: Core & Inventory | Supabase schema, Auth/RLS, Inventory & Rice Price Guide |  | XXXX |  |  |  |
| Sprint 2: Log & Records | Log In/Out (SI/NSI), Auto Business Records, Void Audit Log |  |  | XXXX |  |  |
| Sprint 3: FIFO & Consignment | Atomic FIFO deduction, Restock-to-COGS, Consignment tracking |  |  |  | XXXX |  |
| Sprint 4: BIR Books & QA | 4 BIR Books + Capital, Owner edits, PDF export, QA & Testing |  |  |  | XX | XX |
| Evaluation & Final Paper | ISO/IEC 25010, SUS, Bookkeeper validation, Chapters 4–5 & Defense |  |  |  |  | XXXX |

---

**REFERENCES**

- Aghniya, A., Rivai, A. M., Febisatria, A., Harun, N., & Azza, N. (2025). Penerapan metode First In First Out (FIFO) dalam peningkatan kinerja operasional sektor ritel di Indonesia [Application of the First-In, First-Out method in improving operational performance in the retail sector in Indonesia]. Jurnal Akademik Ekonomi Dan Manajemen, 2(4), 181–192. https://doi.org/10.61722/jaem.v2i4.7265
- Bangor, A., Kortum, P., & Miller, J. (2009). Determining what individual SUS scores mean: Adding an adjective rating scale. Journal of Usability Studies, 4(3), 114–123.
- Brooke, J. (1996). SUS: A "quick and dirty" usability scale. In P. W. Jordan, B. Thomas, B. A. Weerdmeester, & I. L. McClelland (Eds.), Usability evaluation in industry (pp. 189–194). Taylor & Francis.
- Bureau of Internal Revenue. (2023). Revenue Memorandum Circular No. 3-2023: Guidelines on the online registration of books of accounts through the Online Registration and Update System (ORUS). Republic of the Philippines. https://www.bir.gov.ph
- Bureau of Internal Revenue. (2025). Revenue Memorandum Circular No. 65-2025: Clarifications on registration of books of accounts for new business registrants. Republic of the Philippines. https://www.bir.gov.ph
- Cadiao, M. A. B. (2025). Tax knowledge, bookkeeping practices, and financial performance of micro-enterprises: Basis for an enhanced tax compliance framework. International Journal of Research Studies in Management, 13(5), 181–190. https://doi.org/10.5861/ijrsm.2025.25068
- DeLone, W. H., & McLean, E. R. (2003). The DeLone and McLean model of information systems success: A ten-year update. Journal of Management Information Systems, 19(4), 9–30. https://doi.org/10.1080/07421222.2003.11045748
- Domingo, W. G., Gamay, J. A., Gonzales, V. C., & Malunao, S. S. (2026). QSUMeMarket: A decision support system framework for SMEs to process customer orders. International Journal of Informatics and Communication Technology, 15(3), 975–985. https://doi.org/10.11591/ijict.v15i3.pp975-985
- Fadillah, N. S., & Sutopo, J. (2023). Implementasi metode First In First Out (FIFO) dalam rancang bangun sistem informasi inventory pada Toko Channel Computer berbasis website [Implementation of the First-In, First-Out method in the design and development of a web-based inventory information system]. Indonesian Journal of Software Engineering, 9(1), 39–45. https://doi.org/10.31294/ijse.v9i1.16143
- Fitria, N. A., Jatiningsih, D. E. S., & Putri, C. M. (2024). Business sustainability, internal control and accounting information system: Evidence from culinary sector's MSME in Indonesia. SHS Web of Conferences, 201, 01013. https://doi.org/10.1051/shsconf/202420101013
- Gabriel, M. G. (2025). Inventory management practices of retailers in Santiago City. International Journal of Research and Scientific Innovation, 12(2), 857–864. https://doi.org/10.51244/IJRSI.2025.12020066
- Gibo, C., Sillar, L., Lindayao, B., Patoc, E. M., & Gonzales, M. (2026). Selling strategies and business practices of rice retailers: A qualitative study in a rural Philippine setting. Journal of Interdisciplinary Perspectives, 4(1), 123–128. https://doi.org/10.69569/jip.2025.722
- Goodhue, D. L., & Thompson, R. L. (1995). Task-technology fit and individual performance. MIS Quarterly, 19(2), 213–236. https://doi.org/10.2307/249689
- International Organization for Standardization. (2011). Systems and software engineering — Systems and software Quality Requirements and Evaluation (SQuaRE) — System and software quality models (ISO/IEC Standard No. 25010:2011).
- Nabila, T., Riyanto, P., Purwanto, E., & Permatasari, H. (2024). Sistem informasi inventory berbasis website menerapkan metode First In First Out pada Toko Draftsupply [Website-based inventory information system applying the First-In, First-Out method at Draftsupply Store]. JEKIN - Jurnal Teknik Informatika, 5(1), 24–35. https://doi.org/10.58794/jekin.v5i1.879
- Panigrahi, R. R., Shrivastava, A. K., & Nudurupati, S. S. (2024). Impact of inventory management on SME performance: A systematic review. International Journal of Productivity and Performance Management, 73(9), 2901–2925. https://doi.org/10.1108/IJPPM-08-2023-0428
- Rustendy, C. A. S., Nurlelasari, S., Rajagukguk, H., Pratama, D., & Sulistyowati, W. A. (2024). Digital bookkeeping adoption among MSMEs in Indonesia: Extension of Technology Acceptance Model. International Journal of Management, Accounting and Economics, 11(8), 990–1003. https://doi.org/10.5281/zenodo.13323188
- Sandhu, R. S., Coyne, E. J., Feinstein, H. L., & Youman, C. E. (1996). Role-based access control models. IEEE Computer, 29(2), 38–47. https://doi.org/10.1109/2.485845
- Tindage, J., Manurung, T., & Manuhutu, M. A. (2025). The effect of accounting information system implementation on internal control effectiveness in Sorong City MSMEs. International Journal of Health, Economics, and Social Sciences, 7(2). https://doi.org/10.56338/ijhess.v7i2.7351