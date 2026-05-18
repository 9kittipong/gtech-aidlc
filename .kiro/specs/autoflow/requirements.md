# Requirements

## Summary
- **Total Stories**: 32 across 6 functional areas
- **Priority**: 12 High, 14 Medium, 6 Low
- **User Types**: Cashier, Store Staff, Supervisor, Manager, CFO, Admin
- **Key Entities**: TX Log, Item/Stock, Job Order, Invoice/CN, Vendor/Customer
- **Integrations**: None in MVP (Mapping Table export deferred)
- **Core Flows**: 
  - GR_RECEIVE → Stock + MA update → AP creation
  - JOB_ORDER → TEMP_DO/SALE_INVOICE → AR creation
  - GR_RETURN → CN_RETURN → AP reduction + PPV
  - Sales Return → CN_SALES_RETURN → Stock + AR reduction
  - Stock Count → ADJ_COUNT_UP/DOWN → MA recalculation

## Overview
User stories organized by functional area with EARS notation acceptance criteria. Scope is MVP: Core TX Engine + Sales + Purchasing + Inventory. Warehouse adjustments limited to Count, Transfer, and Write-off. Simple status-based approval. ERROR-level alerts only.

---

## Functional Area 1: Core TX Engine & Stock Management

### US-001: Create Transaction Log Entry
**As a** system
**I want** every business operation to create an immutable TX Log entry with all mandatory fields
**So that** there is a complete audit trail and financial accuracy is maintained

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** any business operation is executed, **THEN** the system SHALL create a TX Log entry with all Identity, Reference Chain, Stock & Cost, AP/AR, VAT, and Audit fields populated
2. **WHEN** a TX is POSTed, **THEN** the system SHALL set status to POSTED and the entry SHALL become immutable (no UPDATE or DELETE allowed)
3. **IF** any mandatory field is missing, **THEN** the system SHALL reject the POST and return a validation error
4. **WHEN** a TX status is POSTED, **IF** any attempt is made to UPDATE qty, cost, or status fields, **THEN** the system SHALL throw an error "TX ที่ POST แล้วต้องเป็น Immutable"

**Dependencies**: None
**Source**: Spec Section 01 — TX Log Structure

---

### US-002: Moving Average Calculation
**As a** system
**I want** to calculate Moving Average (MA) correctly for every stock-affecting transaction
**So that** inventory valuation is always accurate at point-in-time

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** a stock-increasing TX is POSTed (GR_RECEIVE, GR_REPLACEMENT, CN_SALES_RETURN, ADJ_COUNT_UP), **THEN** the system SHALL recalculate MA = (existing total value + new value) ÷ (existing qty + new qty)
2. **WHEN** a stock-decreasing TX is POSTed (SALE_INVOICE, TEMP_DO, GR_RETURN, ADJ_COUNT_DOWN, ADJ_WRITEOFF), **THEN** the system SHALL use current MA for cost calculation and MA SHALL NOT change
3. **WHEN** any TX is POSTed, **THEN** the system SHALL record `ma_before` and `ma_after` in the TX Log entry
4. **The system SHALL** never recalculate MA retroactively for previously POSTed transactions

**Dependencies**: US-001
**Source**: Spec Section 01 — MA Calculation Rules

---

### US-003: Stock Balance Validation (No Negative Stock)
**As a** system
**I want** to prevent any transaction from causing negative stock
**So that** inventory data integrity is always maintained

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** a stock-decreasing TX is about to POST, **IF** `stock_before - qty < 0`, **THEN** the system SHALL throw an error and reject the POST
2. **WHEN** stock validation fails, **THEN** the system SHALL display "Stock ติดลบ" error with item_id, warehouse_id, current stock, and requested qty
3. **The system SHALL** validate stock availability within the same atomic transaction as the POST operation

**Dependencies**: US-001
**Source**: Spec Section 09 — Business Rules (ห้าม Stock ติดลบ)

---

### US-004: Period Lock Enforcement
**As a** system
**I want** to prevent POSTing transactions in closed accounting periods
**So that** financial period integrity is maintained

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** any TX is about to POST, **THEN** the system SHALL check the period status for the TX's `period` field
2. **IF** the period status is CLOSED, **THEN** the system SHALL reject the POST with error "ห้าม POST ใน Period ที่ปิดแล้ว"
3. **WHEN** a period is closed, **THEN** no new TX can be POSTed with that period value regardless of TX type

