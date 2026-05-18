---
inclusion: always
---
# Technology Context

## Summary
- **Stack**: TypeScript / Angular + NestJS / PostgreSQL
- **Architecture**: Modular Monolith — Transaction Log Engine
- **Infra**: Pending D3 decisions

## Stack

- **Languages**: TypeScript 5.x (strict mode)
- **Frameworks**: Angular (Frontend), NestJS (Backend)
- **Build System**: Nx (monorepo)
- **Package Manager**: npm
- **Testing**: Jest + Supertest + Playwright

## Architecture

- **Pattern**: Modular Monolith — Transaction Log Engine at core
- **API Style**: REST with OpenAPI/Swagger

## Infrastructure

- **Cloud Provider**: Pending D3 decisions
- **Compute**: Pending D3 decisions
- **Database**: PostgreSQL (single DB, multi-schema)
- **IaC Tool**: Pending D3 decisions

## Patterns & Conventions

Defined during Foundation phase:

- **Architecture pattern**: Modular Monolith — NestJS modules with defined interfaces, direct imports between units
- **Data access**: Prisma ORM with multi-schema support (master_data, transactions, warehouse, reports)
- **API response format**: NestJS default HttpException format
- **Error handling**: DomainException extending HttpException with domain-specific error codes (STOCK_NEGATIVE, PERIOD_LOCKED, TX_IMMUTABLE, etc.)
- **Authentication**: JWT with RBAC — role claims in token, NestJS Guards (JwtAuthGuard → RolesGuard)
- **Validation**: Prisma schema validation + class-validator decorators in DTOs
- **Logging**: Structured JSON with correlation ID (X-Request-Id), NestJS Logger
- **Code style**: ESLint + Prettier (shared config in monorepo root)
- **Naming conventions**: kebab-case files, PascalCase classes, camelCase functions, snake_case DB tables
- **Branch strategy**: Feature branches per unit, PR-based merge with team review

## Shared Conventions (Foundation Decisions)

- **Repo**: Monorepo with Nx — shared build, affected-based CI
- **Auth**: JWT + RBAC (6 roles: Cashier, Store, Supervisor, Manager, CFO, Admin)
- **Errors**: NestJS HttpException + custom DomainException classes
- **Inter-Unit Comms**: Direct NestJS module imports with exported service interfaces
- **Database**: Single PostgreSQL DB, separate schemas per unit (master_data, transactions, warehouse, reports)
- **Shared Types**: libs/shared-types/ — TxType enum, DTOs, service interfaces
- **ORM**: Prisma (type-safe, schema-first, multi-schema)
- **API**: REST with OpenAPI/Swagger documentation
- **Testing**: Jest (unit) + Supertest (integration) + Playwright (E2E)
- **Frontend**: Single Angular app with lazy-loaded feature modules per unit
- **IDs**: UUID v4
- **Timestamps**: ISO 8601 UTC
- **Currency**: THB, Decimal(10,2)

## Environment Configuration

Will be defined during design phase.

## CI/CD Pipeline

Pending D3 decisions.

## Dependency Management

- **Lockfile**: package-lock.json (committed)
- **Version strategy**: Exact versions for production deps
- **Monorepo tooling**: Nx
