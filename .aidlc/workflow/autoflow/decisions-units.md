# Decomposition Decisions

## Context Summary
- **Project**: Autoflow — Inventory, AP/AR & Document Flow system (No COA)
- **Type**: Greenfield
- **Stack**: TypeScript / Angular + NestJS / PostgreSQL
- **Stories**: 32 across 6 functional areas
- **User Types**: 6 (Cashier, Store Staff, Supervisor, Manager, CFO, Admin)
- **Scope**: MVP — Core TX Engine + Sales + Purchasing + Inventory + Count/Transfer/Write-off + ERROR alerts
- **Priority**: Inventory accuracy (Stock + MA) as foundation

---

## Decision Questions

### D2-1: Decomposition Strategy
**Question**: How should we decompose the 32 stories into units?
- 1) Domain-Driven — group by business domain boundaries **(Recommended)**
- 2) Layer-Based — group by technical layer (data, logic, UI)
- 3) User Journey-Based — group by user workflow
- 4) Other (please specify): _______

**Answer**: 1 — Domain-Driven

---

### D2-2: Number of Units
**Question**: How many units should we create?
- 1) 3 units — combine smaller domains
- 2) 4 units — balanced team distribution **(Recommended)**
- 3) 5+ units — fine-grained separation
- 4) Other (please specify): _______

**Answer**: 2 — 4 units (1 per team)

---

### D2-3: Unit Boundaries
**Question**: What are the proposed unit boundaries?
- 1) By TX flow: Core Engine / Sales / Purchasing / Warehouse+Reports
- 2) By data ownership: Master Data / Transactions / Warehouse / Reports **(Recommended)**
- 3) By user role: Admin / Cashier+Store / Supervisor+Manager / CFO+Reports
- 4) Other (please specify): _______

**Answer**: 2 — ข้อมูลหลัก (Master Data & Core Engine), ข้อมูลพื้นฐาน (Transactions — Sales + Purchasing + AP/AR), คลังสินค้า (Warehouse), รายงาน (Reports & Alerts)

---

### D2-4: Team Structure
**Question**: How are teams organized?
- 1) 4 teams, 1 unit per team — clear ownership **(Recommended)**
- 2) 2 teams, 2 units each — shared knowledge
- 3) 1 team, sequential delivery
- 4) Other (please specify): _______

**Answer**: 1 — 4 teams, 1 unit per team

---

### D2-5: Foundation Phase
**Question**: Should all teams build shared foundation together before splitting?
- 1) Yes — Foundation first (DB schema, TX Log, shared patterns, auth) then split **(Recommended)**
- 2) No — each team defines their own conventions
- 3) Minimal — only DB schema shared, rest per-team
- 4) Other (please specify): _______

**Answer**: 1 — Yes, Foundation first then split into units

---

### D2-6: Development Sequence
**Question**: In what order should units be developed after foundation?
- 1) Sequential: ข้อมูลหลัก → ข้อมูลพื้นฐาน → คลังสินค้า → รายงาน
- 2) Parallel where possible: ข้อมูลหลัก first, then ข้อมูลพื้นฐาน + คลังสินค้า parallel, then รายงาน **(Recommended)**
- 3) All parallel from start (risky — dependencies)
- 4) Other (please specify): _______

**Answer**: 2 — ข้อมูลหลัก first (core dependency), then ข้อมูลพื้นฐาน + คลังสินค้า in parallel, then รายงาน last

---

### D2-7: Delivery Mode
**Question**: How should units be delivered?
- 1) Incremental with Foundation — shared spec first, then per-unit design/tasks/implement **(Recommended)**
- 2) Incremental skip Foundation — conventions from brownfield codebase
- 3) Comprehensive — single design covering all units
- 4) Other (please specify): _______

**Answer**: 1 — Incremental with Foundation

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream phases: read ONLY this section. -->
- D2-1 Strategy: Domain-Driven
- D2-2 Units: 4 units (ข้อมูลหลัก, ข้อมูลพื้นฐาน, คลังสินค้า, รายงาน)
- D2-3 Boundaries: Master Data & Core Engine / Transactions (Sales+Purchasing+AP/AR) / Warehouse / Reports & Alerts
- D2-4 Teams: 4 teams, 1 unit per team
- D2-5 Foundation: Yes — all teams build shared foundation first
- D2-6 Sequence: ข้อมูลหลัก → (ข้อมูลพื้นฐาน + คลังสินค้า parallel) → รายงาน
- D2-7 Mode: Incremental with Foundation