**Dependencies**: US-001
**Source**: Spec Section 09 — Business Rules (Period Lock)

---

### US-005: VOID Transaction
**As a** Manager or higher role
**I want** to void a POSTed transaction by creating a reverse entry
**So that** errors can be corrected without deleting audit trail

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** a VOID is requested for a POSTed TX, **THEN** the system SHALL create a new TX with all values negated (opposite sign)
2. **WHEN** a VOID TX is created, **THEN** the system SHALL set `parent_tx_id` to reference the original TX and set original TX status to VOIDED
3. **IF** the VOID affects stock, **THEN** MA SHALL be recalculated based on the reverse movement
4. **WHEN** a VOID is requested, **IF** no reason is provided, **THEN** the system SHALL reject the request
5. **The system SHALL** never DELETE any TX — only VOID

**Dependencies**: US-001, US-002
**Source**: Spec Section 09 — Business Rules (VOID pattern)

---

### US-006: Reference Chain Validation
**As a** system
**I want** to validate reference chain integrity before POSTing any transaction
**So that** document relationships are always traceable and valid

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** a CN is about to POST, **IF** no valid Invoice reference exists, **THEN** the system SHALL reject with "CN ต้องมี Invoice อ้างอิง"
2. **WHEN** a GR_RETURN is about to POST, **IF** no valid GR_RECEIVE reference exists, **THEN** the system SHALL reject
3. **WHEN** an INVOICE_FROM_DO is about to POST, **IF** no valid TEMP_DO reference exists, **THEN** the system SHALL reject
4. **The system SHALL** validate all `ref_*` fields against existing POSTed transactions before allowing POST

**Dependencies**: US-001
**Source**: Spec Section 09 — Business Rules (Validate Reference Chain)

---

### US-007: Simple Status-Based Approval
**As a** user with appropriate role
**I want** transactions requiring approval to stay in DRAFT until an authorized user approves
**So that** business controls are enforced without complex workflow

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** a TX requiring approval is created, **THEN** the system SHALL set status to DRAFT
2. **WHILE** a TX is in DRAFT status, **IF** a user with the required approval role reviews it, **THEN** the system SHALL allow them to change status to POSTED
3. **IF** a user without the required role attempts to POST a TX requiring approval, **THEN** the system SHALL reject with "ไม่มีสิทธิ์อนุมัติ"
4. **WHEN** a TX is approved, **THEN** the system SHALL record `approved_by` and approval timestamp

**Dependencies**: US-001
**Source**: D1-7 Decision (Simple status-based approval)

---

## Functional Area 2: Sales Flow (Job Order → Invoice → AR)

### US-008: Create Job Order
**As a** Cashier
**I want** to create a Job Order to track service/repair work
**So that** work can be tracked from start to invoicing

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** a new Job Order is created, **THEN** the system SHALL set status to OPEN, `has_temp_do=false`, `invoice_id=null`
2. **WHEN** a Job Order status changes, **THEN** it SHALL follow the sequence: OPEN → IN_PROGRESS → DONE
3. **The system SHALL** not create a TX Log entry for the Job Order itself (it is a tracking document only)

**Dependencies**: None
**Source**: Spec Section 03 — JOB_ORDER

---

### US-009: Issue TEMP_DO (Path A)
**As a** Cashier
**I want** to issue a Temporary Delivery Order from a completed Job Order
**So that** goods can be delivered before the formal invoice is issued

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** a TEMP_DO is created from a JOB_ORDER, **IF** JO status is not DONE, **THEN** the system SHALL reject with "ใบสั่งงานยังไม่เสร็จ"
2. **WHEN** a TEMP_DO is created, **IF** the JO already has a TEMP_DO (`has_temp_do=true`), **THEN** the system SHALL reject with "ห้าม TEMP_DO มากกว่า 1 ใบต่อ JOB_ORDER"
3. **WHEN** a TEMP_DO is POSTed, **THEN** the system SHALL: cut stock at current MA, record `cogs_unit`, create AR (base_amount + vat_amount), record VAT OUTPUT
4. **WHEN** a TEMP_DO is POSTed, **THEN** the system SHALL update JO: `has_temp_do=true`, `temp_do_id=DO-xxx`
5. **WHEN** a TEMP_DO is about to POST, **IF** stock is insufficient, **THEN** the system SHALL reject

