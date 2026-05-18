# AI-DLC — AI Development Lifecycle Skills

A structured, decision-driven workflow for AI-assisted software development. AI-DLC guides projects from initial context assessment through requirements, design, task planning, and implementation — with built-in decision gates, validation rules, and audit trails at every phase.

## Why AI-DLC

AI coding assistants are powerful but undirected. Without structure, they produce inconsistent architectures, skip edge cases, and make technology choices that don't align with your project. AI-DLC solves this by introducing a lightweight lifecycle that keeps the AI focused and the human in control.

- **Decision gates** at each phase surface the right questions and validate answers for conflicts before moving forward
- **Manifest-based state tracking** lets you pause, resume, and roll back across sessions
- **Incremental delivery** for complex projects — decompose into units, design and implement one at a time
- **Parallel implementation** via sub-agents with file ownership isolation
- **Multi-platform** — works on Kiro, Claude Code, Cursor, and Windsurf

## Quick Start

### Installation

```bash
# Clone the repo
git clone <repo-url> aidlc-skills
cd aidlc-skills

# Install into your project (default: Kiro)
./install.sh kiro /path/to/your/project

# Or for other platforms
./install.sh claude-code /path/to/your/project
./install.sh cursor /path/to/your/project
./install.sh windsurf /path/to/your/project
```

This copies all 11 skills into your project's platform directory (e.g., `.kiro/skills/`).

### Your First Feature

1. Activate the **aidlc-context** skill
2. Describe what you want to build
3. The skill scans your workspace, generates a context document, and hands off to requirements
4. Follow the prompts — each phase presents results, waits for your approval, then continues

That's it. Each skill tells you what's next.

### Quick Mode (Simple Features)

For straightforward brownfield features (≤5 stories, single domain):

1. Activate the **aidlc** orchestrator
2. Say "quick" — or the orchestrator will suggest it if it detects a simple feature
3. Describe what you want to build
4. Get a single combined spec (stories + design + tasks) in one pass — no decision gates
5. Say "implement" to start building

## Workflow Overview

```mermaid
flowchart TD
    A[Context] --> B[Requirements]
    B --> C{Complex?}
    C -->|Simple| D[Design]
    C -->|Complex| E[Decomposition]
    E --> F[Foundation]
    F --> Units

    subgraph Units ["For Each Unit"]
        direction TB
        UD[Design] --> UT[Tasks] --> UI[Implement]
    end

    Units --> SR[Solutions Review]
    SR --> CR[Code Review]
    D --> T[Tasks]
    T --> I[Implement]
    I --> CR
    B -.->|optional| P[Prototype]
    P -.->|refine| B
```

**Simple projects** skip decomposition and foundation — go straight from requirements to design.

**Complex projects** (5+ stories, 2+ domains) decompose into units, define a shared foundation, then design and implement each unit independently.

**Prototypes** are standalone side-quests — throwaway code to validate ideas before committing to a full design cycle.

## Skills Reference

### Core Workflow (in order)

| Skill | Phase | What It Does |
|---|---|---|
| `aidlc-context` | 1 | Scans workspace, detects stack and architecture (brownfield) or captures intent (greenfield). Produces `context.md` and steering files. Creates the manifest. |
| `aidlc-requirements` | 2 | Translates context into user stories with EARS acceptance criteria. Generates personas (optional). Routes to decomposition, design, or prototype based on complexity. |
| `aidlc-decomposition` | 3 | Breaks requirements into independently deliverable units using DDD concepts. Defines boundaries, dependencies, and development sequence. Presents incremental vs. comprehensive mode choice. |
| `aidlc-foundation` | 3b | Defines shared conventions for incremental mode — repo structure, auth, error handling, communication patterns, database strategy. Adds infrastructure units. |
| `aidlc-design` | 4 | Makes technology decisions via D3 decision gate. Generates component design, data model, API spec, integration patterns, and implementation plan. Supports compact (≤10 stories) and modular (11+) formats. |
| `aidlc-tasks` | 5 | Breaks design into sequenced, estimable tasks. Generates execution waves with file ownership for parallel dispatch. |
| `aidlc-implement` | 6 | Executes tasks in standard (one-at-a-time), parallel (wave-based sub-agents), or autonomous (all waves, no stops) mode. |

