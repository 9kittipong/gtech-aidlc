# Foundation Specification — Output Template

**Path**: `{SPECS_DIR}/{feature}/foundation.md`
**Condition**: Generated in incremental mode after units approved.
**Language**: Write ALL content in user's language. Keep technical terms, file paths, code unchanged.

## When to Generate

Generate when incremental mode is chosen and 2+ units defined.

For team-specific sections (Team Assignments, Sync Schedule, Risks, Ownership Rules), also load `foundation-team.md` when team size > 1.

## Template

````markdown
# Foundation Specification

## Summary
<!-- Compact digest for downstream agents. Read ONLY this section. -->
- **Team**: [Solo / Small team / Multiple teams]
- **Repo**: [Monorepo / Multi-repo / Hybrid]
- **Architecture**: [Modular Monolith / Microservices / Distributed]
- **Gateway**: [API Gateway / BFF / Direct / Hybrid / N/A]
- **Auth**: [JWT / Session / OAuth2 / API keys]
- **Error Format**: [RFC 7807 / Custom envelope / Framework default]
- **Inter-Unit Comms**: [REST / Events / gRPC / Mixed]
- **Database**: [Shared DB separate schemas / DB per unit / Mixed]
- **Shared Types**: [Shared package / Code generation / Manual sync]
- **Frontend**: [In monorepo / Separate repo / N/A] — [Shared UI: Yes/No]
- **Infrastructure Units**: [List or "None"]

---

## Repository Structure

**Strategy**: [Monorepo / Multi-repo / Hybrid]
**Rationale**: [Why this fits]

[If Monorepo]:
```
project-root/
├── apps/
│   ├── web/                    # Frontend web app (if frontend unit exists)
│   ├── admin/                  # Admin dashboard (if separate frontend unit)
│   ├── gateway/                # API Gateway (if infra unit)
│   ├── [backend-unit-1]/       # Backend domain unit
│   └── [backend-unit-2]/       # Backend domain unit
├── packages/
│   ├── shared-types/           # Shared DTOs, interfaces, event schemas
│   ├── shared-ui/              # Shared UI components (if multiple frontends)
│   ├── shared-auth/            # Auth middleware, token validation
│   ├── shared-errors/          # Error handling utilities
│   ├── shared-logging/         # Logging configuration
│   └── shared-config/          # Linting, formatting, build config
├── infrastructure/             # IaC templates
├── docker-compose.yml          # Local dev orchestration
└── [monorepo-config]           # turbo.json / nx.json / pnpm-workspace.yaml
```

**NOTE**: Include ALL units from units.md in the directory structure — both frontend and backend.

[If Multi-repo]: List repositories as `[feature]-[unit]/` per service, plus `[feature]-shared-libs/` for shared packages.

---

## API Architecture

[Only for microservices/distributed — skip for modular monolith]

**Pattern**: [API Gateway / BFF / Direct / Hybrid]
**Rationale**: [Why this pattern fits]

[If API Gateway]: Gateway handles routing, auth, rate limiting. Services are internal-only.
[If BFF]: List BFF per frontend type. Backend APIs are service-to-service.
[If Direct]: Each service handles auth, CORS, rate limiting. Service discovery via [method].
[If Hybrid]: External through gateway, service-to-service direct.

---

## Authentication & Authorization

**Approach**: [JWT / Session / OAuth2 / API keys]
**Authorization**: [RBAC / ABAC / Simple role check]
**Enforced at**: [Gateway / Unit level / Both]

**Shared Auth Contract**: `AuthContext { userId, roles, permissions }` — implemented as middleware returning context or error.

---

## Error Handling

**Format**: [RFC 7807 / Custom envelope / Framework default]
**Code Convention**: `[DOMAIN]_[NUMBER]` — e.g., `AUTH_001`, `VALIDATION_001`
**Standard Shape**: `{ code, message, status, details?, requestId }`

**Shared Codes**: VALIDATION_001 (400), AUTH_001 (401), AUTH_002 (403), NOT_FOUND (404), INTERNAL (500)

---

## Inter-Unit Communication

**Pattern**: [REST / Events / gRPC / Mixed]
**Convention**: [REST: `/api/v1/[unit]/[resource]` / Events: `[unit].[entity].[action]` / gRPC: `[Unit]Service`]
**Timeout/Retry**: [Policy]

**Event Schema** (if event-driven): `DomainEvent<T> { eventId, eventType, timestamp, source, data: T }`

---

## Database Strategy

**Approach**: [Shared DB separate schemas / DB per unit / Mixed]

[If shared DB]: Schema convention `[unit]_schema`, cross-schema access rules
[If DB per unit]: Naming `[feature]-[unit]-db`, cross-unit data via API/events

---

## Shared Types & Contracts

**Strategy**: [Shared package / Code generation / Manual sync]

[If shared package]: Location `packages/shared-types/`, versioning approach
[If code generation]: Source of truth (OpenAPI/GraphQL/Proto), generation tool

---

## Code & Data Conventions

### Code
- **Language**: [Shared language and version]
- **Naming**: [File, class, function naming patterns]
- **Testing**: [Shared framework and approach]
- **Linting/Formatting**: [Shared config and tools]

### Data
- **IDs**: [UUID v4 / ULID / auto-increment]
- **Timestamps**: [ISO 8601 UTC / Unix epoch]
- **Soft deletes**: [Yes with deletedAt / No]

---

## Integration Contracts

High-level interface sketches. Full API specs defined during each unit's design phase.

### [Unit A] → [Unit B]

**Endpoints** (sketch):
```
[METHOD] /api/v1/[resource]     → [Purpose]
[METHOD] /api/v1/[resource]/:id → [Purpose]
```

**Key data shape**:
```typescript
interface [EntityName] {
  id: string;
  [key fields]
}
```

**Events** (if event-driven): `[domain].[entity].[action]` — [When triggered]

---

## Infrastructure Units

[If identified — these get added to units.md]

### [Infrastructure Unit Name]

**Type**: Infrastructure (not domain)
**Purpose**: [What it does]
**Priority**: Design and implement BEFORE domain units
**Responsibilities**: [List]
**Stories**: None (cross-cutting)
**Depended on by**: [Domain units]

---

## Logging & Observability

**Log Format**: [Structured JSON / Plain text]
**Correlation**: Request ID via `X-Request-Id` header
**Log Levels**: error, warn, info, debug
````
