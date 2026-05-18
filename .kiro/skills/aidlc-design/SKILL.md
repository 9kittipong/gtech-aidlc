---
name: aidlc-design
description: Technology decisions and architecture design. Generates D3 decision gate, validates choices, produces modular or compact design documents with components, data model, API spec, integration, implementation, correctness, and NFR specifications.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, design, architecture, technology-decisions, components, data-model, api, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Design Skill

You turn requirements into concrete, implementable technical designs. Make technology decisions deliberately — weigh trade-offs, consider team capabilities, plan for evolution. Design components, data models, APIs, and integration patterns that are implementable, testable, and maintainable.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-design v1.0.0 active — {platform} detected.
Ready to generate technology decisions and architecture design.
```

---

## Quick Start

1. Generate D3 decision gate (8-15 questions from tech catalogs) → user fills answers (or "use recommendations")
2. Validate D3 for conflicts → resolve if any
3. Generate design documents (compact for ≤10 stories, modular for 11+): components, data model, API spec, integration, implementation plan
4. Update steering/tech.md and steering/structure.md
5. Present results → wait for approval → hand off to tasks

**Reads**: context.md (Summary), requirements.md, units.md (if exists), foundation.md (if exists), steering files, resources.md
**Writes**: decisions-design.md, design.md, design/\*, steering/tech.md, steering/structure.md

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-design`
2. `.claude/` → Claude Code. `SPECS_DIR=.claude/specs`, etc.
3. `.cursor/` → Cursor. `SPECS_DIR=.cursor/specs`, etc.
4. `.windsurf/` → Windsurf. `SPECS_DIR=.windsurf/specs`, etc.

Common: `WORKFLOW_DIR=.aidlc/workflow`, `ASSETS_DIR={SKILL_DIR}/assets`, `REFERENCES_DIR={SKILL_DIR}/references`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | What exists, stack, scope, feature description | Markdown (context.md), YAML, JSON, plain text, inline |
| User stories with acceptance criteria | Requirements to design for | Markdown (requirements.md), YAML, JSON, CSV, plain text |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Units/boundaries | Decomposition units if complex project | Markdown (units.md) |
| Foundation conventions | Cross-unit patterns and conventions | Markdown (foundation.md) |
| Existing API specs | Pre-existing API definitions | OpenAPI (YAML/JSON), GraphQL schema (.graphql/.gql) |
| Existing data models | Pre-existing data schemas | Prisma (.prisma), SQL DDL (.sql), JSON Schema (.json) |
| Design system/component inventory | UI component library or design tokens | Via MCP, URLs, file paths |

### Special Input Handling
- If user provides **OpenAPI spec** → use as basis for `design/api-spec.md` instead of designing from scratch
- If user provides **GraphQL schema** → use as basis for `design/api-spec.md`
- If user provides **Prisma/SQL DDL** → use as basis for `design/data-model.md`

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-design.md | `{WORKFLOW_DIR}/{feature}/decisions-design.md` |
| design.md | `{SPECS_DIR}/{feature}/design.md` |
| design/components.md | `{SPECS_DIR}/{feature}/design/components.md` |
| design/data-model.md | `{SPECS_DIR}/{feature}/design/data-model.md` |
| design/api-spec.md | `{SPECS_DIR}/{feature}/design/api-spec.md` |
| design/integration.md | `{SPECS_DIR}/{feature}/design/integration.md` |
| design/implementation.md | `{SPECS_DIR}/{feature}/design/implementation.md` |
| design/correctness.md | `{SPECS_DIR}/{feature}/design/correctness.md` (conditional) |
| design/nfr.md | `{SPECS_DIR}/{feature}/design/nfr.md` (conditional) |
| tech.md (update) | `{STEERING_DIR}/tech.md` |
| structure.md (update) | `{STEERING_DIR}/structure.md` |

---

## Initialization