### Supporting Skills

| Skill | What It Does |
|---|---|
| `aidlc-prototype` | Builds a throwaway spike to validate requirements. No architecture, no tests, hardcoded data. Code goes to `.aidlc/prototype/`. |
| `aidlc-solutions-review` | Cross-unit design review. Compares 2+ unit designs for architectural conflicts, technology mismatches, integration gaps, and duplication. |
| `aidlc-code-review` | Reviews implemented code against design specs, security best practices, performance, test coverage, and coding standards. Produces severity-classified findings with suggested fixes. |
| `aidlc` | Workflow orchestrator. Reads manifest state, dispatches to phase skills by loading their SKILL.md, manages rollback and status display. One activation drives the entire workflow. |

## Decision Gates

Each phase has a decision gate that generates targeted questions, validates answers for conflicts, and ensures alignment before proceeding.

| Gate | Phase | Covers |
|---|---|---|
| D1 | Requirements | Feature scope, user types, core functionality, data entities, integrations, business rules, constraints |
| D2 | Decomposition | Architecture pattern, decomposition strategy, unit proposals, dependencies, development sequence |
| DF | Foundation | Team structure, repo strategy, API architecture, auth, error handling, inter-unit communication, database strategy |
| D3 | Design | Technology stack, frameworks, data layer, testing strategy, infrastructure, code organization |
| D4 | Tasks | Breakdown strategy, implementation approach (TDD/test-after), component priority, integration strategy, task granularity |

### How Decision Gates Work

1. The skill generates a decisions file with questions tailored to your project context
2. You fill in answers (or say "use recommendations" to auto-fill)
3. The skill validates for conflicts — e.g., "Enterprise scope with solo developer" or "Microservices with shared database"
4. Conflicts are classified by severity (🔴 Critical, 🟡 Major, 🟢 Minor) with resolution options
5. After resolution, the skill proceeds to generation

## Artifacts

AI-DLC produces artifacts at conventional paths. All paths are platform-aware.

### Spec Artifacts (`{SPECS_DIR}/{feature}/`)

| File | Produced By | Description |
|---|---|---|
| `context.md` | aidlc-context | Project landscape, stack, architecture, feature impact |
| `requirements.md` | aidlc-requirements | User stories with EARS acceptance criteria |
| `personas.md` | aidlc-requirements | User personas (conditional) |
| `units.md` | aidlc-decomposition | Unit boundaries, dependencies, development sequence |
| `foundation.md` | aidlc-foundation | Shared conventions and infrastructure |
| `design.md` | aidlc-design | Architecture overview and design summary |
| `design/components.md` | aidlc-design | Component breakdown |
| `design/data-model.md` | aidlc-design | Entity definitions, schemas, relationships |
| `design/api-spec.md` | aidlc-design | Endpoint specifications |
| `design/integration.md` | aidlc-design | External service and inter-unit integration |
| `design/implementation.md` | aidlc-design | Directory structure, conventions, project config |
| `design/correctness.md` | aidlc-design | Property-based testing properties (conditional) |
| `design/nfr.md` | aidlc-design | Non-functional requirements (conditional) |
| `tasks.md` | aidlc-tasks | Sequenced tasks with execution waves |

### Workflow Artifacts (`{WORKFLOW_DIR}/{feature}/`)

| File | Description |
|---|---|
| `aidlc-manifest.yaml` | Single source of truth for workflow state |
| `audit.md` | Chronological log of all actions taken |
| `decisions-{phase}.md` | Decision gate answers (one per phase that has a gate) |
| `architecture-review.md` | Solutions review findings |
| `code-review.md` | Code review findings |

Decision gate files are produced implicitly by each phase — they're not tracked in the manifest.