**Dependencies**: US-001, US-002, US-003, US-008
**Source**: Spec Section 03 — Path A TEMP_DO

---

### US-010: Issue Invoice from TEMP_DO (Path A — INVOICE_FROM_DO)
**As a** Cashier
**I want** to issue a formal tax invoice from an existing TEMP_DO
**So that** the customer receives an official tax document

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** an invoice is requested for a JO with `has_temp_do=true`, **THEN** the system SHALL automatically set TX type to INVOICE_FROM_DO
2. **WHEN** INVOICE_FROM_DO is created, **THEN** `qty=0`, `total_cost=0`, `ar_amount=0` (no stock cut, no new AR)
3. **WHEN** INVOICE_FROM_DO is POSTed, **THEN** the system SHALL issue a formal `tax_invoice_no` and inherit VAT from the TEMP_DO TX
4. **IF** the JO already has an invoice (`invoice_id != null`), **THEN** the system SHALL reject with "มีใบเสร็จแล้ว ห้ามออกซ้ำ"
5. **The system SHALL** never allow users to manually select TX type — it must be determined automatically from `has_temp_do`

**Dependencies**: US-009
**Source**: Spec Section 03 — INVOICE_FROM_DO

---

### US-011: Issue Direct Sale Invoice (Path B — SALE_INVOICE)
**As a** Cashier
**I want** to issue a direct sale invoice from a completed Job Order without TEMP_DO
**So that** sales can be processed in a single step when immediate delivery isn't needed

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** an invoice is requested for a JO with `has_temp_do=false`, **THEN** the system SHALL automatically set TX type to SALE_INVOICE
2. **WHEN** SALE_INVOICE is POSTed, **THEN** the system SHALL: cut stock at current MA, record `cogs_unit`, create AR (base + vat), issue `tax_invoice_no`, record VAT OUTPUT
3. **IF** the JO status is not DONE, **THEN** the system SHALL reject
4. **IF** a JO has `has_temp_do=true`, **THEN** the system SHALL never allow SALE_INVOICE (would cause double stock cut and double AR)
5. **WHEN** SALE_INVOICE is about to POST, **IF** stock is insufficient, **THEN** the system SHALL reject

**Dependencies**: US-001, US-002, US-003, US-008
**Source**: Spec Section 03 — Path B, Spec Section 04

---

### US-012: Sales Credit Note — Return (CN_SALES_RETURN)
**As a** Supervisor
**I want** to process customer returns with proper stock and AR adjustment
**So that** returned goods are correctly valued and customer balance is reduced

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** CN_SALES_RETURN is created, **THEN** it SHALL reference the original Tax Invoice
2. **WHEN** CN_SALES_RETURN is POSTed with condition "good", **THEN** the system SHALL receive stock at original `cogs_unit` from the referenced sale TX and recalculate MA
3. **WHEN** CN_SALES_RETURN is POSTed with condition "damaged_total", **THEN** the system SHALL record Loss only (no stock increase)
4. **WHEN** CN_SALES_RETURN is POSTed, **THEN** AR SHALL decrease and VAT OUTPUT SHALL be reversed
5. **IF** the CN references an INVOICE_FROM_DO, **THEN** the system SHALL traverse to TEMP_DO to get `cogs_unit`
6. **IF** return qty exceeds original sale qty, **THEN** the system SHALL reject

**Dependencies**: US-001, US-002, US-009, US-011
**Source**: Spec Section 04 — CN_SALES_RETURN

---

### US-013: Sales Credit Note — Price Adjustment (CN_SALES_PRICE)
**As a** Manager
**I want** to issue a price reduction credit note without affecting inventory
**So that** customer discounts/adjustments are properly recorded

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** CN_SALES_PRICE is created, **THEN** it SHALL reference the original Tax Invoice and require a reason
2. **WHEN** CN_SALES_PRICE is POSTed, **THEN** AR SHALL decrease, Revenue SHALL decrease, VAT OUTPUT SHALL be reversed
3. **WHEN** CN_SALES_PRICE is POSTed, **THEN** Inventory and MA SHALL NOT be affected
4. **IF** no reason is provided, **THEN** the system SHALL reject the CN
5. **WHILE** TX status is DRAFT, **IF** a Manager approves, **THEN** the system SHALL allow POST

