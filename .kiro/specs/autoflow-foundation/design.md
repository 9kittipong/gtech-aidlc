# Design: Foundation Unit

## Summary
- **Architecture**: Modular Monolith — Nx monorepo with NestJS modules and Angular lazy-loaded features
- **Stack**: Angular / NestJS / PostgreSQL / Prisma / Nx
- **Components**: 7 — SharedAuth, SharedPrisma, SharedErrors, SharedTypes, SharedConfig, AppShell (API), AppShell (Web)
- **Entities**: 3 — User, Role, RefreshToken
- **Endpoints**: 4 — login, register, refresh, me

## Architecture

**Pattern**: Modular Monolith with Nx Monorepo

```
┌─────────────────────────────────────────────────────────┐
│                    Nx Monorepo                           │
├─────────────────────────────────────────────────────────┤
│  apps/                                                  │
│  ├── api/          (NestJS app shell — imports modules) │
│  └── web/          (Angular app — lazy-loaded routes)   │
├─────────────────────────────────────────────────────────┤
│  libs/                                                  │
│  ├── shared-types/    (TxType, DTOs, interfaces)        │
│  ├── shared-auth/     (JWT, Guards, RBAC)               │
│  ├── shared-prisma/   (Prisma client, schema)           │
│  ├── shared-errors/   (DomainException, error codes)    │
│  ├── shared-config/   (ESLint, Prettier, tsconfig)      │
│  ├── shared-utils/    (date, currency, validation)      │
│  ├── master-data/     (Unit 1 — future)                 │
│  ├── transactions/    (Unit 2 — future)                 │
│  ├── warehouse/       (Unit 3 — future)                 │
│  └── reports/         (Unit 4 — future)                 │
├─────────────────────────────────────────────────────────┤
│  prisma/                                                │
│  ├── schema.prisma    (multi-schema: master_data,       │
│  │                     transactions, warehouse, reports) │
│  ├── migrations/                                        │
│  └── seed.ts                                            │
├─────────────────────────────────────────────────────────┤
│  docker-compose.yml   (PostgreSQL)                      │
│  .github/workflows/   (CI/CD with Nx affected)          │
│  nx.json, tsconfig.base.json, .eslintrc.json            │
└─────────────────────────────────────────────────────────┘
```

---

## Components

### SharedAuth
- **Purpose**: JWT authentication and RBAC authorization for all units
- **Technology**: @nestjs/jwt + @nestjs/passport + bcrypt
- **Responsibilities**: Token generation/validation, password hashing, role guards, current user decorator
- **Exposes**: JwtAuthGuard, RolesGuard, @Roles() decorator, @CurrentUser() decorator, AuthService
- **Consumes**: SharedPrisma (User entity)

### SharedPrisma
- **Purpose**: Database access layer with Prisma client and multi-schema support
- **Technology**: Prisma ORM with PostgreSQL
- **Responsibilities**: Prisma client singleton, connection management, migrations, seeding
- **Exposes**: PrismaService (extends PrismaClient), PrismaModule (global)
- **Consumes**: PostgreSQL database

### SharedErrors
- **Purpose**: Standardized error handling across all units
- **Technology**: NestJS HttpException + custom DomainException
- **Responsibilities**: Domain exception classes, global exception filter, error code registry
- **Exposes**: DomainException, StockNegativeException, PeriodLockedException, ImmutableTxException, AllExceptionsFilter
- **Consumes**: None

### SharedTypes
- **Purpose**: Shared TypeScript types, enums, interfaces, and DTOs
- **Technology**: TypeScript library (no runtime dependencies)
- **Responsibilities**: TxType enum, TxStatus enum, ApArStatus enum, VatType enum, shared DTOs, service interfaces
- **Exposes**: All shared types and interfaces
- **Consumes**: None

### SharedConfig
- **Purpose**: Shared development tooling configuration
- **Technology**: ESLint, Prettier, TypeScript
- **Responsibilities**: Linting rules, formatting rules, TypeScript strict config, path aliases
- **Exposes**: ESLint config, Prettier config, tsconfig presets
- **Consumes**: None

