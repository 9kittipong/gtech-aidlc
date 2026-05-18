---
name: aidlc-tasks
description: Bridge design to implementation. Break design documents into concrete, sequenced, estimable tasks with execution waves for parallel dispatch. Generates decision gate, task hierarchy, and dependency-aware wave plan.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, tasks, implementation, planning, execution-waves, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Tasks Skill

You bridge architecture and implementation. Take design documents and break them into concrete, sequenced, estimable tasks that can be picked up and executed. Think about dependencies, parallelism, and risk. Size tasks so they're completable in 1-2 days and sequence them to avoid blocking.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-tasks v1.0.0 active — {platform} detected.
Ready to generate implementation tasks from design documents.
```

Then proceed to initialization.

---

## Quick Start

1. Generate D4 decision gate → user fills answers (or "use recommendations")
2. Validate D4 for conflicts → resolve if any
3. Generate sequenced tasks from design documents with execution waves and file ownership
4. Validate: all components covered, no circular deps, no file ownership overlaps
5. Present results → wait for approval → hand off to implement

**Reads**: context.md (Summary), design.md + design/\*, steering files
**Writes**: decisions-tasks.md, tasks.md

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-tasks`
2. `.claude/` → Claude Code. `SPECS_DIR=.claude/specs`, `STEERING_DIR=.claude/steering`, `SKILL_DIR=.claude/skills/aidlc-tasks`
3. `.cursor/` → Cursor. `SPECS_DIR=.cursor/specs`, etc.
4. `.windsurf/` → Windsurf. `SPECS_DIR=.windsurf/specs`, etc.