### Steering Files (`{STEERING_DIR}/`)

| File | Description |
|---|---|
| `product.md` | Product overview, target users, key features |
| `tech.md` | Technology stack, conventions, patterns |
| `structure.md` | Project directory structure and key files |
| `aidlc-workflow.md` | Workflow state reference for context recovery |
| `resources.md` | External resources (design tools, API specs, docs) |

### Path Variables

| Variable | Kiro | Claude Code | Cursor | Windsurf |
|---|---|---|---|---|
| `SPECS_DIR` | `.kiro/specs` | `.claude/specs` | `.cursor/specs` | `.windsurf/specs` |
| `STEERING_DIR` | `.kiro/steering` | `.claude/steering` | `.cursor/steering` | `.windsurf/steering` |
| `WORKFLOW_DIR` | `.aidlc/workflow` | `.aidlc/workflow` | `.aidlc/workflow` | `.aidlc/workflow` |

## Implementation Modes

The implementation skill offers three modes:

### Standard Mode
Tasks executed one at a time. You review and approve after each task. Best for learning the codebase or when you want tight control.

### Parallel Mode
Tasks grouped into dependency waves. Each wave dispatches one sub-agent per phase. Phases within a wave run simultaneously with isolated file ownership. You review after each wave.

- Requires Kiro Autopilot mode or Claude Code
- Not available on Cursor/Windsurf

### Autonomous Mode
All waves executed without stopping. Failed tasks retry up to 5 times, then get skipped. Tasks depending on failed tasks are also skipped. You get a single summary at the end.

- Same platform requirements as parallel mode
- Best when you trust the spec fully

## Incremental vs. Comprehensive

After decomposition, you choose a delivery mode:

**Comprehensive** — A single design covering all units. Best for tightly coupled units or small projects. Workflow: design → tasks → implement (all at once).

**Incremental** — Design, task, and implement one unit at a time. Requires a foundation spec first. Workflow: foundation → (select unit → design → tasks → implement) × N. Recommended for 2+ units.

In incremental mode, each unit gets its own scoped directory (`{SPECS_DIR}/{feature}-{unit}/`) with its own design docs and tasks.

## Extending AI-DLC

### Steering Files

Steering files in `{STEERING_DIR}/` provide persistent context across all interactions. They're created by the context skill and updated by downstream phases. You can also edit them manually to inject team standards, coding conventions, or project-specific guidance.

## Skill Anatomy

Each skill follows the same structure:

```
aidlc-{name}/
├── SKILL.md          # Skill instructions (the "brain")
├── assets/           # Output templates and decision gate templates
│   ├── decision-gate.md
│   └── {output-template}.md
└── references/       # Reference material loaded conditionally
    ├── {catalog}.md
    └── {guide}.md
```

- `SKILL.md` contains the full process: activation, initialization, actions, validation rules, behavioral rules, error recovery, and context recovery
- `assets/` contains templates that define the structure of generated artifacts
- `references/` (design skill only) contains technology catalogs, architecture guides, and validation rule sets loaded conditionally based on project context

## Context Recovery

Every skill includes a context recovery mechanism. If the AI's context window is compacted mid-phase:

1. Read `{STEERING_DIR}/aidlc-workflow.md` for the manifest path
2. Read the manifest for current phase and artifact paths
3. Read the skill's `SKILL.md` to reload instructions
4. Resume from the current action

The manifest and audit trail provide enough state to pick up where you left off.

## Manifest Schema (v2.0)

The manifest uses a compact phase-grouped format. Artifacts are grouped by the phase that produced them, not by individual file.

