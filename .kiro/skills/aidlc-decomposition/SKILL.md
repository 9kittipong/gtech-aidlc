---
name: aidlc-decomposition
description: Decompose requirements into units of work with DDD concepts. Define system boundaries, dependencies, and development sequence. Presents incremental vs comprehensive mode choice.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, decomposition, units, DDD, bounded-context, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Decomposition Skill

You break requirements into manageable, independently deliverable units of work. You define system boundaries, dependencies, and development sequence using DDD concepts.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process
4. Do NOT make technology stack decisions — that's the design phase's job
5. Decomposition should be proportional to project complexity
6. Integration contracts are sketches, not full API specs
7. For upstream artifacts (context.md, requirements.md), read ONLY the `## Summary` section first

---

## Activation

```
✅ aidlc-decomposition v1.0.0 active — {platform} detected.
Ready to decompose requirements into units of work.
```

---

## Quick Start

1. Generate D2 decision gate → user fills answers (or "use recommendations")
2. Validate D2 for conflicts → resolve if any
3. Generate units with boundaries, dependencies, and story assignments
4. Present results → wait for approval
5. On approval → choose delivery mode (incremental / incremental skip foundation / comprehensive)

**Reads**: context.md (Summary), requirements.md, personas.md
**Writes**: decisions-units.md, units.md

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-decomposition`
2. `.claude/` → Claude Code. `SPECS_DIR=.claude/specs`, etc.
3. `.cursor/` → Cursor. `SPECS_DIR=.cursor/specs`, etc.
4. `.windsurf/` → Windsurf. `SPECS_DIR=.windsurf/specs`, etc.

Common: `WORKFLOW_DIR=.aidlc/workflow`, `ASSETS_DIR={SKILL_DIR}/assets`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | What exists, stack, scope, feature description | Markdown (context.md), YAML, JSON, plain text, inline |
| User stories with priorities | Requirements from previous phase | Markdown (requirements.md), YAML, JSON, CSV, plain text |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Personas | User types and characteristics | Markdown (personas.md), YAML, JSON |
| Existing decomposition | Pre-existing units or architecture breakdown | Markdown, YAML, JSON, plain text |

If user provides existing decomposition, validate and enrich rather than generate from scratch.

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-units.md | `{WORKFLOW_DIR}/{feature}/decisions-units.md` |
| units.md | `{SPECS_DIR}/{feature}/units.md` |

---

## Initialization

1. Detect environment
2. Resolve feature name:
   - Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` for existing manifests
   - If exactly one manifest → use its `feature` field
   - If multiple manifests → present list, ask user which feature to work on
   - If no manifests → infer from `{SPECS_DIR}/` folders (if exactly one, use it; if multiple, list and ask; if none, ask user)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve project context input (manifest → user override → conventional path → ask)
5. Resolve requirements input (manifest → user override → conventional path → ask)
6. Resolve personas input (manifest → conventional path → skip silently)

---

## Process

### Action: unit-decisions

Generate the D2 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-units.md`.

Read `{ASSETS_DIR}/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- If user said "use recommendations" on a previous gate, that does NOT carry forward
- Include context summary from requirements.md and context.md
- Generate questions covering:
  - **Decomposition need**: Does this project warrant decomposition?
  - **Architecture pattern**: Modular Monolith / Microservices / Distributed / Single Unit
  - **Decomposition strategy**: Domain-Driven / Layer-Based / User Journey-Based / Hybrid
  - **Unit proposals**: Proposed units with story assignments
  - **Dependencies**: How units interact (data, API, events)
  - **Development sequence**: Which units first, which can be parallel

Present:

```
📍 Decomposition: Decision Gate D2 (3 of 6 phases)

- **Decisions**: [X] questions covering decomposition, architecture, strategy, units

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-units.md`, fill answers, say "done"
🤖 Or say "use recommendations" to auto-fill with recommended options

---
🔲 **Your turn**:
- ✏️ Fill answers in the file and say "done"
- 🤖 "use recommendations" — auto-fill for THIS gate
```

**STOP and wait.**

---

### Action: validate-d2

**D2 Validation Rules**:

| Rule | Severity | Detection | Questions | Options |
|---|---|---|---|---|
| Over-Decomposition for Small Project | 🟡 Medium | stories≤10 AND units≥4 AND team≤3 | What's the rationale for this level of decomposition? Is the added complexity worth the benefits? | 1. Reduce to 2-3 units (simpler coordination) 2. Skip decomposition (single unit, monolithic approach) 3. Keep current decomposition (team has experience, anticipating growth) |
| Microservices for Small Team | 🔴 High | arch=Microservices AND team≤3 AND stories≤15 | Does the team have microservices experience? Is the operational overhead manageable? Are you anticipating rapid team growth? | 1. Start with Modular Monolith (easier to manage, can split later) 2. Use Microservices (team experienced, clear rationale) 3. Hybrid approach (monolith with service boundaries defined) |
| Circular Dependencies | 🔴 High | Unit A→B→A (direct or transitive) | Can we break this circular dependency? Should these be combined into one unit? | 1. Introduce shared library/module for common functionality 2. Merge units into single unit 3. Refactor to remove circular dependency 4. Use event-driven pattern to decouple |

Present conflicts grouped by severity, ask for resolution. User can skip validation.

After resolution, write decision summary to manifest `decisions.decomposition` (compact key-value pairs from Decisions Summary section).

### Action: unit-generation

Generate `{SPECS_DIR}/{feature}/units.md` using `{ASSETS_DIR}/units.md` template.

- Read decisions from manifest `decisions.decomposition` section. Fall back to reading `## Decisions Summary` from D2 file if manifest section is missing.
- Assign every story to exactly one unit
- Define interfaces and dependencies using DDD concepts
- Define Context Map relationships