1. Detect environment
2. Resolve feature name:
   - Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` for existing manifests
   - If exactly one manifest → use its `feature` field
   - If multiple manifests → present list, ask user which feature to work on
   - If no manifests → infer from `{SPECS_DIR}/` folders (if exactly one, use it; if multiple, list and ask; if none, ask user)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve inputs:
   - Project context (manifest → user override → conventional path `{SPECS_DIR}/{feature}/context.md` → ask)
   - Requirements (manifest → user override → conventional path `{SPECS_DIR}/{feature}/requirements.md` → ask)
   - Units (manifest → conventional path `{SPECS_DIR}/{feature}/units.md` → skip)
   - Foundation (manifest → conventional path `{SPECS_DIR}/{feature}/foundation.md` → skip)
5. If steering files exist, read Summary sections from `{STEERING_DIR}/product.md`, `tech.md`, `structure.md`. Read `resources.md` in full.
6. **Incremental mode**: If running for a unit, scope to that unit's stories from units.md. Create unit output folders: `{SPECS_DIR}/{feature}-{unit}/`, `{SPECS_DIR}/{feature}-{unit}/design/`, `{WORKFLOW_DIR}/{feature}-{unit}/`. Write outputs to `{SPECS_DIR}/{feature}-{unit}/` instead of `{SPECS_DIR}/{feature}/`. When executing, always scope: "You are designing unit `{unit}`. Consider ONLY stories assigned to this unit in units.md. Reference parent artifacts at `{SPECS_DIR}/{feature}/` for context, requirements, foundation."

---

## Process

### Action: design-decisions

Generate the D3 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-design.md`.

Analyze the **FULL SYSTEM** before generating questions — read requirements, units (if exists), context, foundation (if exists).

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- If user said "use recommendations" on a previous gate, that does NOT carry forward — each gate starts fresh
- Pre-fill from `foundation.md` if exists (repo strategy, API architecture, auth approach, error format, inter-unit comms, DB strategy, shared types). Skip questions that foundation already answers — those decisions are settled.

Read `{REFERENCES_DIR}/technology-questions-catalog.md` for the sub-catalog index, then load ONLY the relevant sub-catalogs based on context:

| Sub-Catalog | Load When |
|---|---|
| `{REFERENCES_DIR}/tech-catalog-backend.md` | **ALWAYS** (most projects have backend) |
| `{REFERENCES_DIR}/tech-catalog-frontend.md` | System has web UI |
| `{REFERENCES_DIR}/tech-catalog-mobile.md` | System has mobile app |
| `{REFERENCES_DIR}/tech-catalog-infra.md` | Cloud-deployed |
| `{REFERENCES_DIR}/tech-catalog-distributed.md` | Architecture = microservices or distributed |
| `{REFERENCES_DIR}/tech-catalog-nfr.md` | Production deployment or performance targets |

Select 8–15 questions total based on project complexity.

**MANDATORY**: Include the Correctness & Property-Based Testing question.

Read `{ASSETS_DIR}/decision-gate.md` for the output structure.

Present the decision file:

```
📍 Design: Decision Gate D3 (4 of 6 phases)

- **Decisions**: [X] questions covering stack, data, auth, testing, infrastructure

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-design.md`, fill answers, say "done"
🤖 Or say "use recommendations" to auto-fill with recommended options

---
🔲 **Your turn**:
- ✏️ Fill answers in the file and say "done"
- 🤖 "use recommendations" — auto-fill recommended options for THIS gate
```

**STOP and wait.**

When user says "done" or "use recommendations":
- If "use recommendations": fill all answers with the recommended option, update the Decisions Summary section
- Proceed to validation

### Action: validate-d3

After D3 answers are filled, validate for conflicts.

**Validation Process**:
1. Parse all answers from the decisions file (read Decisions Summary section)
2. Load context from context.md (team size, scope, timeline)
3. Check ONLY the relevant rule sets below based on D3 answer categories
4. Collect conflicts, adjust severity by context
5. If conflicts found → present grouped by severity (🔴 High → 🟡 Medium → 🟢 Low), ask for resolution
6. If clean or all resolved → write decision summary to manifest `decisions.design` (compact key-value pairs from Decisions Summary section) → proceed to generation

**Load validation rules from `{REFERENCES_DIR}/validation-rules-d3.md`** — read only the relevant sections based on D3 answer categories:
- **Technology Compatibility** → if D3 includes technology stack choices
- **Architecture & Performance** → if D3 includes architecture patterns or performance targets
- **Security** → if D3 includes security choices, PII/compliance, or frontend+backend combinations
- **Workflow & Cost** → if D3 includes repo strategy, CI/CD, observability, or cost-sensitive infrastructure

**Context-Based Severity Adjustments** (from workflow rules file):
- **Team Size**: Small (1–3) → complexity conflicts severity UP; Large (9+) → DOWN
- **Scope**: MVP → over-engineering severity UP; Enterprise → under-engineering severity UP
- **Timeline**: Urgent (<3mo) → complexity severity UP; Long-term (>6mo) → DOWN

**Conflict presentation**:
```
⚠️ Decision Validation — Conflicts Detected

