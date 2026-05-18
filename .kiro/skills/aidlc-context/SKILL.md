---
name: aidlc-context
description: Scan workspace, assess project landscape, and generate context document with steering files. First phase of the AI-DLC specification workflow.
license: MIT
compatibility: Requires file system access. Auto-detects environment (Kiro, Claude Code, Cursor, Windsurf).
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, context, discovery, assessment, workspace, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Context Assessment Skill

You assess the project landscape — existing code, technology stack, architecture patterns — and generate a context document with steering files that inform all subsequent phases.

When active:
1. Follow ONLY the process below
2. WAIT for user approval before considering the phase complete
3. Never narrate your internal process — present only results, questions, and choices

---

## Activation

When loaded, present:

```
✅ aidlc-context v1.0.0 active — {platform} detected.
Ready to assess your project and generate context.
```

Then proceed to initialization.

---

## Quick Start

1. Scan workspace → classify greenfield/brownfield → detect stack and patterns
2. Generate `context.md` with findings and recommendations
3. Generate steering files (product.md, tech.md, structure.md, resources.md)
4. Create manifest and audit trail
5. Present results with recommended workflow diagram → wait for approval
6. On approval → hand off to requirements

**Reads**: Workspace files (source, configs, README)
**Writes**: context.md, steering/\*, manifest, audit.md

---

## Environment Detection

Detect platform and set paths:

1. `.kiro/` exists → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-context`
2. `.claude/` exists → Claude Code. `SPECS_DIR=.claude/specs`, `STEERING_DIR=.claude/steering`, `SKILL_DIR=.claude/skills/aidlc-context`
3. `.cursor/` exists → Cursor. `SPECS_DIR=.cursor/specs`, `STEERING_DIR=.cursor/steering`, `SKILL_DIR=.cursor/skills/aidlc-context`
4. `.windsurf/` exists → Windsurf. `SPECS_DIR=.windsurf/specs`, `STEERING_DIR=.windsurf/steering`, `SKILL_DIR=.windsurf/skills/aidlc-context`

Common: `WORKFLOW_DIR=.aidlc/workflow`, `ASSETS_DIR={SKILL_DIR}/assets`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Feature request | What the user wants to build | Inline chat message |
| Workspace access | Ability to scan project files, configs, source code | Filesystem |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Existing architecture docs | README, architecture.md, or similar | Markdown, plain text, any doc |
| Prior context document | Previously generated context.md | Markdown |

If user provides an existing context doc ("use docs/architecture.md as context"), enrich it with workspace scan rather than starting from scratch.

### Outputs
| Artifact | Default Path |
|---|---|
| context.md | `{SPECS_DIR}/{feature}/context.md` |
| product.md | `{STEERING_DIR}/product.md` |
| tech.md | `{STEERING_DIR}/tech.md` |
| structure.md | `{STEERING_DIR}/structure.md` |
| aidlc-workflow.md | `{STEERING_DIR}/aidlc-workflow.md` |
| resources.md | `{STEERING_DIR}/resources.md` |
| CLAUDE.md | `{PROJECT_ROOT}/CLAUDE.md` (Claude Code only) |
| aidlc-manifest.yaml | `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` |
| audit.md | `{WORKFLOW_DIR}/{feature}/audit.md` |

---

## Initialization

1. Detect environment (above)
2. Detect language from user's first message (ISO 639-1)
3. Get feature name from user
4. Check for existing manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`:
   - Found → resume scenario. Read manifest, present what exists, ask user how to proceed.
   - Not found → fresh start.
5. Create folders: `{SPECS_DIR}/{feature}/`, `{WORKFLOW_DIR}/{feature}/`

---

## Process

### Action: context-assessment

#### Step 1: Workspace Detection

Scan the workspace:
- Check for existing source files (.ts, .js, .py, .java, etc.)
- Check for build configuration (package.json, pom.xml, Cargo.toml, etc.)
- Classify as **Greenfield** or **Brownfield**

#### Step 2: Technology Stack Detection (Brownfield)

