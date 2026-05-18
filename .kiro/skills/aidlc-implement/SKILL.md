---
name: aidlc-implement
description: Code generation and testing. Execute implementation tasks from design specs using standard, parallel, or autonomous modes. Produces production-ready source code and tests.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, implementation, code-generation, testing, parallel, autonomous, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Implementation Skill

You write clean, tested, production-ready code. Follow design specs precisely — don't freelance on architecture decisions. Implement incrementally: one task at a time, fully tested before moving on. Track requirements coverage and report honestly. Write the code that's needed, not the code that's clever.

When active:
1. Follow ONLY the process below
2. WAIT for user approval at each checkpoint
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-implement v1.0.0 active — {platform} detected.
Ready to implement tasks from design specifications.
```

Then proceed to initialization.

---

## Quick Start

1. Choose implementation mode: standard (one task at a time) / parallel (wave-based sub-agents) / autonomous (all waves, no stops)
2. Execute tasks following design specs and D4 testing approach
3. Run tests after each task/wave → mark complete in tasks.md
4. On completion → present summary with test results and coverage

**Reads**: tasks.md, design.md + design/\*, steering files, resources.md
**Writes**: Source code, test files, tasks.md (checkbox updates)

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-implement`
2. `.claude/` → Claude Code. `SPECS_DIR=.claude/specs`, `STEERING_DIR=.claude/steering`, `SKILL_DIR=.claude/skills/aidlc-implement`
3. `.cursor/` → Cursor. `SPECS_DIR=.cursor/specs`, etc.
4. `.windsurf/` → Windsurf. `SPECS_DIR=.windsurf/specs`, etc.

