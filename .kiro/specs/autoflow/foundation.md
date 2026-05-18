# Foundation Specification

## Summary
- **Team**: Multiple teams (4 teams, 4 units)
- **Repo**: Monorepo with Nx
- **Architecture**: Modular Monolith — Transaction Log Engine
- **Gateway**: N/A (single app)
- **Auth**: JWT with RBAC (6 roles)
- **Error Format**: NestJS default HttpException
- **Inter-Unit Comms**: Direct module imports with defined interfaces
- **Database**: Single PostgreSQL DB, separate schemas per unit
- **Shared Types**: Shared library in monorepo (libs/shared-types/)
- **Frontend**: Single Angular app with lazy-loaded feature modules
- **Infrastructure Units**: Foundation (single combined unit)

---

## Repository Structure

**Strategy**: Monorepo with Nx
**Rationale**: 4 teams working on Angular + NestJS benefit from shared build tooling, consistent versioning, and easy cross-unit imports. Nx provides affected-based builds and caching.

```
autoflow/
├── apps/
│   ├── web/                        # Angular frontend (single app, lazy-loaded modules)
│   └── api/                        # NestJS backend (single app, modular)
├── libs/
│   ├── shared-types/               # TX Log interfaces, TxType enum, MA types, DTOs
│   ├── shared-auth/                # JWT guard, RBAC decorators, AuthContext
│   ├── shared-prisma/              # Prisma client, schema, migrations
│   ├── shared-errors/              # HttpException filters, error codes
│   ├── shared-utils/               # Common utilities (date, currency, validation)
│   ├── master-data/                # Unit 1: ข้อมูลหลัก module
│   │   ├── data-access/            # Prisma repositories
│   │   ├── feature/                # NestJS controllers + services
│   │   └── ui/                     # Angular feature module (lazy-loaded)
│   ├── transactions/               # Unit 2: ข้อมูลพื้นฐาน module
│   │   ├── data-access/
│   │   ├── feature/
│   │   └── ui/
│   ├── warehouse/                  # Unit 3: คลังสินค้า module
│   │   ├── data-access/
│   │   ├── feature/
│   │   └── ui/
│   └── reports/                    # Unit 4: รายงาน module
│       ├── data-access/
│       ├── feature/
│       └── ui/
├── prisma/
│   ├── schema.prisma               # Main schema (multi-schema)
│   └── migrations/                 # DB migrations
├── docker-compose.yml              # PostgreSQL + Redis (dev)
├── nx.json                         # Nx workspace config
├── tsconfig.base.json              # Shared TypeScript config
├── .eslintrc.json                  # Shared ESLint config
├── .prettierrc                     # Shared Prettier config
└── package.json                    # Root package.json
```

### Repository Ownership Rules

- `libs/shared-*` — ทุกทีมร่วม review, ต้อง approve จาก 2+ ทีมก่อน merge
- `libs/master-data/` — Team 1 owns
- `libs/transactions/` — Team 2 owns
- `libs/warehouse/` — Team 3 owns
- `libs/reports/` — Team 4 owns
- `prisma/` — Team 1 owns schema, ทุกทีม contribute migrations สำหรับ schema ตัวเอง
- `apps/api/` — shared, ทุกทีม contribute module registration
- `apps/web/` — shared routing, แต่ละทีม owns feature module ของตัวเอง

---

## Authentication & Authorization

**Approach**: JWT with RBAC
**Authorization**: Role-Based Access Control (6 roles: Cashier, Store, Supervisor, Manager, CFO, Admin)
**Enforced at**: Unit level via NestJS Guards

**Shared Auth Contract**:
```typescript
// libs/shared-auth/src/auth-context.interface.ts
interface AuthContext {
  userId: string;
  username: string;
  roles: Role[];
  permissions: Permission[];
  companyId: string;
}

enum Role {
  CASHIER = 'CASHIER',
  STORE = 'STORE',
  SUPERVISOR = 'SUPERVISOR',
  MANAGER = 'MANAGER',
  CFO = 'CFO',
  ADMIN = 'ADMIN',
}

// Usage in controllers:
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MANAGER, Role.CFO)
@Post('void')
async voidTransaction(@Body() dto: VoidTxDto, @CurrentUser() user: AuthContext) {}
```