### AppShell (API)
- **Purpose**: NestJS application entry point that imports all unit modules
- **Technology**: NestJS + @nestjs/config + @nestjs/swagger
- **Responsibilities**: App bootstrap, global pipes/filters/interceptors, Swagger setup, module registration
- **Exposes**: HTTP API on configured port
- **Consumes**: All unit modules, SharedAuth, SharedPrisma, SharedErrors, SharedConfig

### AppShell (Web)
- **Purpose**: Angular application entry point with lazy-loaded routing
- **Technology**: Angular + Angular Router
- **Responsibilities**: App bootstrap, root routing with lazy-loaded feature modules, shared layout (header, sidebar, navigation)
- **Exposes**: Web UI on configured port
- **Consumes**: API endpoints via HttpClient

---

## Data Model

### User
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, default uuid() | Unique user identifier |
| username | String | Unique, not null | Login username |
| email | String | Unique, not null | User email |
| passwordHash | String | Not null | bcrypt hashed password |
| displayName | String | Not null | Display name in UI |
| roles | Role[] | Not null, default [] | Assigned roles (RBAC) |
| isActive | Boolean | Default true | Account active status |
| createdAt | DateTime | Default now() | Account creation time |
| updatedAt | DateTime | Auto-update | Last modification time |

**Schema**: `master_data`
**Indexes**: username (unique), email (unique)

### Role (Enum)
```
CASHIER | STORE | SUPERVISOR | MANAGER | CFO | ADMIN
```

### RefreshToken
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK | Token identifier |
| userId | UUID | FK → User.id | Owner of the token |
| token | String | Unique, not null | Hashed refresh token |
| expiresAt | DateTime | Not null | Token expiration |
| createdAt | DateTime | Default now() | Token creation time |
| revokedAt | DateTime | Nullable | When token was revoked |

**Schema**: `master_data`
**Indexes**: token (unique), userId + revokedAt (composite for active token lookup)

---

## API Specification

**Base URL**: `/api/v1`
**Auth**: JWT Bearer token in Authorization header
**Docs**: Swagger UI at `/api/docs`
**Versioning**: URL path prefix (`/api/v1/`)

### POST /api/v1/auth/login
- **Description**: Authenticate user and return JWT tokens
- **Auth**: Public
- **Request**: `{ username: string, password: string }`
- **Response 200**: `{ accessToken: string, refreshToken: string, user: { id, username, displayName, roles } }`
- **Errors**: 401 Invalid credentials

### POST /api/v1/auth/register
- **Description**: Create new user account (Admin only)
- **Auth**: ADMIN role required
- **Request**: `{ username: string, email: string, password: string, displayName: string, roles: Role[] }`
- **Response 201**: `{ id: string, username: string, email: string, displayName: string, roles: Role[] }`
- **Errors**: 400 Validation error, 409 Username/email already exists

### POST /api/v1/auth/refresh
- **Description**: Refresh access token using refresh token
- **Auth**: Public (refresh token in body)
- **Request**: `{ refreshToken: string }`
- **Response 200**: `{ accessToken: string, refreshToken: string }`
- **Errors**: 401 Invalid/expired refresh token

### GET /api/v1/auth/me
- **Description**: Get current authenticated user profile
- **Auth**: Any authenticated user
- **Response 200**: `{ id, username, email, displayName, roles, isActive, createdAt }`
- **Errors**: 401 Not authenticated

---

## Implementation

