# Units of Work

## Summary
- **Units**: 4 units — ข้อมูลหลัก (Master Data), ข้อมูลพื้นฐาน (Transactions), คลังสินค้า (Warehouse), รายงาน (Reports)
- **Strategy**: Domain-Driven
- **Architecture**: Modular Monolith — Transaction Log Engine
- **Story Distribution**: ข้อมูลหลัก: 7, ข้อมูลพื้นฐาน: 16, คลังสินค้า: 4, รายงาน: 5
- **Key Dependencies**: ข้อมูลพื้นฐาน → ข้อมูลหลัก (Data), คลังสินค้า → ข้อมูลหลัก (Data), รายงาน → All (Read)
- **Development Sequence**: Phase 1: Foundation (shared), Phase 2: ข้อมูลหลัก, Phase 3: ข้อมูลพื้นฐาน + คลังสินค้า (parallel), Phase 4: รายงาน
- **Teams**: 4 teams, 1 unit per team

## Overview
Feature decomposed into 4 units for parallel team development with clear domain boundaries.

**Strategy**: Domain-Driven
**Rationale**: Each unit represents a distinct business domain with clear boundaries. The TX Log Engine (ข้อมูลหลัก) is the foundation that all other units depend on. Transaction operations and warehouse can be developed in parallel once the core is ready. Reports depend on all other units' data.

---

## Unit 1: ข้อมูลหลัก (Master Data & Core Engine)

**Purpose**: Core TX Log Engine, Moving Average calculation, stock validation, period management, VOID pattern, approval mechanism, and all master data (items, warehouses, vendors, customers, users/roles)
**Priority**: High
**Complexity**: High
**Stories**: 7 stories — US-001, US-002, US-003, US-004, US-005, US-006, US-007

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| CreateTxLog | Create immutable TX Log entry with all mandatory fields | System |
| CalculateMA | Recalculate Moving Average on stock-affecting TX | System |
| ValidateStock | Check stock >= 0 before POST | System |
| ValidatePeriod | Check period is OPEN before POST | System |
| VoidTransaction | Create reverse TX and mark original as VOIDED | Manager+ |
| ValidateRefChain | Validate all ref_* fields before POST | System |
| ApproveTransaction | Change TX from DRAFT to POSTED (role-based) | Authorized User |
| ManageItem | CRUD item master data | Admin |
| ManageWarehouse | CRUD warehouse master data | Admin |
| ManageVendor | CRUD vendor master data | Admin |
| ManageCustomer | CRUD customer master data | Admin |
| ManageUser | CRUD users and role assignments | Admin |
| ManagePeriod | Open/Close accounting periods | CFO |

### Domain Model
**Aggregates**: TransactionLog (root: TxEntry), ItemMaster (root: Item), WarehouseMaster (root: Warehouse), VendorMaster (root: Vendor), CustomerMaster (root: Customer), UserMaster (root: User), PeriodMaster (root: Period)
**Entities**: TxEntry, Item, Warehouse, Vendor, Customer, User, Role, Period
**Value Objects**: TxType, TxStatus, MovingAverage, ReferenceChain, ApprovalLevel, StockBalance

### Domain Events
**Publishes**: 
- TxPosted — When any TX is successfully POSTed
- TxVoided — When a TX is voided
- MARecalculated — When MA changes for an item+warehouse
- StockChanged — When stock balance changes
- PeriodClosed — When a period is closed

**Subscribes**: None (this is the upstream core)

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| None | — | This is the foundation unit — no upstream dependencies |

---

## Unit 2: ข้อมูลพื้นฐาน (Transaction Operations — Sales & Purchasing)