**Dependencies**: US-001, US-007
**Source**: Spec Section 04 — CN_SALES_PRICE

---

### US-014: AR Payment Receipt (AR_RECEIVE)
**As a** Cashier
**I want** to record customer payments and match them to open AR items
**So that** customer balances are accurately tracked

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** AR_RECEIVE is created, **THEN** the user SHALL manually select which open AR items to apply payment to
2. **WHEN** AR_RECEIVE is POSTed, **IF** payment fully covers the open item, **THEN** AR status SHALL change to CLOSED
3. **WHEN** AR_RECEIVE is POSTed, **IF** payment partially covers the open item, **THEN** AR status SHALL change to PARTIAL
4. **IF** payment amount exceeds total open AR balance, **THEN** the system SHALL reject

**Dependencies**: US-001, US-009, US-011
**Source**: Spec Section 07 — AR Open Item, D1-6 (Manual matching)

---

## Functional Area 3: Purchasing Flow (GR → Return → CN)

### US-015: Goods Receipt (GR_RECEIVE)
**As a** Store Staff
**I want** to record goods received from suppliers with proper cost and tax documentation
**So that** stock is updated, MA is recalculated, and AP is created

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** GR_RECEIVE is POSTed, **THEN** the system SHALL: increase stock by qty, recalculate MA, create AP (unit_cost × qty + VAT), record VAT INPUT
2. **WHEN** GR_RECEIVE is created, **THEN** `tax_invoice_no` SHALL be mandatory
3. **WHEN** GR_RECEIVE is POSTed, **THEN** the system SHALL record `ma_before` and `ma_after`
4. **IF** Landed Cost is specified, **THEN** the system SHALL distribute it across unit_cost before POST
5. **IF** the referenced PO does not have status Approved, **THEN** the system SHALL reject

**Dependencies**: US-001, US-002
**Source**: Spec Section 05 — GR_RECEIVE

---

### US-016: Goods Return to Supplier (GR_RETURN)
**As a** Supervisor
**I want** to return goods to a supplier with proper stock and clearing account tracking
**So that** returned goods are removed from inventory and a clearing balance is created for CN settlement

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** GR_RETURN is POSTed, **THEN** the system SHALL: decrease stock by qty × current MA (not GR cost), open `gr_ir_return_clearing` = qty × ma_before
2. **WHEN** GR_RETURN is POSTed, **THEN** MA SHALL NOT change
3. **WHEN** GR_RETURN is created, **THEN** it SHALL store `ref_gr_id` for CN inheritance
4. **IF** stock is insufficient for the return qty, **THEN** the system SHALL reject
5. **IF** the referenced GR has already been fully returned, **THEN** the system SHALL reject

**Dependencies**: US-001, US-002, US-003, US-015
**Source**: Spec Section 05 — GR_RETURN

---

### US-017: Goods Replacement (GR_REPLACEMENT)
**As a** Store Staff
**I want** to receive replacement goods from a supplier at zero invoice value
**So that** returned goods are replaced without additional AP

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** GR_REPLACEMENT is POSTed, **THEN** the system SHALL: increase stock at the value from GR/IR Return Clearing, recalculate MA, create no AP
2. **WHEN** GR_REPLACEMENT is POSTed, **THEN** the system SHALL automatically close the `gr_ir_return_clearing` balance
3. **WHEN** GR_REPLACEMENT is POSTed, **THEN** VAT INPUT SHALL be recorded

**Dependencies**: US-001, US-002, US-016
**Source**: Spec Section 05 — GR_REPLACEMENT

---

### US-018: Purchase CN — Return (CN_RETURN)
**As a** Manager
**I want** to issue a credit note for goods returned to supplier
**So that** AP is reduced and GR/IR clearing is settled with PPV

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** CN_RETURN is created, **THEN** it SHALL automatically inherit `ref_gr_id` from GR_RETURN and `tax_invoice_no` from GR_RECEIVE
2. **WHEN** CN_RETURN is POSTed, **THEN** the system SHALL: reduce AP by invoice price (unit_cost × qty), calculate PPV = GR/IR Clearing − AP reduction, close `gr_ir_return_clearing`, reverse VAT INPUT
3. **WHEN** CN_RETURN is POSTed, **THEN** Inventory SHALL NOT be affected (goods already left in GR_RETURN)
4. **IF** CN_RETURN attempts to modify any inventory field, **THEN** the system SHALL throw an error