Common: `WORKFLOW_DIR=.aidlc/workflow`, `ASSETS_DIR={SKILL_DIR}/assets`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | What exists, stack, scope, feature description | Markdown (context.md), YAML, JSON, plain text, inline |
| Design documents | Components, data model, APIs, integrations, implementation plan | Markdown (design/*.md), YAML, JSON |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Units | Decomposition units if project was decomposed | Markdown, YAML, JSON |
| NFR specs | Non-functional requirements (performance, security, etc.) | Markdown, YAML, JSON |
| Existing task list | Pre-existing tasks to validate and enrich | Markdown, YAML, JSON, plain text |

If user provides existing tasks, validate coverage against design, add missing tasks, generate execution waves — **enrichment mode**.

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-tasks.md | `{WORKFLOW_DIR}/{feature}/decisions-tasks.md` |
| tasks.md | `{SPECS_DIR}/{feature}/tasks.md` |

### Incremental Mode

When operating on a specific unit:
- Read from: `{SPECS_DIR}/{feature}-{unit}/design/*`
- Write to: `{SPECS_DIR}/{feature}-{unit}/tasks.md`
- Decisions at: `{WORKFLOW_DIR}/{feature}-{unit}/decisions-tasks.md`

---

## Initialization

1. Detect environment
2. Resolve feature name:
   - Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` for existing manifests
   - If exactly one manifest → use its `feature` field
   - If multiple manifests → present list, ask user which feature to work on
   - If no manifests → infer from `{SPECS_DIR}/` folders (if exactly one, use it; if multiple, list and ask; if none, ask user)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve required inputs:
   - **Context**: manifest → user override → conventional path `{SPECS_DIR}/{feature}/context.md` → ask
   - **Design documents**: manifest → user override → conventional path `{SPECS_DIR}/{feature}/design/` → scan for `design*.md`, `components*.md`, `data-model*.md`, `api*.md`, `integration*.md`, `implementation*.md` → ask
5. Resolve optional inputs:
   - **Units**: manifest → `{SPECS_DIR}/{feature}/units.md` → skip silently
   - **NFR specs**: manifest → `{SPECS_DIR}/{feature}/nfr.md` → skip silently
   - **Existing tasks**: manifest → `{SPECS_DIR}/{feature}/tasks.md` → skip silently (if found, enter enrichment mode)
6. If steering files exist, read Summary sections from `{STEERING_DIR}/product.md`, `tech.md`

---

## Process

### Action: tasks-decisions

Generate the D4 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-tasks.md`.

Read `{ASSETS_DIR}/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- If user said "use recommendations" on a previous gate, that does NOT carry forward — each gate starts fresh
- Include context summary from design documents (component count, entity count, endpoint count, integration count)

**Generate questions covering**:
- Task breakdown strategy (vertical slice / layer-by-layer / feature-by-feature / component-first)
- Implementation approach (TDD / test-first / test-last / outside-in)
- Component priority (which components to build first)
- Integration strategy (mock-first / contract-first / real-services)
- Testing strategy (unit-only / unit+integration / full pyramid / E2E-first)
- Task granularity (fine-grained 2-4h / standard 1-2d / coarse 3-5d)
- Parallel work (sequential / parallel by layer / parallel by feature)
- Estimates (T-shirt sizes / story points / hours / none)

Present the decision file:

```
📍 Tasks: Decision Gate D4 (5 of 6 phases)

- **Decisions**: [X] questions covering strategy, approach, priorities, testing

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-tasks.md`, fill answers, say "done"
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

### Action: validate-d4

After D4 answers are filled, validate for conflicts.

**Validation Process**:
1. Parse all answers from the decisions file (read Decisions Summary section)
2. Load context from design documents and previous decisions (D3 tech choices)
3. Check each rule below against user answers
4. Collect conflicts, adjust severity by context
5. If conflicts found → present grouped by severity (🔴 High → 🟡 Medium → 🟢 Low), ask for resolution
6. If clean or all resolved → write decision summary to manifest `decisions.tasks` (compact key-value pairs from Decisions Summary section) → proceed to generation

**D4 Validation Rules**:

| Rule | Severity | Detection | Questions | Options |
|---|---|---|---|---|
| TDD Without Team Experience | 🟢 Low | Testing approach="TDD", context indicates team new to TDD | Does the team have TDD experience? Is there time for the learning curve? | 1. Start with test-after approach (easier learning curve) 2. Use TDD for critical components only 3. Keep TDD (team committed to learning) |
| No Testing Strategy | 🔴 High | Testing approach="None"/"Manual only", production deployment planned | How will you ensure code quality? Is this a prototype or production system? | 1. Add unit tests at minimum (Jest, Pytest, JUnit) 2. Add integration tests for critical paths 3. Keep no automated tests (prototype only, will add later) |
| Parallel Dev Without Coordination | 🟡 Medium | Breakdown="Parallel"/"By unit", multiple devs, no integration points | How will developers coordinate on shared interfaces? When will integration happen? | 1. Define integration milestones and sync points 2. Assign interface contracts upfront 3. Use sequential development (less coordination needed) |
| Outside-In Without E2E Framework | 🟡 Medium | Testing approach="Outside-in", D3 E2E framework="None"/unspecified | Which E2E framework will drive the outer tests? Can you start with integration tests instead? | 1. Select an E2E framework (Playwright, Cypress, Supertest) 2. Use integration tests as the "outer" layer instead 3. Keep outside-in without E2E (unit tests as outer layer) |
| No CI/CD With Production | 🟡 Medium | Deployment target includes production, CI/CD="None"/"Manual" | How will you ensure consistent deployments? Is manual deployment acceptable? | 1. Add basic CI/CD pipeline (GitHub Actions, GitLab CI) 2. Use manual deployment with documented runbook 3. Defer CI/CD to post-MVP |
| Task Count vs Timeline Mismatch | 🔴 High | Total tasks≥30, timeline<2 weeks/"Urgent", team size≤3 | Is this timeline realistic for the task count? Can tasks be reduced or deferred? | 1. Reduce scope — defer non-critical tasks to follow-up phase 2. Extend timeline to match task count 3. Increase parallelism (more developers, parallel mode) 4. Keep current plan (tasks are small, team is experienced) |
| Cloud Deploy Without Infra Tasks | 🔴 High | D3 includes cloud provider+IaC tool, no infra provisioning tasks | Who will set up the cloud infrastructure? Should infrastructure tasks be included? | 1. Add infrastructure tasks (IaC setup, environment provisioning, deployment pipeline) 2. Infrastructure is pre-existing — document as assumption 3. Defer infrastructure to a separate workstream |
| E2E Framework Without E2E Tasks | 🟡 Medium | D3 E2E framework≠"None", no E2E test setup/writing tasks | Should E2E tests be part of this implementation phase? Which user flows need E2E coverage? | 1. Add E2E test tasks for critical user flows 2. Defer E2E tests to a QA phase after implementation 3. Remove E2E framework choice (not needed yet) |
| API Docs Without Doc Tasks | 🟢 Low | D3 API docs="OpenAPI/Swagger"/similar, no doc generation tasks | Should API documentation be generated as part of implementation? Is documentation auto-generated from code or manually maintained? | 1. Add API doc tasks (schema generation, Swagger UI setup, doc hosting) 2. Auto-generate from code annotations (add annotations to implementation tasks) 3. Defer documentation to post-implementation |
| DB Migrations Without Migration Tasks | 🟡 Medium | D3 includes DB+ORM with migration support, no schema/migration tasks | Should database schema setup be an explicit task? Is seed data needed for development/testing? | 1. Add migration tasks (schema creation, seed data, migration scripts) 2. Include migration as sub-task of the data layer setup task 3. Schema is pre-existing — document as assumption |
| CI/CD Without Pipeline Tasks | 🟡 Medium | D3 CI/CD tool≠"None", no pipeline config/test/deploy tasks | Should CI/CD pipeline setup be part of this implementation? What stages are needed (lint, test, build, deploy)? | 1. Add CI/CD tasks (pipeline config, test stage, build stage, deploy stage) 2. Include as sub-task of the project setup phase 3. Defer CI/CD to post-implementation |

**Context-Based Severity Adjustments**:
- Team Size: Small (1-3) → complexity conflicts HIGH; Large (9+) → LOW
- Scope: MVP → over-engineering HIGH; Enterprise → under-engineering HIGH
- Timeline: Urgent (<3mo) → complexity HIGH; Long-term (>6mo) → LOW

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

### Action: tasks-generation

Derive tasks from design documents:
- **Components** → implementation tasks
- **Entities** → schema/migration tasks
- **Endpoints** → API route tasks
- **Integrations** → integration tasks
- **NFRs** → infrastructure/performance tasks
- **Correctness properties** → PBT (property-based testing) tasks

Read decisions from manifest `decisions.tasks` section. Fall back to reading `## Decisions Summary` from the decisions file if manifest section is missing.

Read `{ASSETS_DIR}/tasks.md` for the output structure.

Use **Kiro-compatible checkbox format**:
- Phase = top-level checkbox: `- [ ] 1. Phase Name`
- Task = nested checkbox: `  - [ ] 1.1 Task Title`
- Details = plain list items (no checkbox)

Generate `{SPECS_DIR}/{feature}/tasks.md` (or `{SPECS_DIR}/{feature}-{unit}/tasks.md` in incremental mode).

#### Execution Waves (MANDATORY)

Generate the `## Execution Waves` section. Group top-level phases (not individual tasks) into waves based on inter-phase dependencies:

1. Build a dependency graph at the phase level — Phase B depends on Phase A if any task in B depends on any task in A
2. Phases with no unresolved phase dependencies form the next wave
3. Tasks within each phase are executed sequentially by a single sub-agent — no need to parallelize within a phase
4. For each parallel wave (2+ phases), assign file ownership per phase — which directories/files each phase owns
5. File ownership must not overlap between phases in the same wave
6. If two phases must touch the same directory, they cannot be in the same wave — move one to the next wave

#### Validate Output

- ✅ All design components have tasks
- ✅ All user stories covered
- ✅ Dependencies correct (no circular, no missing)
- ✅ Kiro checkbox format correct (Phase = top-level, Task = nested, Details = plain list)
- ✅ Execution Waves section present with phase-level grouping and file ownership for parallel waves
- ✅ No file ownership overlap between phases in the same wave (see below)

#### File Ownership Overlap Validation

For each parallel wave (2+ phases), verify that no two phases own overlapping paths:

1. Collect all ownership paths for each phase in the wave
2. For each pair of phases, check if any path is a prefix of or equal to another:
   - `src/auth/` and `src/auth/middleware.ts` → 🔴 overlap (directory contains file)
   - `src/auth/` and `src/users/` → ✅ no overlap
   - `src/models/` and `src/models/` → 🔴 overlap (identical)
3. If overlap detected:
   - Move one of the conflicting phases to the next wave
   - Re-generate the wave assignment
   - Report: "Moved Phase {X} to Wave {N+1} due to file ownership conflict with Phase {Y} on `{path}`"

#### Update Manifest

Update artifacts in manifest:
- **Incremental mode**: Add `units[{unit}].artifacts.tasks` entry: `status: "draft"`, `timestamp`, `files: [tasks.md]`. Update `units[{unit}].implementation.totalTasks` with task count. Write tasks decisions to `units[{unit}].decisions.tasks`.
- **Comprehensive mode**: Add top-level `artifacts.tasks` entry: `status: "draft"`, `timestamp`, `files: [tasks.md]`. Write tasks decisions to top-level `decisions.tasks`.
- Do NOT update phase state yet — wait for user approval

#### Present Results

```
📍 Tasks (5 of 6 phases)

[Summary]

- **Total Tasks**: [X] across [Y] phases
- **Execution Waves**: [Z] waves ([W] parallel)
- **Coverage**: [A] components, [B] entities, [C] endpoints, [D] integrations
- **Strategy**: [from D4]

Artifact at `{SPECS_DIR}/{feature}/tasks.md`.

---
🔲 **Your turn**:
- ✅ "approve" — finalize tasks
- ✏️ "change [what]" — request edits
```

**STOP and wait for approval.**

On approval: update manifest — **incremental mode**: set `units[{unit}].artifacts.tasks.status` to `"approved"`, set `units[{unit}].phase` to `"tasks"`, add `"tasks"` to `units[{unit}].completedPhases`. **Comprehensive mode**: set `artifacts.tasks.status` to `"approved"`, add `"tasks"` to `state.sharedPhases`. Append audit entry. If platform is Claude Code, update `CLAUDE.md` (set Phase to "tasks"). Then auto-continue (see Skill Handoff below).

### Action: tasks-edit

1. Read current tasks.md
2. Apply requested changes (reorder tasks, add/remove tasks, change estimates, update dependencies, modify sub-tasks)
3. Regenerate the `## Execution Waves` section if dependencies changed (re-run wave grouping and file ownership assignment)
4. Re-validate:
   - ✅ All design components still have tasks
   - ✅ All user stories still covered
   - ✅ Dependencies still correct (no circular, no missing)
   - ✅ Kiro checkbox format preserved (Phase = top-level, Task = nested, Details = plain list)
5. Present changes with updated metrics
6. Include the `🔲 **Your turn**` prompt block
7. **STOP** — wait for approval

---

## References

For task breakdown strategies, read `{SKILL_DIR}/references/task-strategies.md` when generating tasks.
For CI/CD, deployment, and operations guidance, read `{SKILL_DIR}/references/operations.md` when generating infrastructure or deployment tasks.

---

## Skill Handoff

When the user approves tasks, auto-continue to the next skill:

1. Resolve: `{PLATFORM_DIR}/skills/aidlc-implement/SKILL.md`
2. Read that file
3. Follow its instructions — begin the implementation phase (mode selection) in the same conversation

**Next skill mapping**:
- Tasks approved → `aidlc-implement`

If the next skill's SKILL.md cannot be found, fall back to:
```
👉 Next: Activate the **aidlc-implement** skill to start building.
```

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, audit, templates, validation, platform detection).
- Tools — Kiro: `fsWrite`, `readMultipleFiles`, `invokeSubAgent`. Claude Code: `Write`/`Edit`, parallel `Read`, `Agent`. Cursor/Windsurf: `Write`/`Edit`, sequential reads, no sub-agents.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.
- Errors: report clearly with what happened and what to do. Offer rebuild/retry. Never lose work silently.

### Audit Trail
Append to `{WORKFLOW_DIR}/{feature}/audit.md` after: decision gate, validation, generation, approval, edit.

Use the standard audit entry format:

```
### [{ISO timestamp}] {Phase}: {Action}

**Phase**: tasks
**Action**: {decision-gate | validation | generation | approval | edit}
**Artifacts**: {files created or modified}
**Outcome**: {result summary — e.g., "24 tasks across 6 phases, 4 execution waves (2 parallel), vertical slice strategy"}
```