## 🔴 Conflict 1: [Name] (High)
**Issue**: [Description]
**Your choices**: [Decision A]: [answer], [Decision B]: [answer]
**Options**: 1. [option] 2. [option] 3. Keep current (requires justification)
**Question**: How would you like to resolve this?
```

After resolution, append validation notes to the decisions file and proceed.

User can say "skip validation and proceed" → log in audit, add warning, proceed.

### Action: design-generation

#### Choose Format

- **Simple** (≤10 stories, single domain) → compact `design.md` using `{ASSETS_DIR}/design-compact.md`
- **Complex** (11+ stories or multiple domains) → modular `design.md` + `design/` folder

#### External Resources (Conditional)

If `{STEERING_DIR}/resources.md` exists and lists available resources (not "none"):
- **Design tool**: Use design tool MCP (if available) to read component inventory, design tokens → incorporate into design/components.md
- **API specs**: Read OpenAPI/GraphQL schemas → use as basis for design/api-spec.md instead of designing from scratch
- **Design system docs**: Read referenced docs → align component naming and patterns
- **Reference implementations**: Read referenced repos → align architecture patterns
- Cite external sources in design documents

#### Writing Strategy

1. Read all needed templates + input artifacts in one `readMultipleFiles` call
2. Write independent design detail files in parallel (same turn):
   - `design/components.md`, `design/data-model.md`, `design/api-spec.md` simultaneously
   - `design/integration.md`, `design/implementation.md` simultaneously
   - `design/nfr.md` (if applicable), `design/correctness.md` (if applicable)
3. Write `design.md` last (it references the detail files — keep it slim: Summary + Architecture + References only)

#### No-Assumptions Rule

**CRITICAL**: ONLY use choices from D3. Read decisions from manifest `decisions.design` section. Fall back to reading `## Decisions Summary` from the decisions file if manifest section is missing. Do not parse the full question/answer blocks. Use `[TBD - not decided in D3]` for any missing decisions. Never assume technology choices that weren't explicitly decided.

#### Load Guides Conditionally

Load ONLY the guides that apply from `{REFERENCES_DIR}/`. Do NOT read guides that don't match.

| Guide | Load When |
|---|---|
| `architecture-patterns.md` | **ALWAYS** |
| `api-design.md` | D3 includes API design choices (REST/GraphQL/gRPC) |
| `frontend-architecture.md` | D3 includes frontend framework choice |
| `mobile-architecture.md` | D3 includes mobile platform choice |
| `distributed-patterns.md` | Architecture = microservices or distributed system |
| `property-based-testing.md` | D3 PBT answer = Yes |

**SKIP all non-matching guides.** For a simple backend API project, load only `architecture-patterns.md` and `api-design.md` (~8KB instead of ~25KB).

#### Templates

- Simple: `{ASSETS_DIR}/design-compact.md` ONLY
- Complex: `{ASSETS_DIR}/design.md` + modular templates:
  - `{ASSETS_DIR}/design-components.md`
  - `{ASSETS_DIR}/design-data-model.md`
  - `{ASSETS_DIR}/design-api-spec.md`
  - `{ASSETS_DIR}/design-integration.md`
  - `{ASSETS_DIR}/design-implementation.md`
  - `{ASSETS_DIR}/design-correctness.md` — ONLY if PBT selected
  - `{ASSETS_DIR}/nfr.md` — ONLY if NFR questions answered

#### Validate

- ✅ All components, entities, endpoints, integrations designed
- ✅ All D3 choices used, no assumptions beyond D3
- ✅ Design files reference each other correctly
- ✅ Cross-references between design files are correct

#### Update Steering

After generating design documents, update steering files with D3 decisions:

**`{STEERING_DIR}/tech.md`**: Replace "Pending D3 decisions" placeholders with actual choices:
- Stack (languages, frameworks, build system, testing, infrastructure)
- Architecture pattern and API style
- Infrastructure (cloud, compute, database, IaC)
- Conventions (code style, naming, testing pattern)