If brownfield, identify:
- **Stack**: Languages, Frameworks, Build System, Testing, Infrastructure
- **Patterns & Conventions**: How the framework is used (architecture pattern, data access pattern, API response format, error handling approach, auth mechanism, validation approach, logging). Detect from source code, not just config files.
- **Environment**: Config approach, environments, secrets management
- **CI/CD**: Pipeline tool, stages, deploy target
- **Dependencies**: Lockfile, version strategy, monorepo tooling
- **Technical Debt**: Deprecated patterns, low coverage areas, known issues

#### Step 3: Existing Code Analysis (Brownfield)

Document:
- **Architecture pattern**: How modules are organized and depend on each other
- **Entry points**: API servers, workers, CLI commands — what they do
- **Data layer**: Database types, ORMs, access patterns
- **Key components**: Important modules and their responsibilities
- **Integration points**: External APIs, databases, services
- **Module dependencies**: Import graph — which modules depend on which
- **Data flow**: How a request moves through the system (middleware → handler → service → repository → database)
- **Key abstractions**: Base classes, interfaces, patterns the codebase is built on
- **Test organization**: Where tests live, what types exist, coverage, utilities
- **Build artifacts**: What gets built, containerization, deploy target

#### Step 4: Feature Impact Assessment

Assess: Affected areas, Files likely to change, Dependencies.

#### Step 5: Generate Context

Read `{ASSETS_DIR}/context.md` for output structure.
Generate `{SPECS_DIR}/{feature}/context.md`.

#### Step 6: Generate Steering Files

Read each asset template and generate the corresponding steering file:

1. `{ASSETS_DIR}/steering-product.md` → `{STEERING_DIR}/product.md`
2. `{ASSETS_DIR}/steering-tech.md` → `{STEERING_DIR}/tech.md`
3. `{ASSETS_DIR}/steering-structure.md` → `{STEERING_DIR}/structure.md`
4. `{ASSETS_DIR}/steering-workflow.md` → `{STEERING_DIR}/aidlc-workflow.md`
   - Replace `{feature}`, `{language}`, `{SPECS_DIR}` with actual values
5. `{ASSETS_DIR}/steering-resources.md` → `{STEERING_DIR}/resources.md`

**Kiro only**: Add `inclusion: always` YAML front-matter to each steering file.
**Claude Code only**: Also generate CLAUDE.md at project root using `{ASSETS_DIR}/claude-md.md`.
**Cursor/Windsurf**: No front-matter, no CLAUDE.md.

**Greenfield**: Populate `product.md` from user's request. Use "Pending D3 decisions" placeholders in `tech.md` and `structure.md`.
**Brownfield**: Populate all files with detected stack, structure, and conventions.
**If steering files already exist**: Read them as additional context, then overwrite with updated content.

#### Step 7: Create Manifest

Create `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` with:

```yaml
version: "2.1"
feature: "{feature}"
language: "{language}"
platform: "{platform}"
created: "{ISO timestamp}"
updated: "{ISO timestamp}"
state:
  status: "active"
  sharedPhases: []
  mode: null
  foundationSkipped: false
artifacts:
  context:
    status: "draft"
    timestamp: "{ISO timestamp}"
    files: [context.md]
context-summary:
  type: "{Greenfield/Brownfield}"
  stack: "{Primary language + framework, e.g. TypeScript / Express / PostgreSQL}"
  architecture: "{Pattern, e.g. Modular Monolith}"
  feature: "{1-sentence description}"
  impact: "{New standalone / Extends existing / Cross-cutting}"
  complexity: "{Low/Medium/High}"
  recommendations: { personas: false, units: false, nfr: false }
decisions: {}
steering:
  updatedBy:
    product: [context]
    tech: [context]
    structure: [context]
units: []
```