**JWT Payload**: `{ sub, username, roles, companyId, iat, exp }`
**Token Expiry**: Access token 15min, Refresh token 7 days
**Guard Hierarchy**: JwtAuthGuard → RolesGuard → custom guards (e.g., ApprovalGuard)

---

## Error Handling

**Format**: NestJS default HttpException
**Code Convention**: Use NestJS built-in exceptions + custom domain exceptions extending HttpException

```typescript
// libs/shared-errors/src/domain-exception.ts
export class DomainException extends HttpException {
  constructor(
    public readonly code: string,
    message: string,
    status: HttpStatus = HttpStatus.BAD_REQUEST,
    public readonly details?: Record<string, any>,
  ) {
    super({ code, message, details }, status);
  }
}

// Domain-specific exceptions:
export class StockNegativeException extends DomainException {
  constructor(itemId: string, warehouseId: string, currentStock: number, requestedQty: number) {
    super('STOCK_NEGATIVE', 'Stock ติดลบ', HttpStatus.UNPROCESSABLE_ENTITY, {
      itemId, warehouseId, currentStock, requestedQty,
    });
  }
}

export class PeriodLockedException extends DomainException {
  constructor(period: string) {
    super('PERIOD_LOCKED', `ห้าม POST ใน Period ${period} ที่ปิดแล้ว`, HttpStatus.FORBIDDEN, { period });
  }
}

export class ImmutableTxException extends DomainException {
  constructor(txId: string) {
    super('TX_IMMUTABLE', 'TX ที่ POST แล้วต้องเป็น Immutable', HttpStatus.FORBIDDEN, { txId });
  }
}
```

**Shared Error Codes**:
| Code | HTTP Status | Description |
|------|-------------|-------------|
| STOCK_NEGATIVE | 422 | Stock would go negative |
| PERIOD_LOCKED | 403 | Period is closed |
| TX_IMMUTABLE | 403 | Cannot modify POSTed TX |
| REF_CHAIN_INVALID | 400 | Reference chain validation failed |
| APPROVAL_REQUIRED | 403 | TX requires approval from higher role |
| DUPLICATE_INVOICE | 409 | Invoice already exists for this JO |
| INSUFFICIENT_ROLE | 403 | User role insufficient for this operation |

---

## Inter-Unit Communication

**Pattern**: Direct module imports with defined interfaces
**Convention**: Each unit exposes a public API via a NestJS module. Other units import the module and use its exported services.

```typescript
// libs/master-data/feature/src/master-data.module.ts
@Module({
  imports: [SharedPrismaModule],
  providers: [TxLogService, MaCalculationService, StockValidationService, PeriodService],
  exports: [TxLogService, MaCalculationService, StockValidationService, PeriodService],
})
export class MasterDataModule {}

// libs/transactions/feature/src/transactions.module.ts
@Module({
  imports: [MasterDataModule, SharedAuthModule],  // ← direct import
  providers: [SalesService, PurchasingService, ApArService],
  exports: [SalesService, PurchasingService, ApArService],
})
export class TransactionsModule {}
```

**Interface Contract**: Each unit defines its public service interface in `libs/shared-types/`:
```typescript
// libs/shared-types/src/master-data.interface.ts
export interface ITxLogService {
  createTx(dto: CreateTxDto): Promise<TxEntry>;
  voidTx(txId: string, reason: string, userId: string): Promise<TxEntry>;
  getTx(txId: string): Promise<TxEntry>;
}

export interface IMaCalculationService {
  calculateNewMa(itemId: string, warehouseId: string, incomingQty: number, incomingValue: number): Promise<MaResult>;
  getCurrentMa(itemId: string, warehouseId: string): Promise<number>;
}

export interface IStockValidationService {
  validateStockAvailable(itemId: string, warehouseId: string, qty: number): Promise<void>;
  getStockBalance(itemId: string, warehouseId: string): Promise<number>;
}
```

---

## Database Strategy

**Approach**: Single PostgreSQL DB, separate schemas per unit
**Schemas**: `master_data`, `transactions`, `warehouse`, `reports`

