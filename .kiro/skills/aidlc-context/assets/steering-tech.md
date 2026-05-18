# Steering: Tech — Output Template

Generate `{STEERING_DIR}/tech.md` with this structure.

**Kiro only**: Add `inclusion: always` YAML front-matter.
**Progressive enrichment**: Phase 1 creates (detected or placeholders), Phase 4 updates with D3 decisions.
**Brownfield**: Detect from codebase — config files, package manifests, source patterns.
**Greenfield**: Use placeholders ("Pending D3 decisions") for undecided items.

```markdown
# Technology Context

## Summary
<!-- 3-line max -->
- **Stack**: [Language / Framework / DB or "Pending D3"]
- **Architecture**: [Pattern / API style or "Pending D2/D3"]
- **Infra**: [Cloud / Compute / IaC or "Pending D3"]

## Stack

- **Languages**: [Detected or "Pending D3 decisions"]
- **Frameworks**: [Detected or "Pending D3 decisions"]
- **Build System**: [Detected or "Pending D3 decisions"]
- **Package Manager**: [Detected or "Pending D3 decisions"]
- **Testing**: [Detected or "Pending D3 decisions"]

## Architecture

- **Pattern**: [Monolith / Microservices / Serverless / "Pending D2/D3 decisions"]
- **API Style**: [REST / GraphQL / gRPC / "Pending D3 decisions"]

## Infrastructure

- **Cloud Provider**: [Detected or "Pending D3 decisions"]
- **Compute**: [Detected or "Pending D3 decisions"]
- **Database**: [Detected or "Pending D3 decisions"]
- **IaC Tool**: [Detected or "Pending D3 decisions"]

## Patterns & Conventions

How the codebase is structured and how things are done — not just what tools, but how they're used.

[Brownfield: Detect from source code. Look at existing patterns, not just config files.]
[Greenfield: "Will be defined during design phase."]

- **Architecture pattern**: [e.g., "Layered: routes → controllers → services → repositories", "Clean architecture with use cases", "MVC"]
- **Data access**: [e.g., "Repository pattern with Prisma ORM", "Direct SQL queries via pg pool", "Mongoose models"]
- **API response format**: [e.g., "Envelope: { data, error, meta }", "Direct JSON", "JSON:API"]
- **Error handling**: [e.g., "Custom AppError class thrown in services, caught by error middleware", "try/catch per route"]
- **Authentication**: [e.g., "JWT in Authorization header, verified by auth middleware", "Session-based with Passport.js"]
- **Validation**: [e.g., "Zod schemas at route level", "Joi in controllers", "Class-validator decorators"]
- **Logging**: [e.g., "Winston with structured JSON, correlation ID via cls-hooked", "console.log"]
- **Code style**: [Detected from ESLint/Prettier/EditorConfig or "Not configured"]
- **Naming conventions**: [e.g., "camelCase for files, PascalCase for classes, kebab-case for routes"]
- **Branch strategy**: [Detected from git or "Not detected"]

## Environment Configuration

[Brownfield: Detect from .env files, config modules, deployment configs.]
[Greenfield: "Will be defined during design phase."]

- **Config approach**: [e.g., "dotenv with .env files per environment", "AWS SSM Parameter Store", "Hardcoded"]
- **Environments**: [e.g., "development, staging, production" or "local only"]
- **Secrets management**: [e.g., "AWS Secrets Manager", ".env files (not committed)", "Not configured"]

## CI/CD Pipeline

[Brownfield: Detect from .github/workflows/, .gitlab-ci.yml, Jenkinsfile, etc.]
[Greenfield: "Pending D3 decisions."]

- **Tool**: [e.g., "GitHub Actions", "GitLab CI", "None"]
- **Stages**: [e.g., "lint → test → build → deploy" or "Not configured"]
- **Deploy target**: [e.g., "AWS ECS via CDK", "Vercel auto-deploy", "Manual"]

## Dependency Management

- **Lockfile**: [e.g., "package-lock.json committed", "pnpm-lock.yaml", "No lockfile"]
- **Version strategy**: [e.g., "Exact versions", "Caret ranges", "Not enforced"]
- **Monorepo tooling**: [e.g., "Turborepo", "Nx", "pnpm workspaces", "N/A"]

## Known Technical Debt
[Brownfield only — omit for greenfield]

Areas of the codebase that are fragile, deprecated, or need attention:

- [e.g., "Auth module uses deprecated passport-local, should migrate to passport-jwt"]
- [e.g., "No database migrations — schema changes are manual SQL scripts"]
- [e.g., "Test coverage is <20% in the payments module"]
- [e.g., "Mixed CommonJS and ESM imports causing bundling issues"]

[If none detected: omit this section.]
```
