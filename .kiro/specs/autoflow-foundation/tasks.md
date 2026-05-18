# Implementation Tasks

## Overview
Tasks organized by component-first strategy (bottom-up: shared libs → app shells).

**Derived From**:
- Design: 7 components, 3 entities, 4 endpoints from `design.md`

**Strategy**: Component-First (bottom-up)
**Rationale**: Foundation unit builds shared infrastructure that domain units depend on. Must build types → prisma → errors → auth → shells in dependency order.

---

- [-] 1. Project Scaffold & Tooling
  - [-] 1.1 Initialize Nx Monorepo
    - **Deps**: None | **Ref**: `design.md` — Repository Structure
    - Create Nx workspace with @nx/nest + @nx/angular presets
    - Configure nx.json, tsconfig.base.json with path aliases (@autoflow/*)
    - Set up .eslintrc.json and .prettierrc (shared config)
    - Create jest.preset.js for shared test configuration
  - [~] 1.2 Create Docker Compose for Local Dev
    - **Deps**: None | **Ref**: `design.md` — Dev Setup
    - Create docker-compose.yml with PostgreSQL 16 service
    - Configure volumes for data persistence
    - Add .env.example with DATABASE_URL template
  - [~] 1.3 Set up GitHub Actions CI Pipeline
    - **Deps**: 1.1 | **Ref**: `design.md` — CI/CD Pipeline
    - Create .github/workflows/ci.yml
    - Configure: checkout, setup-node, npm ci, nx affected (lint, test, build)
    - Add PostgreSQL service container for test jobs

- [ ] 2. Shared Types Library
  - [~] 2.1 Create shared-types Nx library
    - **Deps**: 1.1 | **Ref**: `design.md` — SharedTypes component
    - Generate lib: `nx g @nx/js:library shared-types --directory=libs/shared-types`
    - Create enums/: TxType, TxStatus, ApArStatus, VatType, Role
    - Create interfaces/: ITxLogService, IMaCalculationService, IStockValidationService, IPeriodService
    - Create dto/: CreateTxDto, MaResult, AuthContext
    - Set up barrel exports in index.ts

- [ ] 3. Shared Prisma Library & Database
  - [~] 3.1 Create shared-prisma Nx library
    - **Deps**: 2.1 | **Ref**: `design.md` — SharedPrisma component
    - Generate lib: `nx g @nx/js:library shared-prisma --directory=libs/shared-prisma`
    - Install prisma and @prisma/client
    - Create PrismaService extending PrismaClient with onModuleInit/onModuleDestroy
    - Create PrismaModule (Global, exports PrismaService)
  - [~] 3.2 Create Prisma Schema with Multi-Schema Support
    - **Deps**: 3.1 | **Ref**: `design.md` — Data Model
    - Create prisma/schema.prisma with datasource (schemas: master_data, transactions, warehouse, reports)
    - Define User model (@@schema("master_data")) with all fields
    - Define RefreshToken model (@@schema("master_data")) with all fields
    - Add indexes: username (unique), email (unique), token (unique)
  - [~] 3.3 Run Initial Migration & Seed Script
    - **Deps**: 3.2, 1.2 | **Ref**: `design.md` — Database Seeding
    - Create SQL to create schemas: master_data, transactions, warehouse, reports
    - Run `prisma migrate dev --name init`
    - Create prisma/seed.ts with faker data (admin user, test users per role)
    - Configure seed command in package.json

- [ ] 4. Shared Errors Library
  - [~] 4.1 Create shared-errors Nx library
    - **Deps**: 1.1 | **Ref**: `design.md` — SharedErrors component
    - Generate lib: `nx g @nx/js:library shared-errors --directory=libs/shared-errors`
    - Create DomainException base class extending HttpException
    - Create domain exceptions: StockNegativeException, PeriodLockedException, ImmutableTxException, RefChainInvalidException, ApprovalRequiredException, DuplicateInvoiceException, InsufficientRoleException
    - Create AllExceptionsFilter (global exception filter)
    - Create error code constants

- [ ] 5. Shared Auth Library
  - [~] 5.1 Create shared-auth Nx library
    - **Deps**: 2.1, 3.1 | **Ref**: `design.md` — SharedAuth component
    - Generate lib: `nx g @nx/js:library shared-auth --directory=libs/shared-auth`
    - Install @nestjs/jwt, @nestjs/passport, passport, passport-jwt, bcrypt
    - Create AuthModule with JwtModule.registerAsync configuration
    - Create AuthService: login, register, refresh, validateUser, hashPassword
    - Create JwtStrategy (passport-jwt) extracting Bearer token
  - [~] 5.2 Create Guards and Decorators
    - **Deps**: 5.1 | **Ref**: `design.md` — Authentication & Authorization
    - Create JwtAuthGuard (extends AuthGuard('jwt'))
    - Create RolesGuard (reads @Roles metadata, checks user.roles)
    - Create @Roles() decorator (SetMetadata)
    - Create @CurrentUser() decorator (createParamDecorator from request.user)
  - [~] 5.3 Write Auth Unit Tests
    - **Deps**: 5.1, 5.2 | **Ref**: `design.md` — Conventions
    - Test AuthService: login success/failure, register, refresh token rotation
    - Test JwtAuthGuard: valid/invalid/expired token
    - Test RolesGuard: authorized/unauthorized role combinations
    - Test password hashing with bcrypt

- [ ] 6. Shared Utils Library
  - [~] 6.1 Create shared-utils Nx library
    - **Deps**: 1.1 | **Ref**: `design.md` — SharedConfig component
    - Generate lib: `nx g @nx/js:library shared-utils --directory=libs/shared-utils`
    - Create date.utils.ts: toISOString, toPeriod (YYYY-MM), isWithinPeriod
    - Create currency.utils.ts: roundToDecimal(2), formatTHB
    - Create period.utils.ts: getCurrentPeriod, parsePeriod, comparePeriods

- [ ] 7. API Application Shell
  - [~] 7.1 Create NestJS API App
    - **Deps**: 3.1, 4.1, 5.2 | **Ref**: `design.md` — AppShell (API)
    - Generate app: `nx g @nx/nest:application api --directory=apps/api`
    - Configure AppModule: import PrismaModule, AuthModule, SharedErrorsModule
    - Set up main.ts: global ValidationPipe (class-validator), AllExceptionsFilter, CORS
    - Install and configure @nestjs/config with .env support
    - Set up @nestjs/swagger in main.ts (title, description, version, bearer auth)
  - [~] 7.2 Create Auth Controller (4 endpoints)
    - **Deps**: 7.1 | **Ref**: `design.md` — API Specification
    - POST /api/v1/auth/login — validate credentials, return tokens
    - POST /api/v1/auth/register — Admin only, create user with roles
    - POST /api/v1/auth/refresh — validate refresh token, rotate tokens
    - GET /api/v1/auth/me — return current user profile (JWT protected)
    - Add Swagger decorators (@ApiTags, @ApiOperation, @ApiResponse)
  - [~] 7.3 Write API Integration Tests
    - **Deps**: 7.2 | **Ref**: `design.md` — Conventions
    - Test login: valid credentials → 200 + tokens, invalid → 401
    - Test register: admin creates user → 201, non-admin → 403, duplicate → 409
    - Test refresh: valid token → 200 + new tokens, expired → 401
    - Test me: authenticated → 200 + profile, unauthenticated → 401
    - Use Supertest with test database

- [ ] 8. Web Application Shell
  - [~] 8.1 Create Angular Web App
    - **Deps**: 1.1 | **Ref**: `design.md` — AppShell (Web)
    - Generate app: `nx g @nx/angular:application web --directory=apps/web --routing --style=scss`
    - Set up app.routes.ts with lazy-loaded route placeholders for each unit
    - Create core/ directory: AuthGuard, AuthInterceptor (attach JWT to requests), AuthService
    - Create shared/ directory: LayoutComponent (header + sidebar + content area), NavComponent
  - [~] 8.2 Create Login Page
    - **Deps**: 8.1 | **Ref**: `design.md` — API Specification (login endpoint)
    - Create login component with username/password form
    - Integrate with POST /api/v1/auth/login
    - Store tokens in localStorage, redirect to dashboard on success
    - Handle error states (invalid credentials, network error)
  - [~] 8.3 Create Dashboard Shell
    - **Deps**: 8.2 | **Ref**: `design.md` — AppShell (Web)
    - Create dashboard component (placeholder for unit-specific content)
    - Implement sidebar navigation with role-based menu items
    - Add user profile display in header (from GET /auth/me)
    - Set up route guards (redirect to login if not authenticated)

---

## Task Summary

| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | Initialize Nx Monorepo | None | [ ] |
| 1.2 | Create Docker Compose | None | [ ] |
| 1.3 | Set up GitHub Actions CI | 1.1 | [ ] |
| 2.1 | Create shared-types library | 1.1 | [ ] |
| 3.1 | Create shared-prisma library | 2.1 | [ ] |
| 3.2 | Create Prisma Schema | 3.1 | [ ] |
| 3.3 | Run Migration & Seed | 3.2, 1.2 | [ ] |
| 4.1 | Create shared-errors library | 1.1 | [ ] |
| 5.1 | Create shared-auth library | 2.1, 3.1 | [ ] |
| 5.2 | Create Guards and Decorators | 5.1 | [ ] |
| 5.3 | Write Auth Unit Tests | 5.1, 5.2 | [ ] |
| 6.1 | Create shared-utils library | 1.1 | [ ] |
| 7.1 | Create NestJS API App | 3.1, 4.1, 5.2 | [ ] |
| 7.2 | Create Auth Controller | 7.1 | [ ] |
| 7.3 | Write API Integration Tests | 7.2 | [ ] |
| 8.1 | Create Angular Web App | 1.1 | [ ] |
| 8.2 | Create Login Page | 8.1 | [ ] |
| 8.3 | Create Dashboard Shell | 8.2 | [ ] |

---

## Design Coverage

**Components**: 7 components → All covered
- SharedTypes → Task 2.1
- SharedPrisma → Tasks 3.1, 3.2, 3.3
- SharedErrors → Task 4.1
- SharedAuth → Tasks 5.1, 5.2, 5.3
- SharedConfig → Task 1.1 (ESLint, Prettier, tsconfig)
- AppShell (API) → Tasks 7.1, 7.2, 7.3
- AppShell (Web) → Tasks 8.1, 8.2, 8.3

**Entities**: 3 entities → Tasks 3.2, 3.3
**Endpoints**: 4 endpoints → Task 7.2
**Integrations**: 0 (infrastructure unit)

---

## Definition of Done

- [~] Code written and follows shared ESLint/Prettier config
- [~] Tests written and passing (unit + integration where applicable)
- [~] All Nx libraries buildable and importable via path aliases
- [~] Docker Compose starts PostgreSQL successfully
- [~] Prisma migrations run without errors
- [~] API starts and Swagger UI accessible at /api/docs
- [~] Web app starts and login flow works end-to-end
- [~] CI pipeline passes (lint + test + build)

---

## Execution Waves

| Wave | Phases | Dependencies Resolved |
|------|--------|-----------------------|
| 1 | 1. Project Scaffold & Tooling | None (bootstrap) |
| 2 | 2. Shared Types, 4. Shared Errors, 6. Shared Utils | Wave 1 (Nx workspace exists) |
| 3 | 3. Shared Prisma, 5. Shared Auth | Wave 2 (types available) |
| 4 | 7. API Shell, 8. Web Shell | Wave 3 (all shared libs ready) |

### File Ownership Per Wave

**Wave 2** (parallel):
- Phase 2: `libs/shared-types/`
- Phase 4: `libs/shared-errors/`
- Phase 6: `libs/shared-utils/`

**Wave 3** (parallel):
- Phase 3: `libs/shared-prisma/`, `prisma/`
- Phase 5: `libs/shared-auth/`

**Wave 4** (parallel):
- Phase 7: `apps/api/`
- Phase 8: `apps/web/`

---

## Notes

**Technical Debt**: None (greenfield)

**Future Enhancements** (deferred to domain units):
- Master Data CRUD (Unit 1: ข้อมูลหลัก)
- TX Log Engine (Unit 1: ข้อมูลหลัก)
- Sales/Purchasing flows (Unit 2: ข้อมูลพื้นฐาน)
- Warehouse operations (Unit 3: คลังสินค้า)
- Reports & Alerts (Unit 4: รายงาน)