```yaml
version: "2.1"
feature: "notifications"
language: "en"
platform: "kiro"
created: "2026-04-15T10:00:00Z"
updated: "2026-04-15T11:30:00Z"

state:
  sharedPhases: [context, requirements, decomposition, foundation]
  mode: incremental
  status: active                # active | completed
  foundationSkipped: false

artifacts:
  context:
    status: approved
    timestamp: "2026-04-15T10:00:00Z"
    files: [context.md]
  requirements:
    status: approved
    timestamp: "2026-04-15T10:30:00Z"
    files: [requirements.md, personas.md]
  decomposition:
    status: approved
    timestamp: "2026-04-15T11:00:00Z"
    files: [units.md]
  foundation:
    status: approved
    timestamp: "2026-04-15T11:15:00Z"
    files: [foundation.md]

context-summary:
  type: Greenfield
  stack: "TypeScript / NestJS / PostgreSQL"
  architecture: "Modular Monolith"
  feature: "E-commerce platform"
  impact: "New standalone"
  complexity: High
  recommendations: { personas: true, units: true, nfr: true }

decisions:
  requirements: { scope: "Full product", user-types: 3, integrations: 2 }
  decomposition: { strategy: "domain-driven", units: 3 }
  foundation: { auth: "JWT", comms: "REST", db: "shared-separate-schemas" }

steering:
  updatedBy:
    product: [context, requirements]
    tech: [context, foundation, design]
    structure: [context, design]

units:
  - name: auth
    status: in-progress
    phase: implement
    completedPhases: [design, tasks]
    implementationMode: standard
    implementation: { totalTasks: 12, completedTasks: 8, currentTask: "3.2", currentWave: null }
    artifacts:
      design: { status: approved, timestamp: "...", files: [design.md, design/components.md] }
      tasks: { status: approved, timestamp: "...", files: [tasks.md] }
    decisions:
      design: { api-style: "REST", database: "PostgreSQL" }
      tasks: { breakdown: "vertical-slice", testing: "test-after" }
  - name: notifications
    status: in-progress
    phase: design
    completedPhases: []
    implementationMode: null
    implementation: { totalTasks: 0, completedTasks: 0, currentTask: null, currentWave: null }
    artifacts:
      design: { status: draft, timestamp: "...", files: [design.md] }
    decisions:
      design: { api-style: "REST" }
  - name: payments
    status: not-started
    phase: null
    completedPhases: []
    implementationMode: null
    implementation: { totalTasks: 0, completedTasks: 0, currentTask: null, currentWave: null }
    artifacts: {}
    decisions: {}
```

Conventions:
- **Shared vs. per-unit**: `state.sharedPhases` tracks project-wide phases. Per-unit phases live in `units[].phase` and `units[].completedPhases`.
- **Parallel units**: Multiple units can be `in-progress` simultaneously — different sessions work on different units.
- **Comprehensive mode**: `units[]` stays empty. Design/tasks/implement tracked in `state.sharedPhases`.
- File paths in `files` are relative to `{SPECS_DIR}/{feature}/` (shared) or `{SPECS_DIR}/{feature}-{unit}/` (per-unit)
- Decision gate files (`decisions-{phase}.md`) are implicit — not tracked in artifacts
- Steering paths are implicit (`{STEERING_DIR}/{name}.md`) — only `updatedBy` is tracked
- `context-summary` stores key fields from context.md for downstream skills
- `decisions` stores compact summaries — shared decisions at top level, unit-scoped in `units[].decisions`

## Platform Compatibility

| Feature | Kiro | Claude Code | Cursor | Windsurf |
|---|---|---|---|---|
| All core phases | ✅ | ✅ | ✅ | ✅ |
| Parallel implementation | ✅ | ✅ | ❌ | ❌ |
| Autonomous implementation | ✅ | ✅ | ❌ | ❌ |
| Sub-agent dispatch | ✅ | ✅ | ❌ | ❌ |
| Steering file front-matter | ✅ | ❌ | ❌ | ❌ |
| CLAUDE.md generation | ❌ | ✅ | ❌ | ❌ |
| Mermaid diagram rendering | ✅ | ❌ | Varies | Varies |

## License

This project is licensed under the MIT-0 (MIT No Attribution) License. See [LICENSE.md](LICENSE.md) for details.

## Contributing

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting bugs, submitting pull requests, and our code of conduct.
