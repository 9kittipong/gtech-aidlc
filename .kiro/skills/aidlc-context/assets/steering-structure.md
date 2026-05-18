# Steering: Structure — Output Template

Generate `{STEERING_DIR}/structure.md` with this structure.

**Kiro only**: Add `inclusion: always` YAML front-matter.
**Progressive enrichment**: Phase 1 creates (detected or placeholders), Phase 4 updates with design structure.
**Brownfield**: Detect from codebase — directory tree, imports, config files.
**Greenfield**: Use placeholders. Most sections filled during design phase.

```markdown
# Project Structure

## Summary
<!-- 3-line max -->
- **Repo**: [Type — Monorepo/Multi-repo/Single or "Pending D3"]
- **Source**: [Key source directories]
- **Entry**: [Main entry points or "Pending Phase 4"]

## Repository

- **Type**: [Monorepo / Multi-repo / Single repo / "Pending D3 decisions"]
- **Root**: [Brief description of workspace root]

## Key Directories

| Directory | Purpose | Key Contents |
|-----------|---------|-------------|
| [src/ or detected] | [Source code] | [e.g., "routes/, services/, models/"] |
| [tests/ or detected] | [Test files] | [e.g., "unit/, integration/, fixtures/"] |
| [docs/ or detected] | [Documentation] | [e.g., "API docs, architecture diagrams"] |
| [config/ or detected] | [Configuration] | [e.g., "env configs, feature flags"] |

[Greenfield: "Directory structure will be defined during design phase."]

## Key Files

| File | Purpose | Notes |
|------|---------|-------|
| [package.json or detected] | [Dependencies and scripts] | [e.g., "Key scripts: dev, build, test, lint"] |
| [tsconfig.json or detected] | [TypeScript config] | [e.g., "Strict mode, path aliases: @/src/*"] |
| [Detected config files] | [Purpose] | [Notable settings] |

[Greenfield: "Key files will be defined during design phase."]

## Entry Points

[Brownfield: List detected entry points with what they do]

| Entry Point | Type | Description |
|-------------|------|-------------|
| [src/index.ts] | [API server] | [Express app, listens on PORT] |
| [src/worker.ts] | [Background worker] | [Processes queue jobs] |

[Greenfield: "Entry points will be defined during design phase."]

## Module Dependencies
[Brownfield only — omit for greenfield]

How modules depend on each other. Detected from import statements.

```
routes/ → controllers/ → services/ → repositories/ → database
                                   → external-apis/
middleware/ → services/ (auth, logging)
```

Key dependency rules:
- [e.g., "Routes never import repositories directly — always go through services"]
- [e.g., "Models are shared across services — imported from models/"]
- [e.g., "No circular dependencies detected" or "Circular dependency between X and Y"]

## Data Flow
[Brownfield only — omit for greenfield]

How a typical request moves through the system:

```
Client Request
  → [Middleware: auth, logging, rate-limit]
  → [Route handler: validate input, extract params]
  → [Service: business logic, orchestration]
  → [Repository: data access, queries]
  → [Database / External API]
  → [Response: serialize, format, send]
```

[Adapt to the actual detected pattern. If event-driven, show event flow instead.]

## Key Abstractions
[Brownfield only — omit for greenfield]

Important interfaces, base classes, or patterns the codebase is built on:

| Abstraction | Location | Purpose | Used By |
|-------------|----------|---------|---------|
| [BaseController] | [src/core/] | [Common controller logic: error handling, response formatting] | [All controllers] |
| [Repository<T>] | [src/core/] | [Generic data access interface] | [All repositories] |
| [AuthMiddleware] | [src/middleware/] | [JWT verification, user context injection] | [All protected routes] |

[If no clear abstractions detected: omit this section.]

## Test Organization
[Brownfield only — omit for greenfield]

- **Test location**: [e.g., "Co-located: *.test.ts next to source", "Separate: tests/ directory mirroring src/"]
- **Test types present**: [e.g., "Unit tests (Jest), Integration tests (Supertest), No E2E"]
- **Test utilities**: [e.g., "tests/helpers/: factory functions, mock builders, test database setup"]
- **Coverage**: [e.g., "~65% overall, lowest in payments module (~30%)"]
- **Run command**: [e.g., "npm test (unit), npm run test:integration, npm run test:e2e"]

## Build & Deploy Artifacts
[Brownfield only — omit for greenfield]

- **Build output**: [e.g., "dist/ — compiled TypeScript", "build/ — Next.js output", ".next/ — SSR bundle"]
- **Container**: [e.g., "Dockerfile at root, multi-stage build", "No containerization"]
- **Deploy target**: [e.g., "AWS ECS Fargate", "Vercel", "Manual SSH deploy"]
```