**Purpose**: All sales flow (Job Order, TEMP_DO, Invoice, Sales CN, AR Payment), all purchasing flow (GR, Return, Replacement, Purchase CN, AP Payment), and AP/AR Open Item lifecycle management
**Priority**: High
**Complexity**: High
**Stories**: 16 stories — US-008, US-009, US-010, US-011, US-012, US-013, US-014, US-015, US-016, US-017, US-018, US-019, US-020, US-021, US-026, US-027

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| CreateJobOrder | Create new JO with OPEN status | Cashier |
| UpdateJobOrderStatus | Transition JO status (OPEN→IN_PROGRESS→DONE) | Cashier |
| IssueTempDO | Create TEMP_DO from completed JO (Path A) | Cashier |
| IssueInvoiceFromDO | Create formal invoice from TEMP_DO | Cashier |
| IssueSaleInvoice | Create direct sale invoice from JO (Path B) | Cashier |
| CreateSalesReturn | Process CN_SALES_RETURN with condition check | Supervisor |
| CreateSalesPriceAdj | Process CN_SALES_PRICE (no inventory) | Manager |
| ReceiveARPayment | Match payment to open AR items | Cashier |
| CreateGoodsReceipt | Record GR_RECEIVE with MA recalculation | Store Staff |
| CreateGoodsReturn | Process GR_RETURN with clearing account | Supervisor |
| ReceiveReplacement | Process GR_REPLACEMENT closing clearing | Store Staff |
| CreateCNReturn | Process CN_RETURN (AP reduction + PPV) | Manager |
| CreateCNPriceAdj | Process CN_PRICE_ADJ (inventory + AP) | Manager |
| CreateCNDebt | Process AP_CN_DEBT (AP only) | Manager |
| MakeAPPayment | Match payment to open AP items | Manager |

### Domain Model
**Aggregates**: JobOrder (root: JobOrder), SalesTransaction (root: SalesTx), PurchaseTransaction (root: PurchaseTx), APOpenItem (root: APItem), AROpenItem (root: ARItem)
**Entities**: JobOrder, SalesTx, PurchaseTx, APItem, ARItem, GRIRClearing
**Value Objects**: JOStatus, InvoicePath, ReturnCondition, ClearingBalance, PaymentMatch

### Domain Events
**Publishes**:
- JobOrderCompleted — When JO status changes to DONE
- TempDOIssued — When TEMP_DO is POSTed
- InvoiceIssued — When any invoice is POSTed
- SalesReturnProcessed — When CN_SALES_RETURN is POSTed
- GoodsReceived — When GR_RECEIVE is POSTed
- GoodsReturned — When GR_RETURN is POSTed
- APPaymentMade — When AP_PAYMENT is POSTed
- ARPaymentReceived — When AR_RECEIVE is POSTed

**Subscribes**:
- TxPosted from ข้อมูลหลัก — Confirm TX was successfully logged
- MARecalculated from ข้อมูลหลัก — Update local cost references

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| ข้อมูลหลัก | Data | TX Log creation, MA calculation, stock validation, period check, reference chain validation |
| ข้อมูลหลัก | API | Item lookup, vendor/customer lookup, warehouse lookup |

---

## Unit 3: คลังสินค้า (Warehouse Operations)

**Purpose**: Stock count (freeze/count/adjust), stock transfer between warehouses, stock write-off with evidence and approval
**Priority**: Medium
**Complexity**: Medium
**Stories**: 4 stories — US-022, US-023, US-024, US-025

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| InitiateStockCount | Freeze stock for item+warehouse, begin count | Supervisor |
| RecordCountResult | Record physical count result | Store Staff |
| ApproveAdjustment | Approve count difference based on threshold | Supervisor/Manager/CFO |
| PostCountAdjustment | POST ADJ_COUNT_UP or ADJ_COUNT_DOWN | System |
| UnfreezeStock | Release stock freeze after count complete | System |
| InitiateTransfer | Create transfer request between warehouses | Supervisor |
| ConfirmTransferReceipt | Confirm receipt at destination warehouse | Store Staff |
| RequestWriteOff | Request stock write-off with evidence | Supervisor |
| ApproveWriteOff | CFO approval for write-off | CFO |

### Domain Model
**Aggregates**: StockCount (root: CountSession), StockTransfer (root: TransferOrder), WriteOff (root: WriteOffRequest)
**Entities**: CountSession, CountLine, TransferOrder, TransferLine, WriteOffRequest
**Value Objects**: FreezeStatus, CountDifference, ApprovalThreshold, TransitStatus, WriteOffEvidence