**Manifest v2.1 conventions**:
- **Shared vs. per-unit state**: `state.sharedPhases` tracks phases that apply to the whole project (context, requirements, decomposition, foundation). Per-unit phases (design, tasks, implement) are tracked in each `units[]` entry.
- **Per-unit structure**: Each unit entry in `units[]` has: `name`, `status`, `phase` (current), `completedPhases`, `implementationMode`, `implementation` (task counters), `artifacts`, and `decisions`.
- **Parallel units**: Multiple units can have `status: "in-progress"` simultaneously — different team members or sessions can work on different units.
- **Comprehensive mode**: When `mode: "comprehensive"`, `units[]` stays empty. Shared `artifacts` and `decisions` drive the workflow. Design/tasks/implement phases are tracked in `state.sharedPhases`.
- Artifacts are grouped by phase, not by file. Each phase entry has: `status` (draft/approved/outdated), `timestamp`, and `files` (list of filenames relative to `{SPECS_DIR}/{feature}/`)
- Decision gate files (`decisions-{phase}.md`) are implicit — not listed in `files`
- Steering paths are implicit (`{STEERING_DIR}/{name}.md`) — only `updatedBy` is tracked
- `context-summary` stores key fields from context.md Summary for downstream skills
- `decisions` stores compact decision summaries from shared phase gates (requirements, decomposition, foundation). Unit-scoped decisions (design, tasks) go in `units[].decisions`

**Unit entry structure** (added by decomposition skill):
```yaml
units:
  - name: "{unit-name}"
    status: "not-started"       # not-started | in-progress | completed
    phase: null                 # null | design | tasks | implement | completed
    completedPhases: []         # [design, tasks, implement]
    implementationMode: null    # null | standard | parallel | autonomous
    implementation:
      totalTasks: 0
      completedTasks: 0
      currentTask: null
      currentWave: null
    artifacts: {}               # per-unit: design, tasks entries
    decisions: {}               # per-unit: design, tasks decisions
```

Register any user-provided files by adding them to the relevant phase's `files` list.

#### Step 8: Create Audit Trail

Create `{WORKFLOW_DIR}/{feature}/audit.md` with header: `# Audit Trail — {feature}`

#### Step 9: Validate

- ✅ Project type identified (greenfield/brownfield)
- ✅ Technology stack documented (if brownfield)
- ✅ Architecture pattern identified (if brownfield)
- ✅ Feature impact assessment complete
- ✅ Recommendations provided (Personas, Units, NFR)
- ✅ All steering files generated
- ✅ Manifest created
- ✅ CLAUDE.md generated (Claude Code only)

#### Step 10: Present Results

Present findings and a recommended workflow diagram tailored to the project:

```
📍 Context Assessment (1 of 6 phases)

[Summary of findings]

- **Project Type**: [Greenfield/Brownfield]
- **Stack**: [Detected or N/A]
- **Architecture**: [Detected or N/A]
- **Impact**: [New standalone / Extends existing / Cross-cutting]
- **Recommendations**: Personas [Yes/No], Units [Yes/No], NFR [Yes/No]

## Recommended Workflow

[ASCII workflow diagram — see below]

Artifact at `{SPECS_DIR}/{feature}/context.md`.

---
🔲 **Your turn**:
- ✅ "proceed" — move to requirements
- ✏️ "change [what]" — request edits
```

**Generate the workflow diagram** based on the recommendations from context assessment. Use top-down ASCII art format so it renders correctly in narrow chat windows and terminals. Tailor the diagram to THIS project — don't show all possible paths, show the recommended path.

**Simple project** (Units=No, few stories, single domain):

```
       ┌─────────────┐
       │  Context ✅  │
       └──────┬──────┘
              ▼
       ┌──────────────┐
       │ Requirements │
       └──────┬───────┘
              ▼
       ┌──────────┐
       │  Design  │
       └────┬─────┘
            ▼
       ┌─────────┐
       │  Tasks  │
       └────┬────┘
            ▼
       ┌───────────┐
       │ Implement │
       └─────┬─────┘
             ▼
       ┌─────────────┐
       │ Code Review │
       └─────────────┘
```

**Complex greenfield project** (Units=Yes, multiple domains, no existing codebase):

```
       ┌─────────────┐
       │  Context ✅  │
       └──────┬──────┘
              ▼
       ┌──────────────┐
       │ Requirements │
       └──────┬───────┘
              ▼
       ┌───────────────┐
       │ Decomposition │
       └───────┬───────┘
               ▼
       ┌────────────┐
       │ Foundation │
       └──┬─────┬───┘
          │     │
          ▼     ▼
     ┌────────┐ ┌────────┐
     │ Unit 1 │ │ Unit 2 │  ← each: Design → Tasks → Implement
     └───┬────┘ └───┬────┘
         │          │
         ▼          ▼
     ┌──────────────────┐
     │ Solutions Review │
     └────────┬─────────┘
              ▼
     ┌─────────────┐
     │ Code Review │
     └─────────────┘
```

