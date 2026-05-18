---
inclusion: always
---
# Product Context

## Summary
- **Product**: Autoflow — Inventory, AP/AR & Document Flow system with Transaction Log Engine (No Chart of Accounts)
- **Users**: Cashier, Store Staff, Supervisor, Manager, CFO, Admin
- **Type**: Greenfield — New product

## Overview

Autoflow is an enterprise inventory and financial document flow system built on a Transaction Log Engine architecture. Instead of maintaining a traditional Chart of Accounts, the system records all business transactions (purchases, sales, returns, adjustments) as immutable log entries with Moving Average costing. Journal entries for external accounting systems are generated via a configurable Mapping Table, decoupling operational logic from accounting structure.

## Problem Statement

Businesses need a unified system to manage inventory movements, accounts payable/receivable, and document flows (Job Orders, Invoices, Credit Notes) with full audit trail and cost tracking. Traditional ERP systems tightly couple operations with accounting charts, making them rigid and hard to adapt. Autoflow separates operational transaction logging from accounting export, providing flexibility while maintaining financial accuracy through Moving Average perpetual inventory and immutable transaction records.

## Target Users

- **Cashier**: Processes Job Orders, issues TEMP_DO and Invoices, receives AR payments
- **Store Staff**: Receives goods (GR_RECEIVE), records tax invoices, manages stock intake
- **Supervisor**: Approves returns (GR_RETURN, CN_SALES_RETURN), transfers, stock count adjustments
- **Manager**: Approves Credit Notes (CN_SALES_PRICE, CN_RETURN, CN_PRICE_ADJ, AP_CN_DEBT), AP payments, VOIDs
- **CFO**: Approves write-offs (ADJ_WRITEOFF), cost adjustments; period closing authority
- **Admin**: System configuration, master data management, user role assignment

## Key Features (MVP Scope)

- **Core TX Engine**: Immutable TX Log with reference chain, MA calculation, period lock, VOID pattern
- **Sales Flow**: Job Order dual-path (TEMP_DO + direct Invoice), CN_SALES_RETURN, CN_SALES_PRICE, AR_RECEIVE
- **Purchasing Flow**: GR_RECEIVE, GR_RETURN, GR_REPLACEMENT, CN_RETURN, CN_PRICE_ADJ, AP_CN_DEBT, AP_PAYMENT
- **Warehouse Adjustments**: ADJ_COUNT_UP/DOWN, ADJ_TRANSFER, ADJ_WRITEOFF (Write-down, Reclass, Cost Adj deferred)
- **AP/AR Open Item**: Manual matching, lifecycle tracking (OPEN → PARTIAL → CLOSED)
- **Simple Approval**: Status-based (DRAFT → POSTED) with role-level enforcement
- **ERROR Alerts**: Blocking errors for business rule violations (stock negative, period lock, duplicate invoice)
- **Deferred**: Mapping Table export, WARNING/INFO alerts, multi-company, Write-down/Reclass/Cost Adj

## Domain Language

| Term | Definition | Example |
|------|-----------|---------|
| TX Log | Immutable transaction record with all financial and stock impacts | A GR_RECEIVE TX records stock increase, AP creation, MA recalculation |
| TX Type | Enumerated transaction classification determining system behavior | SALE_INVOICE, GR_RECEIVE, CN_RETURN |
| Moving Average (MA) | Weighted average cost = Total inventory value ÷ Total quantity | After receiving 10 units at 100 THB with 5 existing at 80 THB: MA = (500+1000)/15 = 100 |
| TEMP_DO | Temporary Delivery Order — delivers goods before formal invoice | Used in Path A of Job Order flow |
| GR/IR Clearing | Intermediate account tracking goods returned pending Credit Note | Created by GR_RETURN, closed by CN_RETURN or GR_REPLACEMENT |
| PPV | Purchase Price Variance — difference between GR cost and invoice cost | PPV = GR/IR Clearing Balance − CN Amount |
| COGS | Cost of Goods Sold — MA at time of sale, stored for returns | cogs_unit field in SALE_INVOICE/TEMP_DO TX |
| Open Item | AP/AR entry with lifecycle: OPEN → PARTIAL → CLOSED | Each GR creates an AP Open Item |
| Mapping Table | Configuration translating TX types to Dr/Cr journal entries | TEMP_DO → Dr. AR / Cr. Revenue / Dr. COGS / Cr. Inventory |
| Period Lock | Closed accounting period preventing new postings | POST in locked period throws error |
| VOID | Cancellation by creating reverse TX (never delete) | VOID creates opposite-value TX with parent_tx_id reference |
| Reference Chain | Links between related transactions | Invoice → TEMP_DO → JOB_ORDER |
| NRV | Net Realizable Value = Selling price − Cost to sell | Used for write-down calculations |

## Success Criteria

- All 30+ TX types process correctly with proper stock, AP/AR, MA, and VAT impacts
- Job Order dual-path flow works with automatic TX type determination
- Moving Average never recalculates retroactively; always accurate at point-in-time
- Zero data loss — all transactions immutable, VOID-only cancellation
- Mapping Table correctly exports journal entries to external accounting system
- Approval workflow enforces all business rules before POST
- Alert system catches all ERROR conditions before they corrupt data
- Stock never goes negative — system throws error before POST

## Constraints & Assumptions

**Constraints**:
- Stack: Angular (Frontend) + NestJS (Backend) + PostgreSQL (Database)
- No Chart of Accounts in the system — accounting handled via Mapping Table export
- TX Log is immutable — no UPDATE/DELETE after POST
- MA must not be recalculated retroactively
- Stock must never go negative
- Period Lock must be enforced on every POST operation
- All CN types must be separate TX Types — no combined logic

**Assumptions**:
- Single currency (THB) for initial release — multi-currency is future scope
- Batch export to accounting system (not real-time)
- In-app approval workflow (not external email-based)
- Direct write-down method for inventory valuation
- Cycle count preferred over full warehouse freeze

## Project Type

- **Type**: Greenfield
- **Scope**: New product