### Domain Events
**Publishes**:
- StockFrozen — When count session starts
- StockUnfrozen — When count session ends
- CountAdjusted — When ADJ_COUNT_UP/DOWN is POSTed
- TransferInitiated — When transfer starts (IN_TRANSIT)
- TransferCompleted — When destination confirms receipt
- WriteOffApproved — When CFO approves write-off

**Subscribes**:
- StockChanged from ข้อมูลหลัก — Validate no stock changes during freeze
- TxPosted from ข้อมูลหลัก — Confirm adjustment TX logged

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| ข้อมูลหลัก | Data | TX Log creation, MA calculation, stock validation, approval check |
| ข้อมูลหลัก | API | Item lookup, warehouse lookup, current stock/MA query |

---

## Unit 4: รายงาน (Reports & Error Alerts)

**Purpose**: ERROR-level alert system (blocking validations), stock reports, AP/AR aging views, and operational dashboards
**Priority**: Low
**Complexity**: Low
**Stories**: 5 stories — US-028, US-029, US-030, US-031, US-032

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| ValidatePrePost | Run all ERROR checks before any TX POST | System |
| LogError | Record error event with TX details | System |
| QueryStockReport | Generate stock balance report | Manager/CFO |
| QueryAPAging | Generate AP aging report | Manager |
| QueryARAging | Generate AR aging report | Manager |

### Domain Model
**Aggregates**: AlertRule (root: AlertRule), ReportQuery (root: ReportDefinition)
**Entities**: AlertRule, AlertLog, ReportDefinition
**Value Objects**: AlertSeverity, AlertCondition, ReportFilter, AgingBucket

### Domain Events
**Publishes**:
- ErrorBlocked — When a POST is blocked by ERROR validation
- AlertLogged — When an alert is recorded

**Subscribes**:
- TxPosted from ข้อมูลหลัก — Trigger post-POST validations
- StockChanged from ข้อมูลหลัก — Check for negative stock conditions
- All events from ข้อมูลพื้นฐาน — Monitor for business rule violations

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| ข้อมูลหลัก | Data/Read | TX Log queries, stock balance, MA history |
| ข้อมูลพื้นฐาน | Data/Read | AP/AR open items, JO status, CN references |
| คลังสินค้า | Data/Read | Count sessions, transfer status |

---

## Context Map

| Upstream | Downstream | Pattern |
|----------|------------|---------|
| ข้อมูลหลัก | ข้อมูลพื้นฐาน | Customer/Supplier |
| ข้อมูลหลัก | คลังสินค้า | Customer/Supplier |
| ข้อมูลหลัก | รายงาน | Publisher/Subscriber |
| ข้อมูลพื้นฐาน | รายงาน | Publisher/Subscriber |
| คลังสินค้า | รายงาน | Publisher/Subscriber |

**Shared Kernel**: TX Log structure, TxType enum, MA calculation formula — defined in Foundation

---

## Development Sequence

### Phase 1: Foundation (All teams together)
- [ ] Foundation — project scaffold, Nx workspace, shared libs, Prisma schema, JWT auth, CI/CD, Docker Compose
- [ ] ข้อมูลหลัก — TX Log Engine, MA, Stock validation, Period Lock, VOID, Master Data CRUD

### Phase 2: Core (Team 1)
- [ ] ข้อมูลหลัก — TX Log Engine, MA, Stock validation, Period Lock, VOID, Master Data CRUD

### Phase 3: Operations (Team 2 + Team 3 in parallel)
- [ ] ข้อมูลพื้นฐาน — Sales flow, Purchasing flow, AP/AR (depends on ข้อมูลหลัก)
- [ ] คลังสินค้า — Count, Transfer, Write-off (depends on ข้อมูลหลัก)

### Phase 4: Reporting (Team 4)
- [ ] รายงาน — ERROR alerts, reports, dashboards (depends on all other units)
