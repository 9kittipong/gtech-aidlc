# Requirements Decisions

## Context Summary
- **Project**: Autoflow — Inventory, AP/AR & Document Flow system (No COA)
- **Type**: Greenfield
- **Stack**: TypeScript / Angular + NestJS / PostgreSQL
- **Complexity**: High — 30+ TX types, 7 domains, 6 user types
- **Source**: System Specification at /Initial-requirement/Autoflow_SystemSpec_NoCOA.md
- **Key Domains**: TX Log Engine, Sales, Purchasing, Inventory/Warehouse, AP/AR, Accounting Export, Alerts/Approval

---

## Decision Questions

### D1-1: Feature Scope — What is included in this release?
**Question**: The system spec covers 10 major areas. Which scope should we target for the first release?
- 1) MVP — Core TX Engine + Sales + Purchasing + Inventory only (defer AP/AR matching, Mapping Table, Alerts)
- 2) Full Operational — All TX types, AP/AR, Warehouse Adjustments, Approval Workflow (defer Mapping Table export)
- 3) Complete System — Everything in the spec including Mapping Table export and Alert system **(Recommended)**
- 4) Other (please specify): _______

**Answer**: 
1
---

### D1-2: User Types & Personas — Who are the primary users?
**Question**: The spec identifies 6 user roles (Cashier, Store, Supervisor, Manager, CFO, Admin). Should we generate detailed personas for each?
- 1) Yes — Generate personas for all 6 roles (helps clarify approval workflows and UI needs) **(Recommended)**
- 2) Partial — Generate personas for key roles only (Cashier, Manager, Admin)
- 3) No — User roles are clear enough from the spec, skip personas
- 4) Other (please specify): _______

**Answer**: 
1
---

### D1-3: Job Order Flow — Which paths to implement?
**Question**: The spec defines 2 paths for Job Orders: Path A (via TEMP_DO) and Path B (direct Invoice). Which to include?
- 1) Both Path A and Path B — full dual-path flow as specified **(Recommended)**
- 2) Path B only (direct Invoice) — simpler, defer TEMP_DO flow
- 3) Path A only (via TEMP_DO) — covers the more complex case
- 4) Other (please specify): _______

**Answer**: 
1
---

### D1-4: Credit Note Types — Separate or phased?
**Question**: The spec mandates 5 distinct CN types (CN_SALES_RETURN, CN_SALES_PRICE, CN_RETURN, CN_PRICE_ADJ, AP_CN_DEBT). Implement all at once?
- 1) All 5 CN types in first release — spec mandates separate logic **(Recommended)**
- 2) Sales CNs first (CN_SALES_RETURN, CN_SALES_PRICE), Purchase CNs in phase 2
- 3) Only CN_SALES_RETURN and CN_RETURN (physical returns), defer price adjustments
- 4) Other (please specify): _______

**Answer**: 
1
---

### D1-5: Warehouse Adjustments — Full or partial?
**Question**: The spec defines 7 adjustment types (Count Up/Down, Write-down, Write-off, Transfer, Reclass, Cost Adj). Include all?
- 1) All 7 adjustment types — complete warehouse management **(Recommended)**
- 2) Core only — Count Up/Down + Transfer (defer Write-down, Write-off, Reclass, Cost Adj)
- 3) Count + Transfer + Write-off only (most common operations)
- 4) Other (please specify): _______

**Answer**: 
3
---

### D1-6: AP/AR System — Open Item matching approach?
**Question**: How should AP/AR payment matching work?
- 1) Manual matching — user selects which open items to apply payment to **(Recommended)**
- 2) Auto-match by invoice reference — system matches automatically
- 3) Both — auto-suggest with manual override
- 4) Other (please specify): _______

**Answer**: 
1
---

### D1-7: Approval Workflow — Implementation approach?
**Question**: The spec requires multi-level approval (Cashier → Supervisor → Manager → CFO). How to implement?
- 1) In-app workflow with notification — built-in approval queue per role **(Recommended)**
- 2) Simple status-based — TX stays DRAFT until approved user changes status
- 3) External integration — connect to existing approval system
- 4) Other (please specify): _______

**Answer**: 
2
---

### D1-8: Accounting Export (Mapping Table) — Include in first release?
**Question**: The Mapping Table translates TX types to journal entries for external accounting. Include now?
- 1) Yes — full Mapping Table CRUD + batch export **(Recommended)**
- 2) Mapping Table config only — no actual export yet (prepare for phase 2)
- 3) Defer entirely — focus on operational system first
- 4) Other (please specify): _______

**Answer**: 
3
---

### D1-9: Alert System — Scope of alerts?
**Question**: The spec defines ERROR, WARNING, and INFO level alerts. What scope?
- 1) All levels — ERROR (blocking) + WARNING (notification) + INFO (dashboard) **(Recommended)**
- 2) ERROR only — critical business rule violations that block operations
- 3) ERROR + WARNING — skip INFO level for now
- 4) Other (please specify): _______

**Answer**: 
2
---

### D1-10: Multi-company Support — Include from start?
**Question**: The Mapping Table spec mentions `company_id` for multi-company support. Include now?
- 1) Single company first — add multi-company later (simpler data model) **(Recommended)**
- 2) Multi-company from start — future-proof the data model
- 3) Multi-company data model but single-company UI (prepare schema, defer UI)
- 4) Other (please specify): _______

**Answer**: 
1
---

### D1-11: Dev Notes Decisions — Resolve open questions from spec?
**Question**: The spec has 6 open questions (Q1-Q6). Should we resolve them now based on recommendations?
- 1) Yes — use spec's recommended options (Option A for Q1/Q2, In-app for Q3, Batch for Q4, No multi-currency for Q5, Cycle Count for Q6) **(Recommended)**
- 2) Resolve Q1-Q4 now, defer Q5-Q6 to design phase
- 3) Defer all to design phase
- 4) Other (please specify): _______

**Answer**: 
1
---

### D1-12: Priority Focus — What is most critical for go-live?
**Question**: If we must prioritize, which functional areas are highest priority?
- 1) Sales flow (JO → Invoice → AR) — revenue-generating operations first **(Recommended)**
- 2) Purchasing flow (PO → GR → AP) — cost control first
- 3) Both Sales + Purchasing equally — they depend on each other
- 4) Inventory accuracy (Stock + MA) — foundation for everything else
- 5) Other (please specify): _______

**Answer**: 
4
---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream phases: read ONLY this section. -->
<!-- Auto-populated after user fills answers. One line per decision. -->
- D1-1 Scope: MVP — Core TX Engine + Sales + Purchasing + Inventory only (defer AP/AR matching, Mapping Table, Alerts)
- D1-2 Personas: Yes — Generate personas for all 6 roles
- D1-3 JO Flow: Both Path A and Path B — full dual-path flow
- D1-4 CN Types: All 5 CN types in first release
- D1-5 Adjustments: Count + Transfer + Write-off only (most common operations)
- D1-6 AP/AR Matching: Manual matching — user selects which open items to apply payment to
- D1-7 Approval: Simple status-based — TX stays DRAFT until approved user changes status
- D1-8 Mapping Table: Defer entirely — focus on operational system first
- D1-9 Alerts: ERROR only — critical business rule violations that block operations
- D1-10 Multi-company: Single company first
- D1-11 Dev Notes: Yes — use spec's recommended options (ar_clearing_amount in TX, Direct write-down, In-app approval, Batch export, No multi-currency, Cycle Count)
- D1-12 Priority: Inventory accuracy (Stock + MA) — foundation for everything else

---

**Instructions**: Fill in your answers above and respond with "done"
