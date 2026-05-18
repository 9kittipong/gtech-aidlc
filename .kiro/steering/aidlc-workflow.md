---
inclusion: always
---
# AI-DLC Workflow Active — autoflow

## ⚠️ MANDATORY — Read Every Turn

This project uses AI-DLC skills for specification and implementation. Follow the skill workflow — do NOT generate spec artifacts outside of it.

- **Manifest**: `.aidlc/workflow/autoflow/aidlc-manifest.yaml`
- **Specs**: `.kiro/specs/autoflow/`
- **Workflow**: `.aidlc/workflow/autoflow/`

## Available Skills

| Skill | Phase | What it does |
|---|---|---|
| aidlc-context | 1 | Workspace scan, context assessment, steering files |
| aidlc-requirements | 2 | User stories with EARS acceptance criteria |
| aidlc-decomposition | 3 | Unit breakdown and foundation (if complex) |
| aidlc-design | 4 | Technology decisions and architecture |
| aidlc-tasks | 5 | Implementation task planning with execution waves |
| aidlc-implement | 6 | Code generation following design specs |
| aidlc-prototype | — | Quick throwaway prototype to validate requirements |

## Recovery (after context compaction)

1. Read `.aidlc/workflow/autoflow/aidlc-manifest.yaml` for current state
2. Read steering files at `.kiro/steering/` for project context
3. Activate the skill for the current phase
4. Resume from where the manifest indicates

## Current State

- **Feature**: autoflow
- **Language**: th (Thai)
- **Specs**: `.kiro/specs/autoflow/`

## Implementation Context

When implementing tasks, read design documents first:
- `design.md` — architecture overview
- `design/components.md` — component specs
- `design/data-model.md` — entities and schemas
- `design/api-spec.md` — endpoints and contracts
- `design/integration.md` — external services
- `design/implementation.md` — directory structure and conventions

Follow technology stack and patterns from design decisions. Follow testing approach from D4 decisions.