Common: `WORKFLOW_DIR=.aidlc/workflow`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Task list with dependencies | Sequenced implementation tasks with execution waves | Markdown (tasks.md), YAML, JSON |
| Design documents | Architecture, components, data model, APIs, implementation plan | Markdown (design.md + design/*), OpenAPI, GraphQL, Prisma |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| External resources | Design tool specs, API docs, library docs | Via MCP, URLs, file paths |

### Outputs
| Artifact | Description |
|---|---|
| Source code files | Production code per design/implementation.md |
| Test files | Unit, integration, E2E, PBT tests per D4 testing approach |
| tasks.md (update) | Task checkboxes marked complete as tasks are implemented |

### Incremental Mode

When operating on a specific unit:
- Read from: `{SPECS_DIR}/{feature}-{unit}/tasks.md`, `{SPECS_DIR}/{feature}-{unit}/design/*`
- Update: `{SPECS_DIR}/{feature}-{unit}/tasks.md` (checkboxes)
- Audit at: `{WORKFLOW_DIR}/{feature}-{unit}/audit.md` (full entry) + `{WORKFLOW_DIR}/{feature}/audit.md` (summary)

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
   - **Tasks**: manifest → user override → conventional path `{SPECS_DIR}/{feature}/tasks.md` → ask
   - **Design documents**: manifest → user override → conventional path `{SPECS_DIR}/{feature}/design.md` + `{SPECS_DIR}/{feature}/design/` → scan for `implementation.md`, `data-model.md`, `api-spec.md`, `components.md`, `integration.md` → ask
5. Resolve optional inputs:
   - **External resources**: read `{STEERING_DIR}/resources.md` if it exists → skip silently if not found
6. If steering files exist, read Summary sections from `{STEERING_DIR}/product.md`, `tech.md`
7. **Incremental mode**: if manifest indicates a unit in progress, read from unit-scoped paths (`{SPECS_DIR}/{feature}-{unit}/tasks.md`, `{SPECS_DIR}/{feature}-{unit}/design/*`)

---

## Process

### Action: select-mode

After tasks are approved, present the implementation mode choice.

#### Step 1: Analyze Project

Read `{SPECS_DIR}/{feature}/tasks.md` (or `{SPECS_DIR}/{feature}-{unit}/tasks.md` in incremental mode):
- Count total tasks (nested checkboxes `- [ ]` under phases)
- Count top-level phases (top-level checkboxes)
- Count execution waves from `## Execution Waves` section
- Check platform from manifest (parallel/autonomous not available on Cursor/Windsurf)

#### Step 2: Present Mode Choice

```
📍 Tasks Complete — Choose Implementation Mode

Your project has [X tasks] across [Y phases] in [Z execution waves].

Available modes:
- 🔹 **standard** — tasks one at a time, review and test after each. Best for learning the codebase or when you want tight control.
- 🔹 **parallel** — tasks in dependency waves via sub-agents, review per wave. Faster but harder to debug if something breaks.
- 🔹 **autonomous** — all tasks without stopping, single review at the end. Best when you trust the spec fully.

[If Cursor/Windsurf: "⚠️ Parallel and autonomous modes are not available on {platform}. Standard mode recommended."]

---
🔲 **Your turn**:
- 🔹 "standard" — tasks one at a time with review after each
- 🔹 "parallel" — tasks in dependency waves via sub-agents
- 🔹 "autonomous" — all tasks without stopping
```

**STOP and wait for user response.** Do not auto-select a mode.

#### Step 3: Handle Response

Update `aidlc-manifest.yaml`:
- Set `state.implementationMode` to the chosen mode
- Set `implementation.totalTasks` to the count from tasks.md
- Standard mode: set `implementation.currentTask` to first task ID, set `nextAction` to `implementing-task-{first}`
- Parallel/Autonomous mode: set `implementation.currentWave` to `1`, set `nextAction` to `implementing-wave-1`

Then begin implementation using the chosen mode:
- **Standard**: Continue with the standard mode process below
- **Parallel**: Read `{SKILL_DIR}/references/parallel-mode.md` and follow its instructions
- **Autonomous**: Read `{SKILL_DIR}/references/autonomous-mode.md` and follow its instructions

---

### Action: implement (Standard Mode)

Execute tasks one at a time in the order they appear in tasks.md (phase by phase, task by task). Ignore the Execution Waves section.

For each task:

**1. Read task details and design specs**

Read the task entry from tasks.md. Read related design documents referenced by the task (Ref fields). If `{STEERING_DIR}/resources.md` lists available resources, use them:
- **Design tool**: Use MCP to read exact specs — spacing, colors, typography, component details → implement UI precisely
- **API specs**: Read OpenAPI/GraphQL schemas → generate types, route stubs, validation from spec
- **Documentation**: Use web search (if available) to look up library APIs, framework patterns, or troubleshoot errors
- Only access external resources when the current task needs them — don't fetch everything upfront

**2. First task (project setup)**

If this is the first task (typically project scaffold/setup):
- Initialize project structure from `design/implementation.md`
- Create directory layout, install dependencies, configure build tools
- Generate type stubs from `design/data-model.md`
- Generate API route stubs from `design/api-spec.md`
- Generate component stubs from `design/components.md`
- Generate test scaffold if D4 chose test-first/TDD

**3. Implement following D4 testing approach**

Read the testing approach from the D4 decisions (stored in `{WORKFLOW_DIR}/{feature}/decisions-tasks.md` Decisions Summary):

- **TDD**: Write failing tests first → implement code to make them pass → refactor
- **Test-after**: Implement the feature → write tests → verify all pass
- **Outside-in**: Write high-level acceptance test → implement from outer layer inward → fill in details

For all approaches: follow design specs precisely. If the design says use Express, use Express. If the design specifies a particular pattern, use that pattern.

**4. Run tests and verify**

Run the test suite. Only mark the task complete when all tests pass. If tests fail:
- Read the error output
- Fix the implementation (not the test, unless the test has a bug)
- Re-run until passing

**5. Mark task complete (environment-aware)**

- **Kiro**: Use `taskStatus` tool to mark the task complete
- **Claude Code**: Use `TaskUpdate` tool OR `Edit` tool to change `- [ ]` → `- [x]` on the task checkbox
- **Cursor/Windsurf**: Use `Edit` tool to change `- [ ]` → `- [x]` on the task checkbox (top-level phase and nested task checkboxes only, not detail items)

**6. Update manifest**

Update `aidlc-manifest.yaml`:
- **Incremental mode**: Set `units[{unit}].implementation.currentTask` to the just-completed task ID. Increment `units[{unit}].implementation.completedTasks`.
- **Comprehensive mode**: Update top-level implementation counters in a similar fashion (store in `artifacts.tasks` metadata or a top-level `implementation` section if needed).

For incremental mode: update both the unit's manifest state and the main manifest's `units[]` entry.

**7. Present per-task results**

```
📍 Implementation: Task {X.Y} complete ({Z}% overall)

- **Files changed**: [count]
- **Tests**: [new] new, [total] total, all passing: [yes/no]
- **What's testable now**: [endpoints, features, or components that are functional]
- **Next**: Task {next ID} — {next title}

---
🔲 **Your turn**:
- ✅ "next" — proceed to next task
- ✏️ "change [what]" — request changes to this task
- ⏸️ "pause" — stop here, resume later
```

**STOP and wait for approval**, then proceed to next task.

**8. Append audit entry**

After each task, append to `{WORKFLOW_DIR}/{feature}/audit.md`:

```
### [{ISO timestamp}] Task Complete: {Task ID} — {Task Title}

**Phase**: implementation
**Action**: task {Task ID} implemented (standard mode)
**Artifacts**: {list of files created/modified}
**Outcome**: {pass/fail}, {test count} tests, {Z}% overall progress
```

For incremental mode: write full entry to `{WORKFLOW_DIR}/{feature}-{unit}/audit.md` and a one-line summary to `{WORKFLOW_DIR}/{feature}/audit.md`.

---

### Action: resolve-conflict

For merge conflicts during parallel or incremental implementation.

#### Resolution Strategies

| Strategy | When to Use | Description |
|---|---|---|
| **Merge Both** | Changes are complementary | Combine functionality from both sides, maintain consistency |
| **Choose One** | Mutually exclusive changes | Evaluate alignment with architecture and design, consider file ownership |
| **Refactor** | Conflict indicates design issue | Extract shared functionality, propose interface changes |
| **Escalate** | Architectural misalignment | Flag for review — reveals a gap in the design |

#### Resolution Process

1. **Understand**: Read conflicting files, identify conflict markers, determine which phases/units are involved, understand the intent of each change
2. **Gather Context**: Read design docs for involved phases/units, check related files, review requirements and integration specs
3. **Analyze Impact**: Identify downstream dependencies, assess impact on other phases/units, check for similar conflicts elsewhere
4. **Propose Resolution**: Explain the conflict, present options with pros/cons, recommend an approach, show the resolved code
5. **Verify**: Ensure code compiles and runs, check that both phases' requirements are met, verify no new conflicts introduced, run relevant tests

#### Common Scenarios

| Scenario | Resolution |
|---|---|
| Overlapping routes | Merge all routes, organize by phase/unit, ensure no path conflicts |
| Conflicting config | Merge configs, use namespacing, validate combined config |
| Duplicate utilities | Extract to shared module, consolidate implementations |
| Incompatible data models | Merge fields, ensure compatibility, update migrations |
| Conflicting dependencies | Align on compatible version, test both phases/units |
| Integration conflicts | Ensure contract compatibility, merge implementations |

#### When to Escalate

Escalate (present to user for decision) when:
- Fundamental architectural misalignment between phases
- Conflicting design interpretations that can't be resolved from specs
- Resolution would require changes to the design documents
- Missing integration specifications
- Same conflict pattern appearing across multiple files

#### Conflict Output Format

```
⚠️ Conflict Detected

**Files**: [list of conflicting files]
**Phases/Units**: [which phases or units are involved]
**Type**: [overlapping routes / conflicting config / duplicate utilities / etc.]

**Root Cause**: [why the conflict occurred]

**Strategy**: [Merge Both / Choose One / Refactor / Escalate]
**Resolution**: [description of what was done]

**Verification**: [tests run, results]
```

---

### Finalize (All Modes)

After all tasks/waves complete (regardless of mode):

**1. Run full test suite**

Execute the complete test suite one final time. Report results.

**2. Present final summary**

```
📍 Implementation Complete

- **Total tasks**: [X] completed [/ Y failed / Z skipped — autonomous only]
- **Total files**: [count] created/modified
- **Tests**: [total] total, [passing] passing
- **Test coverage**: [percentage if available]
- **Requirements coverage**: [X of Y user stories implemented]

---
🔲 **Your turn**:
- ✅ "done" — finalize implementation
- 🔍 "review" — inspect specific areas
- 🔧 "fix [issue]" — address remaining issues
```

**STOP and wait.**

**3. Update manifest**

On user approval:
- **Incremental mode**: Set `units[{unit}].phase` to `"completed"`, add `"implement"` to `units[{unit}].completedPhases`, set `units[{unit}].status` to `"completed"`, clear `units[{unit}].implementation.currentTask` and `currentWave`. If ALL units are now `"completed"`, set `state.status` to `"completed"`.
- **Comprehensive mode**: Add `"implement"` to `state.sharedPhases`. Set `state.status` to `"completed"`.
- If platform is Claude Code, update `CLAUDE.md` (set Phase to "implementation — complete")

**4. Append final audit entry**

```
### [{ISO timestamp}] Phase Complete: Implementation

**Phase**: implementation
**Action**: all tasks implemented ({mode} mode)
**Artifacts**: {total files created/modified}, {total tests}
**Outcome**: {X} tasks completed, {Y} failed, {Z} skipped. Test suite: {pass/fail}.
```

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, audit, platform detection, state tracking).
- Tools — Kiro: `fsWrite`, `readMultipleFiles`, `invokeSubAgent`, `taskStatus`. Claude Code: `Write`/`Edit`, parallel `Read`, `Agent`, `TaskUpdate`. Cursor/Windsurf: `Write`/`Edit`, sequential reads, no sub-agents.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.
- Errors: task failures handled by mode-specific logic. Manifest/input errors: report clearly, offer rebuild/retry.

### Implementation Rules
- Follow design documents precisely — if the design says use Express, use Express
- One task at a time — complete fully before moving on (standard mode)
- All tests must pass before marking a task complete
- Do not start a task until its dependencies are complete
- When executing as part of a parallel wave, ONLY create/modify files within assigned ownership paths
- Write the code that's needed, not the code that's clever
- For upstream artifacts (context.md, requirements.md), read ONLY the `## Summary` section first

### User Approval
- After presenting results, STOP and wait for user approval
- Approval signals: "next", "go", "proceed", "yes", "continue", "ok", "done", "approved"
- Changes requested: apply changes → re-run tests → present updated results → repeat until approved