**Dependencies**: US-001, US-016
**Source**: Spec Section 05 — CN_RETURN

---

### US-019: Purchase CN — Price Adjustment (CN_PRICE_ADJ)
**As a** Manager
**I want** to adjust the purchase price when supplier invoice differs from GR
**So that** inventory value and AP are corrected

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** CN_PRICE_ADJ is created, **THEN** it SHALL reference the original GR_RECEIVE
2. **WHEN** CN_PRICE_ADJ is POSTed, **THEN** the system SHALL: check remaining stock from that GR, reduce Inventory for remaining portion, record `cogs_adj_amount` for sold portion, reduce AP, reverse VAT INPUT
3. **WHEN** CN_PRICE_ADJ affects remaining stock, **THEN** MA SHALL be recalculated
4. **IF** the period is closed, **THEN** the system SHALL reject the POST

**Dependencies**: US-001, US-002, US-004, US-015
**Source**: Spec Section 05 — CN_PRICE_ADJ

---

### US-020: Purchase CN — Debt Only (AP_CN_DEBT)
**As a** Manager
**I want** to issue a credit note that only reduces AP without affecting inventory
**So that** discounts, penalties, and fee adjustments are properly recorded

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** AP_CN_DEBT is created, **THEN** it SHALL reference the original Invoice and require a reason
2. **WHEN** AP_CN_DEBT is POSTed, **THEN** AP SHALL decrease, VAT INPUT SHALL be reversed
3. **WHEN** AP_CN_DEBT is POSTed, **THEN** Inventory and MA SHALL NOT be affected
4. **IF** no reason is provided, **THEN** the system SHALL reject

**Dependencies**: US-001, US-015
**Source**: Spec Section 05 — AP_CN_DEBT

---

### US-021: AP Payment (AP_PAYMENT)
**As a** Manager
**I want** to record payments to suppliers and match them to open AP items
**So that** supplier balances are accurately tracked

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** AP_PAYMENT is created, **THEN** the user SHALL manually select which open AP items to apply payment to
2. **WHEN** AP_PAYMENT is POSTed, **IF** payment fully covers the open item, **THEN** AP status SHALL change to CLOSED
3. **WHEN** AP_PAYMENT is POSTed, **IF** payment partially covers the open item, **THEN** AP status SHALL change to PARTIAL

**Dependencies**: US-001, US-015
**Source**: Spec Section 07 — AP Open Item, D1-6 (Manual matching)

---

## Functional Area 4: Warehouse Adjustments

### US-022: Stock Count — Adjustment Up (ADJ_COUNT_UP)
**As a** Supervisor
**I want** to record stock count increases after physical inventory
**So that** system stock matches physical count

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** ADJ_COUNT_UP is POSTed, **THEN** the system SHALL: increase stock by qty, recalculate MA
2. **WHEN** ADJ_COUNT_UP is created, **THEN** a Reason Code SHALL be mandatory
3. **WHILE** a stock count is in progress (frozen), **IF** any other stock-affecting TX is attempted for the same item+warehouse, **THEN** the system SHALL reject with "Stock frozen during count"
4. **WHEN** ADJ_COUNT_UP requires approval, **THEN** approval level SHALL be determined by value threshold (< 1,000 = Supervisor, 1,000-10,000 = Manager, > 10,000 = CFO)

**Dependencies**: US-001, US-002, US-007
**Source**: Spec Section 06 — ADJ_COUNT_UP, Approval Threshold table

---

### US-023: Stock Count — Adjustment Down (ADJ_COUNT_DOWN)
**As a** Supervisor
**I want** to record stock count decreases after physical inventory
**So that** system stock matches physical count

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** ADJ_COUNT_DOWN is POSTed, **THEN** the system SHALL: decrease stock by qty at current MA, MA SHALL NOT change
2. **WHEN** ADJ_COUNT_DOWN is created, **THEN** a Reason Code SHALL be mandatory
3. **WHILE** a stock count is in progress, **IF** any other stock-affecting TX is attempted, **THEN** the system SHALL reject
4. **IF** the adjustment would cause negative stock, **THEN** the system SHALL reject
5. **WHEN** ADJ_COUNT_DOWN requires approval, **THEN** approval level SHALL follow the same threshold as ADJ_COUNT_UP