```sql
-- Schema creation
CREATE SCHEMA master_data;
CREATE SCHEMA transactions;
CREATE SCHEMA warehouse;
CREATE SCHEMA reports;
```

**Cross-Schema Access Rules**:
- `transactions` schema CAN read from `master_data` schema (items, warehouses, vendors, customers)
- `warehouse` schema CAN read from `master_data` schema
- `reports` schema CAN read from ALL schemas (read-only)
- NO unit writes to another unit's schema — use service interfaces instead

**Prisma Multi-Schema**:
```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["master_data", "transactions", "warehouse", "reports"]
}

model TxLog {
  @@schema("master_data")
  // ... fields
}

model JobOrder {
  @@schema("transactions")
  // ... fields
}
```

**Migration Strategy**: Single migration timeline managed by Team 1 (master-data). Each team submits migration PRs that are reviewed before merge.

---

## Shared Types & Contracts

**Strategy**: Shared library in monorepo (`libs/shared-types/`)

```typescript
// libs/shared-types/src/index.ts — exports all shared types

// TX Types
export enum TxType {
  JOB_ORDER = 'JOB_ORDER',
  TEMP_DO = 'TEMP_DO',
  INVOICE_FROM_DO = 'INVOICE_FROM_DO',
  SALE_INVOICE = 'SALE_INVOICE',
  CN_SALES_RETURN = 'CN_SALES_RETURN',
  CN_SALES_PRICE = 'CN_SALES_PRICE',
  AR_RECEIVE = 'AR_RECEIVE',
  AR_CN_DEBT = 'AR_CN_DEBT',
  AR_DN = 'AR_DN',
  GR_RECEIVE = 'GR_RECEIVE',
  GR_RETURN = 'GR_RETURN',
  GR_REPLACEMENT = 'GR_REPLACEMENT',
  CN_RETURN = 'CN_RETURN',
  CN_PRICE_ADJ = 'CN_PRICE_ADJ',
  AP_CN_DEBT = 'AP_CN_DEBT',
  AP_PAYMENT = 'AP_PAYMENT',
  AP_DN = 'AP_DN',
  AP_DN_REF = 'AP_DN_REF',
  ADJ_COUNT_UP = 'ADJ_COUNT_UP',
  ADJ_COUNT_DOWN = 'ADJ_COUNT_DOWN',
  ADJ_TRANSFER = 'ADJ_TRANSFER',
  ADJ_WRITEOFF = 'ADJ_WRITEOFF',
  VOID = 'VOID',
}

export enum TxStatus {
  DRAFT = 'DRAFT',
  POSTED = 'POSTED',
  VOIDED = 'VOIDED',
}

export enum ApArStatus {
  OPEN = 'OPEN',
  PARTIAL = 'PARTIAL',
  CLOSED = 'CLOSED',
}

export enum VatType {
  INPUT = 'INPUT',
  OUTPUT = 'OUTPUT',
  NONE = 'NONE',
}

// Core DTOs
export interface CreateTxDto {
  txType: TxType;
  txDate: Date;
  period: string; // YYYY-MM
  itemId?: string;
  warehouseId?: string;
  qty?: number;
  unitCost?: number;
  vendorId?: string;
  customerId?: string;
  // ... reference chain fields
}

export interface MaResult {
  maBefore: number;
  maAfter: number;
  stockBefore: number;
  stockAfter: number;
  totalCost: number;
}
```

---

## Code & Data Conventions

### Code
- **Language**: TypeScript 5.x (strict mode)
- **Naming**: 
  - Files: kebab-case (`tx-log.service.ts`)
  - Classes: PascalCase (`TxLogService`)
  - Functions/methods: camelCase (`calculateMa()`)
  - Constants: UPPER_SNAKE_CASE (`MAX_RETRY_COUNT`)
  - DB tables: snake_case (`tx_log`, `job_order`)
- **Testing**: Jest (unit + integration), Playwright (E2E)
- **Linting/Formatting**: ESLint + Prettier (shared config in root)

