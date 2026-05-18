# Foundation Decisions

## Context Summary
- **Project**: Autoflow — Inventory, AP/AR & Document Flow (No COA)
- **Type**: Greenfield
- **Stack**: TypeScript / Angular + NestJS / PostgreSQL
- **Architecture**: Modular Monolith — Transaction Log Engine
- **Units**: 4 (ข้อมูลหลัก, ข้อมูลพื้นฐาน, คลังสินค้า, รายงาน)
- **Teams**: 4 teams, 1 unit per team
- **Mode**: Incremental with Foundation
- **Key Constraint**: TX Log immutable, MA atomic, Stock never negative

---

## Decision Questions

### DF-1: Team Structure
**Question**: How are the 4 teams organized for this project?
- 1) 4 independent teams, each owns 1 unit end-to-end **(Recommended)**
- 2) 4 teams with shared backend lead coordinating
- 3) 4 teams with rotating pair reviews across units
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-2: Repository Strategy
**Question**: How should the codebase be organized for 4 teams working on Angular + NestJS?
- 1) Monorepo with Nx — shared build, single repo, all units together **(Recommended)**
- 2) Multi-repo — separate repo per unit (more isolation, harder sharing)
- 3) Hybrid — monorepo for backend, separate repo for frontend
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-3: Authentication & Authorization
**Question**: How should users authenticate and how should role-based access (6 roles) be enforced?
- 1) JWT with RBAC — stateless tokens, role claims in JWT, guard decorators in NestJS **(Recommended)**
- 2) Session-based with RBAC — server-side sessions, Redis store
- 3) OAuth2 with external IdP — delegate to Keycloak/Auth0
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-4: Error Handling Format
**Question**: What error response format should all units use?
- 1) Custom envelope — `{ success, data, error: { code, message, details } }` **(Recommended)**
- 2) RFC 7807 Problem Details — standard format
- 3) NestJS default HttpException format
- 4) Other (please specify): _______

**Answer**: 
3
---

### DF-5: Inter-Unit Communication
**Question**: How should units communicate with each other within the Modular Monolith?
- 1) Direct module imports with defined interfaces — units are NestJS modules in same app **(Recommended)**
- 2) Internal REST APIs between units (separate processes)
- 3) Event-driven with internal event bus (e.g., NestJS EventEmitter or Bull queues)
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-6: Database Strategy
**Question**: How should the PostgreSQL database be organized for 4 units?
- 1) Single DB, shared schema — all tables in one schema, module prefixes for table names **(Recommended)**
- 2) Single DB, separate schemas per unit — `master_data.`, `transactions.`, `warehouse.`, `reports.`
- 3) Separate databases per unit — full isolation
- 4) Other (please specify): _______

**Answer**: 
2
---

### DF-7: Shared Types Strategy
**Question**: How should shared types (TX Log interfaces, TxType enum, MA types) be managed across units?
- 1) Shared library in monorepo — `libs/shared-types/` imported by all units **(Recommended)**
- 2) Code generation from DB schema — auto-generate TypeScript types
- 3) Manual sync — each unit maintains its own copy
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-8: ORM / Data Access
**Question**: Which ORM should be used for PostgreSQL access in NestJS?
- 1) TypeORM — mature, decorator-based, good NestJS integration **(Recommended)**
- 2) Prisma — type-safe, schema-first, modern DX
- 3) MikroORM — Unit of Work pattern, good for DDD
- 4) Other (please specify): _______

**Answer**: 
2
---

### DF-9: API Style
**Question**: What API style should the NestJS backend expose to the Angular frontend?
- 1) REST with OpenAPI/Swagger documentation **(Recommended)**
- 2) GraphQL with code-first schema
- 3) REST without formal documentation
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-10: Testing Strategy
**Question**: What testing approach should all teams follow?
- 1) Unit tests (Jest) + Integration tests (Supertest) + E2E (Cypress/Playwright) **(Recommended)**
- 2) Unit tests only — fast feedback, defer integration tests
- 3) Unit + Integration only — skip E2E for now
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-11: Infrastructure Unit Strategy
**Question**: Should infrastructure concerns be a single Foundation unit or separate units?
- 1) Single Foundation unit — project scaffold, shared libs, auth, DB setup, CI/CD **(Recommended)**
- 2) Separate units — Foundation (scaffold) + Auth Service + DB Migration Service
- 3) No dedicated unit — each team handles their own infra
- 4) Other (please specify): _______

**Answer**: 
1
---

### DF-12: Frontend Architecture
**Question**: How should the Angular frontend be structured for 4 teams?
- 1) Single Angular app with lazy-loaded feature modules per unit **(Recommended)**
- 2) Micro-frontends — separate Angular apps per unit composed at runtime
- 3) Single Angular app with shared module, no lazy loading
- 4) Other (please specify): _______

**Answer**: 
1
---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream phases: read ONLY this section. -->
<!-- Auto-populated after user fills answers. One line per decision. -->
- DF-1 Team: 4 independent teams, each owns 1 unit end-to-end
- DF-2 Repo: Monorepo with Nx
- DF-3 Auth: JWT with RBAC — role claims in JWT, guard decorators in NestJS
- DF-4 Errors: NestJS default HttpException format
- DF-5 Comms: Direct module imports with defined interfaces (NestJS modules in same app)
- DF-6 Database: Single DB, separate schemas per unit (master_data, transactions, warehouse, reports)
- DF-7 Shared Types: Shared library in monorepo (libs/shared-types/)
- DF-8 ORM: Prisma — type-safe, schema-first
- DF-9 API Style: REST with OpenAPI/Swagger documentation
- DF-10 Testing: Unit tests (Jest) + Integration tests (Supertest) + E2E (Cypress/Playwright)
- DF-11 Infra Units: Single Foundation unit (scaffold, shared libs, auth, DB, CI/CD)
- DF-12 Frontend: Single Angular app with lazy-loaded feature modules per unit

---

**Instructions**: Fill in your answers above and respond with "done"