**Dependencies**: US-001, US-002, US-003, US-007
**Source**: Spec Section 06 — ADJ_COUNT_DOWN

---

### US-024: Stock Transfer (ADJ_TRANSFER)
**As a** Supervisor
**I want** to transfer stock between warehouses
**So that** inventory is properly tracked across locations

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** ADJ_TRANSFER is POSTed, **THEN** the system SHALL: decrease stock at source warehouse (MA unchanged), increase stock at destination warehouse (MA recalculated)
2. **WHEN** ADJ_TRANSFER is in transit, **THEN** the system SHALL track IN_TRANSIT status
3. **WHEN** destination receives the transfer, **THEN** destination MA SHALL be recalculated from existing stock + incoming value
4. **IF** source warehouse has insufficient stock, **THEN** the system SHALL reject

**Dependencies**: US-001, US-002, US-003, US-007
**Source**: Spec Section 06 — ADJ_TRANSFER

---

### US-025: Stock Write-off (ADJ_WRITEOFF)
**As a** CFO
**I want** to write off damaged or obsolete inventory
**So that** inventory reflects only usable stock

**Priority**: Low

**Acceptance Criteria**:
1. **WHEN** ADJ_WRITEOFF is POSTed, **THEN** the system SHALL: decrease stock at current MA, record Loss on Write-off, MA SHALL NOT change
2. **WHEN** ADJ_WRITEOFF is created, **THEN** evidence of destruction SHALL be mandatory (attachment)
3. **WHEN** ADJ_WRITEOFF is created, **THEN** CFO approval SHALL be required
4. **IF** salvage value exists, **THEN** the system SHALL record Salvage Inventory separately

**Dependencies**: US-001, US-002, US-003, US-007
**Source**: Spec Section 06 — ADJ_WRITEOFF

---

## Functional Area 5: AP/AR Open Item Management

### US-026: AP Open Item Lifecycle
**As a** system
**I want** every AP-creating TX to generate an Open Item with lifecycle tracking
**So that** supplier balances are always accurate

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** GR_RECEIVE is POSTed, **THEN** the system SHALL create an AP Open Item with status OPEN
2. **WHEN** AP_PAYMENT is applied to an open item, **IF** fully paid, **THEN** status SHALL change to CLOSED
3. **WHEN** a CN reduces AP for an open item, **IF** partially reduced, **THEN** status SHALL change to PARTIAL
4. **The system SHALL** track `ap_ar_status` (OPEN | PARTIAL | CLOSED) for every AP-affecting TX

**Dependencies**: US-001, US-015
**Source**: Spec Section 07 — AP Open Item

---

### US-027: AR Open Item Lifecycle
**As a** system
**I want** every AR-creating TX to generate an Open Item with lifecycle tracking
**So that** customer balances are always accurate

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** SALE_INVOICE or TEMP_DO is POSTed, **THEN** the system SHALL create an AR Open Item with status OPEN
2. **WHEN** AR_RECEIVE is applied to an open item, **IF** fully paid, **THEN** status SHALL change to CLOSED
3. **WHEN** a Sales CN reduces AR for an open item, **IF** partially reduced, **THEN** status SHALL change to PARTIAL
4. **The system SHALL** track `ap_ar_status` (OPEN | PARTIAL | CLOSED) for every AR-affecting TX

**Dependencies**: US-001, US-009, US-011
**Source**: Spec Section 07 — AR Open Item

---

## Functional Area 6: Error Alerts & System Validation

### US-028: ERROR Alert — Stock Negative Prevention
**As a** system
**I want** to throw a blocking error before any POST that would cause negative stock
**So that** data integrity is never compromised

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** any stock-decreasing TX is about to POST, **IF** result would be negative, **THEN** the system SHALL throw ERROR and block the operation
2. **WHEN** ERROR is thrown, **THEN** the system SHALL log the error with TX details, item_id, warehouse_id, and attempted qty

**Dependencies**: US-003
**Source**: Spec Section 10 — ERROR alerts

---