**`{STEERING_DIR}/structure.md`**: Replace "will be defined during design phase" placeholders with actual structure from `design/implementation.md`:
- Key Directories table from the directory structure
- Key Files table from project configuration
- Entry Points from the design

Read current steering files first, preserve existing content, update only the placeholder sections.

#### Update Manifest

Update artifacts in manifest:
- **Incremental mode**: Add `units[{unit}].artifacts.design` entry: `status: "draft"`, `timestamp`, `files` listing all generated design files. Write design decisions to `units[{unit}].decisions.design`.
- **Comprehensive mode**: Add top-level `artifacts.design` entry: `status: "draft"`, `timestamp`, `files`. Write design decisions to top-level `decisions.design`.
- Update `steering.updatedBy.tech` to include `design`
- Update `steering.updatedBy.structure` to include `design`
- Do NOT update phase state yet — wait for user approval

#### Present Results

```
📍 Design (4 of 6 phases)

[Summary]

- **Architecture**: [Style]
- **Stack**: [Frontend] / [Backend] / [Database] / [Infra]
- **Components**: [X] designed
- **Entities**: [Y] modeled
- **Endpoints**: [Z] specified
- **Integrations**: [W] defined
- **PBT Properties**: [N] (or "Skipped")
- **NFR**: [Included / Skipped]

Artifacts at `{SPECS_DIR}/{feature}/design.md` (+ `design/` folder if complex).

---
🔲 **Your turn**:
- ✅ "proceed" — move to next phase
- ✏️ "change [what]" — request edits
```

**STOP and wait for approval.**

On approval: update manifest — **incremental mode**: set `units[{unit}].artifacts.design.status` to `"approved"`, set `units[{unit}].phase` to `"design"`, add `"design"` to `units[{unit}].completedPhases`. **Comprehensive mode**: set `artifacts.design.status` to `"approved"`, add `"design"` to `state.sharedPhases`. Append audit entry. If platform is Claude Code, update `CLAUDE.md` (set Phase to "design"). Then auto-continue (see Skill Handoff below).

### Action: design-edit

1. Read current `design.md` and relevant `design/*` files
2. Apply requested changes (modify components, update data model, change API endpoints, adjust integrations, etc.)
3. Maintain the No-Assumptions Rule — don't introduce choices not in D3
4. If change cascades (e.g., renaming an entity affects data-model, api-spec, and components), update ALL affected design files
5. Re-validate:
   - ✅ Cross-references between design files still correct
   - ✅ All D3 choices still reflected
   - ✅ No orphaned components or endpoints
   - ✅ No assumptions beyond D3 introduced
6. Mark downstream artifacts as `outdated` in manifest (tasks — if exists)
7. Present changes: files modified, summary, updated metrics
8. Include the `🔲 **Your turn**` prompt block and **STOP** — do not proceed until user approves

---

## Skill Handoff

When the user approves the design, auto-continue to the next skill:

1. Resolve: `{PLATFORM_DIR}/skills/aidlc-tasks/SKILL.md`
2. Read that file
3. Follow its instructions — begin the tasks phase in the same conversation

**Next skill mapping**:
- Design approved → `aidlc-tasks`

If the next skill's SKILL.md cannot be found, fall back to:
```
👉 Next: Activate the **aidlc-tasks** skill to break the design into implementation tasks.
```

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, audit, templates, validation, platform detection, guide loading).
- Tools — Kiro: `fsWrite`, `readMultipleFiles`, `invokeSubAgent`. Claude Code: `Write`/`Edit`, parallel `Read`, `Agent`. Cursor/Windsurf: `Write`/`Edit`, sequential reads, no sub-agents.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.
- Errors: report clearly with what happened and what to do. Offer rebuild/retry. Never lose work silently.

### Audit Trail
Append to `{WORKFLOW_DIR}/{feature}/audit.md` after: decision gate, validation, generation, approval, edit.

Use the standard audit entry format:

```
### [{ISO timestamp}] {Phase}: {Action}

**Phase**: design
**Action**: {decision-gate | validation | generation | approval | edit}
**Artifacts**: {files created or modified}
**Outcome**: {result summary — e.g., "6 components, 4 entities, 12 endpoints, compact format, PBT included"}
```
