# Implementation Template

**Path**: `{SPECS_DIR}/{feature}/design/implementation.md`

Directory structure, code organization, dev setup, and conventions. This is the engineer's reference for project scaffold and daily development.

```markdown
# Implementation Specifications

## Code Organization

**Architecture Pattern**: [Layered/Clean/Hexagonal/Feature-based/MVC]
**Repository**: [Single Repo/Monorepo/Multi-Repo]

### Directory Structure
```
[Planned directory layout with purpose comments]
src/
  ├── controllers/     # HTTP request handlers
  ├── services/        # Business logic
  ├── models/          # Data models / entities
  ├── middleware/       # Auth, validation, error handling
  ├── utils/           # Shared utilities
  └── config/          # Configuration
tests/
  ├── unit/
  ├── integration/
  └── e2e/
```

### Module Boundaries
- [Rule 1 — e.g., "Controllers must not contain business logic"]
- [Rule 2 — e.g., "Domain layer independent of infrastructure"]

### Naming Conventions
- **Files**: [kebab-case/camelCase]
- **Classes**: [PascalCase]
- **Functions**: [camelCase]
- **Constants**: [UPPER_SNAKE_CASE]

---

## Technology Stack

### Dependencies
Key dependencies listed in project configuration file ([package.json/requirements.txt/pom.xml]).

### Monorepo Configuration (if applicable)
- **Tool**: [Nx/Turborepo/pnpm workspaces]
- **Packages**: [List main packages]

---

## Development Setup

### Prerequisites
- [Runtime] v[X]+
- [Package manager]
- [Database] (or Docker)

### Setup Commands
```bash
git clone [repo-url]
[package-manager] install
cp .env.example .env
[migration-command]
[start-command]
```

### Environment Variables
| Variable | Description | Example |
|----------|-------------|---------|
| DATABASE_URL | DB connection string | postgresql://... |
| JWT_SECRET | Auth token secret | [generated] |

---

## Testing

**Unit Tests**: [Framework] — `[run command]`
**Integration Tests**: [Framework] — `[run command]`
**E2E Tests**: [Framework] — `[run command]`
**PBT**: [Framework] — `[run command]` (if applicable)

**Coverage Target**: [X%]
```