### US-029: ERROR Alert — CN_RETURN Inventory Protection
**As a** system
**I want** to throw a blocking error if CN_RETURN attempts to modify inventory fields
**So that** the business rule "CN_RETURN ไม่แตะ Inventory" is enforced

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** CN_RETURN TX has any non-zero inventory field (qty, stock change), **THEN** the system SHALL throw ERROR and block POST
2. **WHEN** ERROR is thrown, **THEN** the system SHALL log "CN_RETURN แตะ Inventory Fields" with TX details

**Dependencies**: US-018
**Source**: Spec Section 10 — ERROR alerts

---

### US-030: ERROR Alert — Duplicate Invoice Prevention
**As a** system
**I want** to prevent issuing duplicate invoices from the same Job Order
**So that** revenue is not double-counted

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** an invoice is requested for a JO that already has `invoice_id != null`, **THEN** the system SHALL throw ERROR "Invoice ออกซ้ำจาก JO เดิม"
2. **WHEN** SALE_INVOICE is requested for a JO with `has_temp_do=true`, **THEN** the system SHALL throw ERROR "ห้ามสร้าง SALE_INVOICE จาก JO ที่มี TEMP_DO"

**Dependencies**: US-008, US-009, US-010, US-011
**Source**: Spec Section 10 — ERROR alerts

---

### US-031: ERROR Alert — INVOICE_FROM_DO Stock Protection
**As a** system
**I want** to throw a blocking error if INVOICE_FROM_DO attempts to cut stock
**So that** the business rule "INVOICE_FROM_DO is document-only" is enforced

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** INVOICE_FROM_DO TX has non-zero qty or total_cost, **THEN** the system SHALL throw ERROR and block POST
2. **WHEN** INVOICE_FROM_DO TX has non-zero ar_amount, **THEN** the system SHALL throw ERROR and block POST

**Dependencies**: US-010
**Source**: Spec Section 10 — ERROR alerts

---

### US-032: ERROR Alert — Period Lock Violation
**As a** system
**I want** to throw a blocking error when POST is attempted in a closed period
**So that** financial period integrity is maintained

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** any TX POST is attempted with a period that is CLOSED, **THEN** the system SHALL throw ERROR "POST ใน Period ที่ปิดแล้ว"
2. **WHEN** ERROR is thrown, **THEN** the system SHALL log the attempt with user, TX type, and period

**Dependencies**: US-004
**Source**: Spec Section 10 — ERROR alerts

---

## Story Summary

| ID | Title | Area | Priority | Dependencies |
|----|-------|------|----------|--------------|
| US-001 | Create Transaction Log Entry | Core TX Engine | High | None |
| US-002 | Moving Average Calculation | Core TX Engine | High | US-001 |
| US-003 | Stock Balance Validation | Core TX Engine | High | US-001 |
| US-004 | Period Lock Enforcement | Core TX Engine | High | US-001 |
| US-005 | VOID Transaction | Core TX Engine | High | US-001, US-002 |
| US-006 | Reference Chain Validation | Core TX Engine | High | US-001 |
| US-007 | Simple Status-Based Approval | Core TX Engine | Medium | US-001 |
| US-008 | Create Job Order | Sales Flow | High | None |
| US-009 | Issue TEMP_DO (Path A) | Sales Flow | High | US-001, US-002, US-003, US-008 |
| US-010 | Issue Invoice from TEMP_DO | Sales Flow | High | US-009 |
| US-011 | Issue Direct Sale Invoice | Sales Flow | High | US-001, US-002, US-003, US-008 |
| US-012 | Sales CN — Return | Sales Flow | Medium | US-001, US-002, US-009, US-011 |
| US-013 | Sales CN — Price Adjustment | Sales Flow | Medium | US-001, US-007 |
| US-014 | AR Payment Receipt | Sales Flow | Medium | US-001, US-009, US-011 |
| US-015 | Goods Receipt (GR_RECEIVE) | Purchasing Flow | High | US-001, US-002 |
| US-016 | Goods Return (GR_RETURN) | Purchasing Flow | Medium | US-001, US-002, US-003, US-015 |
| US-017 | Goods Replacement | Purchasing Flow | Medium | US-001, US-002, US-016 |
| US-018 | Purchase CN — Return | Purchasing Flow | Medium | US-001, US-016 |
| US-019 | Purchase CN — Price Adj | Purchasing Flow | Medium | US-001, US-002, US-004, US-015 |
| US-020 | Purchase CN — Debt Only | Purchasing Flow | Medium | US-001, US-015 |
| US-021 | AP Payment | Purchasing Flow | Medium | US-001, US-015 |
| US-022 | Stock Count — Up | Warehouse Adj | Medium | US-001, US-002, US-007 |
| US-023 | Stock Count — Down | Warehouse Adj | Medium | US-001, US-002, US-003, US-007 |
| US-024 | Stock Transfer | Warehouse Adj | Medium | US-001, US-002, US-003, US-007 |
| US-025 | Stock Write-off | Warehouse Adj | Low | US-001, US-002, US-003, US-007 |
| US-026 | AP Open Item Lifecycle | AP/AR Management | High | US-001, US-015 |
| US-027 | AR Open Item Lifecycle | AP/AR Management | High | US-001, US-009, US-011 |
| US-028 | ERROR — Stock Negative | Error Alerts | High | US-003 |
| US-029 | ERROR — CN_RETURN Inventory | Error Alerts | Medium | US-018 |
| US-030 | ERROR — Duplicate Invoice | Error Alerts | High | US-008-US-011 |
| US-031 | ERROR — INVOICE_FROM_DO Stock | Error Alerts | Medium | US-010 |
| US-032 | ERROR — Period Lock Violation | Error Alerts | High | US-004 |

