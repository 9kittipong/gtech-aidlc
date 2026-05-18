# Tasks Output Template

**Path**: `{SPECS_DIR}/{feature}/tasks.md`

**CRITICAL**: Use Kiro-compatible checkbox format. Phase = top-level checkbox, Task = nested checkbox, Details = plain list items (no checkbox).

```markdown
# Implementation Tasks

## Overview
Tasks organized by [strategy from D4 — e.g., "vertical slices"].

**Derived From**:
- Requirements: [X] user stories from `requirements.md`
- Design: [Y] components, [Z] entities, [A] endpoints from `design/` folder

**Strategy**: [Vertical Slice / Layer-by-Layer / Feature-by-Feature / Component-First]
**Rationale**: [Why this strategy based on D4]

---

- [ ] 1. [Phase Name]
  - [ ] 1.1 [Task Title]
    - **Deps**: None | **Ref**: `design/implementation.md` — [section]
    - [Implementation detail or file to create]
    - [Another detail]
  - [ ] 1.2 [Task Title]
    - **Deps**: 1.1 | **Ref**: `design/components.md` — [component]
    - [Implementation detail]
    - [Testing requirement]

- [ ] 2. [Phase Name]
  - [ ] 2.1 [Task Title]
    - **Deps**: 1.1, 1.2 | **Ref**: `design/data-model.md` — [entity]
    - [Implementation detail]
  - [ ] 2.2 [Task Title]
    - **Deps**: 1.1 | **Ref**: `design/api-spec.md` — [endpoint]
    - [Implementation detail]

- [ ] 3. [Phase Name]
  - [ ] 3.1 [Task Title]
    - **Deps**: 2.1, 2.2 | **Ref**: `design/integration.md` — [integration]
    - [Implementation detail]

---

## Task Summary

| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | [Title] | None | [ ] |
| 1.2 | [Title] | 1.1 | [ ] |
| 2.1 | [Title] | 1.1, 1.2 | [ ] |
| 2.2 | [Title] | 1.1 | [ ] |
| 3.1 | [Title] | 2.1, 2.2 | [ ] |

---

## Requirements Coverage

| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-1 | Task 1.1, Task 2.1 | [ ] |
| US-2 | Task 2.2 | [ ] |

---

## Design Coverage

**Components**: [X] components → Tasks [list task IDs]
**Entities**: [Y] entities → Tasks [list task IDs]
**Endpoints**: [Z] endpoints → Tasks [list task IDs]
**Integrations**: [A] integrations → Tasks [list task IDs]

---

## Definition of Done

- [ ] Code written and follows standards
- [ ] Tests written and passing
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Acceptance criteria met

---

## Execution Waves

Phases grouped by dependency resolution. In parallel/autonomous mode, each phase in a wave is dispatched to its own sub-agent. Tasks within each phase are executed sequentially by the assigned sub-agent.

| Wave | Phases | Dependencies Resolved |
|------|--------|-----------------------|
| 1 | [1. Project Setup] | None (scaffold) |
| 2 | [2. Data Layer, 3. Auth] | Wave 1 |
| 3 | [4. API Endpoints] | Wave 2 |

### File Ownership Per Wave

[For parallel waves only — which files each phase owns to avoid conflicts]

**Wave 2**:
- Phase 2: `src/repositories/`, `src/models/`
- Phase 3: `src/middleware/auth/`, `src/config/auth.ts`

**Wave 3**:
- Phase 4: `src/routes/`, `src/controllers/`

---

## Notes

**Technical Debt**: [Known debt to address later]

**Future Enhancements**: [Deferred features from requirements/design]
```