**Validate**:
- ✅ All stories assigned to exactly one unit
- ✅ Clear boundaries and interfaces
- ✅ Dependencies identified with types (Data/API/Event)
- ✅ No circular dependencies

**Update Manifest**: Add `decomposition` phase entry: `status: "draft"`, `timestamp`, `files: [units.md]`.

**Present**:

```
📍 Decomposition: Units of Work (3 of 6 phases)

- **Units**: [X] units — [list names]
- **Strategy**: [strategy]
- **Story Distribution**: [Unit1: X, Unit2: Y]
- **Dependencies**: [count] identified

Artifact at `{SPECS_DIR}/{feature}/units.md`.

---
🔲 **Your turn**:
- ✅ "approve" — approve units and choose delivery mode
- ✏️ "change [what]" — request edits
```

**STOP and wait.**

---

### Action: units-edit

1. Read current units.md
2. Apply changes (merge/split units, reassign stories, update dependencies)
3. Re-validate: all stories assigned, no circular deps, clear boundaries
4. Mark downstream artifacts as `outdated` in manifest (foundation, design, tasks — any that exist)
5. Present with `🔲 **Your turn**` block. **STOP.**

---

### After Units Approved — Mode Selection

On approval: update manifest (`artifacts.decomposition.status`: `"approved"`, add `"decomposition"` to `state.sharedPhases`). Append audit entry. If platform is Claude Code, update `CLAUDE.md` (set Phase to "decomposition").

#### Determine Recommendation

Read context.md Summary section to check project type:
- **Brownfield**: The codebase already has established conventions (auth, error handling, repo structure, communication patterns). Foundation adds little value — recommend skipping it.
- **Greenfield**: No existing conventions. Foundation is important for aligning units — recommend it.

#### Present Mode Choice

```
📍 Units Approved — Choose Delivery Mode

Your project has [X] units. How do you want to proceed?

- 🔹 **incremental** — Design, task, and implement one unit at a time. Includes a foundation spec to define shared conventions first.
- 🔹 **incremental (skip foundation)** — Same as incremental, but skip the foundation spec. Best for brownfield projects where conventions already exist.{recommended for brownfield}
- 🔹 **comprehensive** — Single design covering all units. Best for tightly coupled units or small projects.

👉 Recommendation: {incremental (skip foundation) for brownfield / incremental for greenfield / comprehensive for 2 tightly-coupled units}
Reason: {brief explanation — e.g., "Your codebase already has established auth, error handling, and repo structure. Foundation would re-ask what's already decided."}

---
🔲 **Your turn**:
- 🔹 "incremental" — proceed to foundation specification
- 🔹 "incremental skip foundation" — skip foundation, select first unit
- 🔹 "comprehensive" — skip foundation, single design for all units
```

**STOP and wait.**

**If incremental**: Update manifest (`state.mode: "incremental"`). Auto-continue to `aidlc-foundation` (see Skill Handoff).

**If incremental skip foundation**: Update manifest (`state.mode: "incremental"`, `state.foundationSkipped: true`). Skip foundation — proceed directly to unit selection (below).

**If comprehensive**: Update manifest (`state.mode: "comprehensive"`). Auto-continue to `aidlc-design` (see Skill Handoff).

---

### Unit Selection (After Skip Foundation)

When the user chooses "incremental skip foundation", present the unit list for selection:

```
📍 Foundation Skipped — Select First Unit

Using existing codebase conventions. Ready to design and implement units one at a time.

**Domain units**:
1. 📦 [Unit A] — [purpose] ([X] stories)
2. 📦 [Unit B] — [purpose] ([Y] stories)

---
🔲 **Your turn**:
- 🎯 "select [unit name]" — start working on that unit
- 📋 "show units" — see full unit details
```

**STOP and wait.**

When user selects a unit:
1. Update manifest: set `units[{unit}].status` to `"in-progress"`, set `units[{unit}].phase` to `"design"`
2. Auto-continue to `aidlc-design` (see Skill Handoff)

---

## Decomposition Strategies Reference

For decomposition strategies (domain-driven, layer-based, user-journey, hybrid), sizing guidance, DDD concepts, and common pitfalls, read `{SKILL_DIR}/references/decomposition-strategies.md` when generating units.

---

## Skill Handoff

When the user chooses a delivery mode, auto-continue:

1. **Incremental** → read `{PLATFORM_DIR}/skills/aidlc-foundation/SKILL.md` and follow its instructions
2. **Incremental (skip foundation)** → present unit selection (above), then on unit selection read `{PLATFORM_DIR}/skills/aidlc-design/SKILL.md` and follow its instructions scoped to the selected unit
3. **Comprehensive** → read `{PLATFORM_DIR}/skills/aidlc-design/SKILL.md` and follow its instructions

If the next skill's SKILL.md cannot be found, fall back to:
```
👉 Next: Activate **aidlc-foundation** (incremental), **aidlc-design** (skip foundation / comprehensive).
```

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, audit, templates, platform detection).
- Tools — Kiro: `fsWrite`, `readMultipleFiles`. Claude Code: `Write`/`Edit`, parallel `Read`. Cursor/Windsurf: `Write`/`Edit`, sequential reads.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.
- Errors: report clearly with what happened and what to do. Offer rebuild/retry. Never lose work silently.

### Audit Trail
Append to `{WORKFLOW_DIR}/{feature}/audit.md` after: decision gate, validation, generation, approval, edit.

Use the standard audit entry format:

```
### [{ISO timestamp}] {Phase}: {Action}

**Phase**: decomposition
**Action**: {decision-gate | validation | generation | approval | edit}
**Artifacts**: {files created or modified}
**Outcome**: {result summary — e.g., "4 units defined, domain-driven strategy, 12 stories assigned"}
```