### Directory Structure
```
autoflow/
├── apps/
│   ├── api/
│   │   ├── src/
│   │   │   ├── app.module.ts          # Root module — imports all
│   │   │   ├── main.ts                # Bootstrap + Swagger setup
│   │   │   └── app.controller.ts      # Health check endpoint
│   │   ├── project.json               # Nx project config
│   │   └── tsconfig.app.json
│   └── web/
│       ├── src/
│       │   ├── app/
│       │   │   ├── app.component.ts   # Root component
│       │   │   ├── app.routes.ts      # Lazy-loaded routes
│       │   │   ├── core/              # Guards, interceptors, services
│       │   │   └── shared/            # Shared UI components (layout, nav)
│       │   ├── environments/
│       │   └── main.ts
│       ├── project.json
│       └── tsconfig.app.json
├── libs/
│   ├── shared-types/
│   │   └── src/
│   │       ├── index.ts               # Barrel export
│   │       ├── enums/                 # TxType, TxStatus, Role, etc.
│   │       ├── dto/                   # Shared DTOs
│   │       └── interfaces/            # Service interfaces
│   ├── shared-auth/
│   │   └── src/
│   │       ├── index.ts
│   │       ├── auth.module.ts
│   │       ├── auth.service.ts
│   │       ├── jwt.strategy.ts
│   │       ├── guards/
│   │       │   ├── jwt-auth.guard.ts
│   │       │   └── roles.guard.ts
│   │       └── decorators/
│   │           ├── roles.decorator.ts
│   │           └── current-user.decorator.ts
│   ├── shared-prisma/
│   │   └── src/
│   │       ├── index.ts
│   │       ├── prisma.module.ts
│   │       └── prisma.service.ts
│   ├── shared-errors/
│   │   └── src/
│   │       ├── index.ts
│   │       ├── domain-exception.ts
│   │       ├── exceptions/            # Per-domain exceptions
│   │       └── filters/
│   │           └── all-exceptions.filter.ts
│   └── shared-utils/
│       └── src/
│           ├── index.ts
│           ├── date.utils.ts
│           ├── currency.utils.ts
│           └── period.utils.ts
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── docker-compose.yml
├── .github/
│   └── workflows/
│       └── ci.yml
├── nx.json
├── tsconfig.base.json
├── .eslintrc.json
├── .prettierrc
├── jest.preset.js
└── package.json
```

### Dev Setup
```bash
# 1. Clone and install
git clone <repo-url> && cd autoflow
npm install

# 2. Start PostgreSQL
docker compose up -d

# 3. Create schemas and run migrations
npx prisma migrate dev

# 4. Seed development data
npx prisma db seed

# 5. Start API (dev mode)
npx nx serve api

# 6. Start Web (dev mode)
npx nx serve web

# 7. Run tests
npx nx run-many --target=test --all
npx nx run-many --target=lint --all
```

### Conventions
- **Files**: kebab-case (`tx-log.service.ts`, `create-tx.dto.ts`)
- **Code**: Layered — Controller → Service → Repository (Prisma)
- **Tests**: Jest, co-located (`*.spec.ts` next to source), Supertest for API integration
- **Nx Libraries**: Each lib has `data-access/`, `feature/`, `ui/` sub-libraries following Nx conventions
- **Imports**: Use Nx path aliases (`@autoflow/shared-types`, `@autoflow/shared-auth`, etc.)

---

## CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: autoflow_test
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports: ['5432:5432']
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - uses: nrwl/nx-set-shas@v4
      - run: npx nx affected --target=lint
      - run: npx nx affected --target=test
      - run: npx nx affected --target=build
```

---

## Traceability

| Responsibility | Component | API | Data |
|----------------|-----------|-----|------|
| Authentication | SharedAuth | POST /auth/login, /auth/refresh | User, RefreshToken |
| User Management | SharedAuth | POST /auth/register, GET /auth/me | User |
| RBAC Authorization | SharedAuth (Guards) | All protected endpoints | Role enum |
| DB Access | SharedPrisma | — | All entities |
| Error Handling | SharedErrors | All endpoints (filter) | — |
| Shared Types | SharedTypes | — | TxType, TxStatus, DTOs |
| Dev Tooling | SharedConfig | — | — |
| API Shell | AppShell (API) | All /api/v1/* | — |
| Web Shell | AppShell (Web) | — | — |