---

## Story-Persona Matrix

| Story | Cashier | Store Staff | Supervisor | Manager | CFO | Admin |
|-------|---------|-------------|------------|---------|-----|-------|
| US-001 | — | — | — | — | — | — (System) |
| US-002 | — | — | — | — | — | — (System) |
| US-003 | — | — | — | — | — | — (System) |
| US-004 | — | — | — | — | — | — (System) |
| US-005 | — | — | — | ✓ Primary | ✓ Secondary | — |
| US-006 | — | — | — | — | — | — (System) |
| US-007 | ✓ Secondary | ✓ Secondary | ✓ Primary | ✓ Primary | ✓ Primary | — |
| US-008 | ✓ Primary | — | — | — | — | — |
| US-009 | ✓ Primary | — | — | — | — | — |
| US-010 | ✓ Primary | — | — | — | — | — |
| US-011 | ✓ Primary | — | — | — | — | — |
| US-012 | — | — | ✓ Primary | — | — | — |
| US-013 | — | — | — | ✓ Primary | — | — |
| US-014 | ✓ Primary | — | — | — | — | — |
| US-015 | — | ✓ Primary | — | — | — | — |
| US-016 | — | — | ✓ Primary | — | — | — |
| US-017 | — | ✓ Primary | — | — | — | — |
| US-018 | — | — | — | ✓ Primary | — | — |
| US-019 | — | — | — | ✓ Primary | — | — |
| US-020 | — | — | — | ✓ Primary | — | — |
| US-021 | — | — | — | ✓ Primary | — | — |
| US-022 | — | — | ✓ Primary | — | — | — |
| US-023 | — | — | ✓ Primary | — | — | — |
| US-024 | — | — | ✓ Primary | — | — | — |
| US-025 | — | — | — | — | ✓ Primary | — |
| US-026 | — | — | — | — | — | — (System) |
| US-027 | — | — | — | — | — | — (System) |
| US-028 | — | — | — | — | — | — (System) |
| US-029 | — | — | — | — | — | — (System) |
| US-030 | — | — | — | — | — | — (System) |
| US-031 | — | — | — | — | — | — (System) |
| US-032 | — | — | — | — | — | — (System) |

---

## Non-Functional Considerations

- **Performance**: Daily snapshot cache for stock balances; MA from latest TX (not SUM); partition TX Log by month
- **Atomicity**: MA recalculation must be within same DB transaction as stock change — full rollback on failure
- **Immutability**: No UPDATE/DELETE on POSTed TX — append-only log
- **Audit Trail**: Every field change logged with who/when/what
- **Security**: Role-based access control with 6 permission levels
- **Data Integrity**: Foreign key constraints on all reference chain fields

---

## External References

| Source | Stories Derived | What was used |
|--------|----------------|---------------|
| /Initial-requirement/Autoflow_SystemSpec_NoCOA.md | All stories | TX Type Master, Business Rules, Document Flows, MA Logic, AP/AR System |
