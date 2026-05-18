# Foundation Unit — Design Decisions

## Context Summary
- **Unit**: Foundation (Infrastructure)
- **Purpose**: Nx workspace scaffold, shared libs, Prisma schema, JWT auth, Docker Compose, CI/CD
- **Stack**: TypeScript / Angular + NestJS / PostgreSQL / Prisma / Nx
- **Pre-decided** (from DF): Monorepo/Nx, JWT/RBAC, NestJS HttpException, Direct imports, Single DB separate schemas, Shared lib, Prisma, REST/OpenAPI, Jest+Supertest+Playwright, Single Angular app lazy-loaded
- **Stories**: None (infrastructure unit)

---

## Decision Questions

### D3-1: Nx Workspace Preset
**Question**: Which Nx preset should be used to scaffold the monorepo?
- 1) @nx/nest + @nx/angular — official Nx plugins for both frameworks **(Recommended)**
- 2) @nx/node + @nx/angular — generic Node.js backend with Angular
- 3) Custom workspace — manual setup without presets
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-2: Prisma Schema Organization
**Question**: How should the Prisma schema be organized for multi-schema support?
- 1) Single schema.prisma file with @@schema annotations per model **(Recommended)**
- 2) Multiple .prisma files merged via prisma-merge tool
- 3) Separate Prisma clients per schema (independent migrations)
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-3: JWT Implementation
**Question**: Which library should handle JWT token generation and validation in NestJS?
- 1) @nestjs/jwt + @nestjs/passport — official NestJS JWT integration **(Recommended)**
- 2) jose — lightweight, standards-compliant JWT library
- 3) jsonwebtoken — popular Node.js JWT library (manual integration)
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-4: Password Hashing
**Question**: Which algorithm for hashing user passwords?
- 1) bcrypt — battle-tested, widely used **(Recommended)**
- 2) Argon2 — newer, memory-hard, recommended by OWASP
- 3) scrypt — good balance of security and performance
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-5: Configuration Management
**Question**: How should environment configuration be managed?
- 1) @nestjs/config with .env files per environment **(Recommended)**
- 2) Custom config module with YAML files
- 3) Environment variables only (no config library)
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-6: Validation Library
**Question**: Which validation library for DTOs and request validation?
- 1) class-validator + class-transformer — decorator-based, NestJS native **(Recommended)**
- 2) Zod — schema-first, type inference
- 3) Joi — schema-based, mature
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-7: API Documentation
**Question**: How should REST API documentation be generated?
- 1) @nestjs/swagger — auto-generate OpenAPI from decorators **(Recommended)**
- 2) Manual OpenAPI YAML maintained separately
- 3) Redoc with manually written spec
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-8: Database Seeding
**Question**: How should development seed data be managed?
- 1) Prisma seed script (prisma/seed.ts) with faker data **(Recommended)**
- 2) SQL seed files executed via migration
- 3) Custom NestJS CLI command for seeding
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-9: Docker Compose Services
**Question**: Which services should Docker Compose include for local development?
- 1) PostgreSQL + Redis (cache/session) + pgAdmin **(Recommended)**
- 2) PostgreSQL only — minimal setup
- 3) PostgreSQL + Redis + Mailhog (email testing) + pgAdmin
- 4) Other (please specify): _______

**Answer**: 
2
---

### D3-10: CI/CD Pipeline
**Question**: Which CI/CD platform should be configured?
- 1) GitHub Actions with Nx affected commands **(Recommended)**
- 2) GitLab CI with Nx affected
- 3) Azure DevOps Pipelines
- 4) Other (please specify): _______

**Answer**: 
1
---

### D3-11: Correctness & Property-Based Testing
**Question**: Should the Foundation unit include property-based testing setup for verifying correctness properties (e.g., MA calculation invariants, stock balance consistency)?
- 1) Yes — set up fast-check library with shared test utilities for PBT **(Recommended)**
- 2) Yes — but defer to domain units (just install the library)
- 3) No — rely on example-based tests only
- 4) Other (please specify): _______

**Answer**: 
3
---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream phases: read ONLY this section. -->
<!-- Auto-populated after user fills answers. One line per decision. -->
- D3-1 Nx Preset: @nx/nest + @nx/angular (official plugins)
- D3-2 Prisma Schema: Single schema.prisma with @@schema annotations
- D3-3 JWT Library: @nestjs/jwt + @nestjs/passport
- D3-4 Password Hash: bcrypt
- D3-5 Config: @nestjs/config with .env files
- D3-6 Validation: class-validator + class-transformer
- D3-7 API Docs: @nestjs/swagger (auto-generate OpenAPI)
- D3-8 Seeding: Prisma seed script (prisma/seed.ts) with faker
- D3-9 Docker: PostgreSQL only (minimal)
- D3-10 CI/CD: GitHub Actions with Nx affected
- D3-11 PBT: No — example-based tests only

---

**Instructions**: Fill in your answers above and respond with "done"