**Complex brownfield project** (Units=Yes, multiple domains, existing codebase with established conventions):

```
       ┌─────────────┐
       │  Context ✅  │
       └──────┬──────┘
              ▼
       ┌──────────────┐
       │ Requirements │
       └──────┬───────┘
              ▼
       ┌───────────────┐
       │ Decomposition │
       └──┬─────┬──────┘
          │     │
          ▼     ▼
     ┌────────┐ ┌────────┐
     │ Unit 1 │ │ Unit 2 │  ← each: Design → Tasks → Implement
     └───┬────┘ └───┬────┘
         │          │
         ▼          ▼
     ┌──────────────────┐
     │ Solutions Review │
     └────────┬─────────┘
              ▼
     ┌─────────────┐
     │ Code Review │
     └─────────────┘
```

**With prototype recommended** (uncertain requirements):

```
       ┌─────────────┐
       │  Context ✅  │
       └──────┬──────┘
              ▼
       ┌──────────────┐
       │ Requirements │◄─┐
       └──────┬───────┘  │
              ▼          │ refine
       ┌───────────┐    │
       │ Prototype ├────┘
       └───────────┘
              ·
              · (then continue)
              ▼
       ┌──────────┐
       │  Design  │
       └────┬─────┘
            ▼
       ┌─────────┐
       │  Tasks  │
       └────┬────┘
            ▼
       ┌───────────┐
       │ Implement │
       └─────┬─────┘
             ▼
       ┌─────────────┐
       │ Code Review │
       └─────────────┘
```

Adapt the diagram based on:
- **Project type**: Brownfield complex projects skip Foundation (conventions already exist). Greenfield complex projects include Foundation.
- Number of recommended units (show each unit as a box if ≤4, otherwise show "N units" as one box)
- Whether personas are recommended (add a note next to the Requirements box)
- Whether NFR is recommended (add a note next to the Design box)
- Whether prototype seems useful (uncertain requirements, novel domain)

The diagram is a recommendation — the user can deviate at any routing decision point.

**STOP and wait for user approval.**

On approval: update manifest (set `artifacts.context.status` to `"approved"`, add `"context"` to `state.sharedPhases`). Append audit entry. Then auto-continue (see Skill Handoff below).

### Action: context-edit

1. Read current context.md
2. Apply requested changes
3. Re-validate (Step 9)
4. If edits affect steering files (stack changed, project type changed), update relevant steering files
5. Update manifest (timestamp, keep status "draft")
6. Mark downstream artifacts as `outdated` in manifest (requirements, personas, units, foundation, design, tasks — any that exist)
7. Present changes with `🔲 **Your turn**` block
8. **STOP** — wait for approval

---

## Skill Handoff

When the user approves and says "proceed", auto-continue to the next skill:

1. Resolve the next skill path: replace `aidlc-context` with `aidlc-requirements` in `SKILL_DIR` → `{PLATFORM_DIR}/skills/aidlc-requirements/SKILL.md`
2. Read that file
3. Follow its instructions — begin the requirements phase in the same conversation

**Next skill mapping**:
- Context approved → `aidlc-requirements`

If the next skill's SKILL.md cannot be found (not installed), fall back to recommending manual activation:
```
👉 Next: Activate the **aidlc-requirements** skill to generate user stories.
```

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, audit, templates, platform detection).
- Tools — Kiro: `fsWrite`, `readMultipleFiles`. Claude Code: `Write`/`Edit`, parallel `Read`. Cursor/Windsurf: `Write`/`Edit`, sequential reads.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.
- Errors: report clearly with what happened and what to do. Offer rebuild/retry. Never lose work silently.

### Audit Trail
Append to `{WORKFLOW_DIR}/{feature}/audit.md` after: assessment, approval, edit.

Use the standard audit entry format:

```
### [{ISO timestamp}] {Phase}: {Action}

**Phase**: context
**Action**: {assessment | approval | edit}
**Artifacts**: {files created or modified}
**Outcome**: {result summary — e.g., "Brownfield, TypeScript/Express/PostgreSQL, extends existing, 3 areas affected"}
```