### Data
- **IDs**: UUID v4 (generated by Prisma `@default(uuid())`)
- **Timestamps**: ISO 8601 UTC (`DateTime` in Prisma)
- **Soft deletes**: No — TX Log is immutable, use VOID pattern instead
- **Period format**: `YYYY-MM` string
- **Currency**: THB (single currency, stored as `Decimal` with 2 decimal places)

---

## Integration Contracts

### ข้อมูลหลัก (Master Data) → ข้อมูลพื้นฐาน (Transactions)

**Services exported**:
```typescript
ITxLogService.createTx(dto)        → TxEntry
IMaCalculationService.calculateNewMa(itemId, warehouseId, qty, value) → MaResult
IMaCalculationService.getCurrentMa(itemId, warehouseId) → number
IStockValidationService.validateStockAvailable(itemId, warehouseId, qty) → void | throw
IPeriodService.validatePeriodOpen(period) → void | throw
IRefChainService.validateRefChain(txType, refs) → void | throw
```

### ข้อมูลหลัก (Master Data) → คลังสินค้า (Warehouse)

**Services exported**: Same as above (TxLog, MA, Stock validation, Period)

### ข้อมูลพื้นฐาน (Transactions) → รายงาน (Reports)

**Read-only access**: Reports unit reads from `transactions` schema directly via Prisma for reporting queries (no service interface needed — read-only cross-schema access).

---

## Infrastructure Units

### Foundation Unit

**Type**: Infrastructure (not domain)
**Purpose**: Project scaffold, shared libraries, auth middleware, DB setup, CI/CD pipeline, dev tooling
**Priority**: Implement FIRST before all domain units
**Responsibilities**:
- Nx workspace setup with all shared libs
- Prisma schema with multi-schema support
- JWT auth module with RBAC guards
- Shared error handling (DomainException classes)
- Docker Compose for local dev (PostgreSQL + Redis)
- ESLint + Prettier shared config
- CI/CD pipeline (lint → test → build)
- Seed data scripts for development

**Stories**: None (cross-cutting infrastructure)
**Depended on by**: All 4 domain units

---

## Logging & Observability

**Log Format**: Structured JSON (NestJS built-in Logger with custom format)
**Correlation**: Request ID via `X-Request-Id` header (auto-generated if missing)
**Log Levels**: error, warn, log, debug, verbose

```typescript
// Every TX operation logs:
{
  "level": "log",
  "timestamp": "2025-01-20T10:00:00Z",
  "requestId": "uuid",
  "userId": "uuid",
  "action": "TX_POST",
  "txType": "GR_RECEIVE",
  "txId": "uuid",
  "itemId": "uuid",
  "warehouseId": "uuid",
  "maBefore": 100.00,
  "maAfter": 105.50,
  "duration": 45
}
```

---

## Team Assignments

| Unit | Team | Priority | Sequence |
|------|------|----------|----------|
| Foundation | All teams together | Critical | Phase 1 — must complete before split |
| ข้อมูลหลัก (Master Data) | Team 1 | High | Phase 2 — core dependency for all |
| ข้อมูลพื้นฐาน (Transactions) | Team 2 | High | Phase 3 — parallel with Warehouse |
| คลังสินค้า (Warehouse) | Team 3 | Medium | Phase 3 — parallel with Transactions |
| รายงาน (Reports) | Team 4 | Low | Phase 4 — depends on all others |

**Parallel Work**: After Foundation + Master Data are complete, Team 2 and Team 3 can work in parallel. Team 4 starts after Teams 2+3 have basic data flowing.

---

## Sync Schedule

- **Weekly**: Integration check — all teams verify cross-unit interfaces work
- **Per-unit**: Design review before implementation starts
- **PR-based**: Shared library changes require 2+ team approvals
- **Cross-team**: Sync when shared-types or Prisma schema changes

---

## Risks

- **Contract drift** → shared-types lib is source of truth; CI fails if interface mismatch
- **Schema conflicts** → single migration timeline, Team 1 reviews all schema PRs
- **Integration delays** → define integration milestones: Foundation done → Master Data API ready → Teams 2+3 can start
- **Prisma multi-schema complexity** → validate early in Foundation phase with spike
