---
name: aidlc-requirements
description: Translate business needs into user stories with EARS acceptance criteria. Generates decision gate, personas, and requirements. Includes routing recommendation for next phase.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, requirements, user-stories, EARS, personas, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Requirements Skill

You translate business needs into clear, actionable requirements. Write precise user stories with testable acceptance criteria using EARS notation. Prioritize ruthlessly and ensure every story is implementable by an engineer who has never spoken to the stakeholder.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-requirements v1.0.0 active — {platform} detected.
Ready to generate requirements from project context.
```

---

## Quick Start

1. Generate D1 decision gate → user fills answers (or "use recommendations")
2. Validate D1 for conflicts → resolve if any
3. Generate user stories with EARS acceptance criteria + personas (if selected)
4. Present results → wait for approval
5. On approval → analyze complexity → recommend next phase (decomposition vs design vs prototype)

**Reads**: context.md (Summary), steering files (Summaries), resources.md
**Writes**: decisions-requirements.md, requirements.md, personas.md, steering/product.md

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-requirements`
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

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Steering files | Product, tech, structure context | Markdown |
| External design resources | Figma screens, wireframes, API specs | Via MCP, URLs, file paths |
| Existing requirements | Pre-existing user stories or backlog | Markdown, YAML, JSON, CSV (Jira export), plain text |

If user provides existing requirements, use them as starting point — run validation and enrichment (add EARS criteria if missing, add priorities if missing) rather than full generation.

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-requirements.md | `{WORKFLOW_DIR}/{feature}/decisions-requirements.md` |
| requirements.md | `{SPECS_DIR}/{feature}/requirements.md` |
| personas.md | `{SPECS_DIR}/{feature}/personas.md` (conditional) |
| product.md (update) | `{STEERING_DIR}/product.md` |

---

## Initialization

1. Detect environment
2. Resolve feature name:
   - Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` for existing manifests
   - If exactly one manifest → use its `feature` field
   - If multiple manifests → present list, ask user which feature to work on
   - If no manifests → infer from `{SPECS_DIR}/` folders (if exactly one, use it; if multiple, list and ask; if none, ask user)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve project context input (manifest → user override → conventional path `{SPECS_DIR}/{feature}/context.md` → ask)
5. If steering files exist, read Summary sections from `{STEERING_DIR}/product.md`, `tech.md`, `structure.md`. Read `resources.md` in full.

---

## Process

### Action: requirements-decisions

Generate the D1 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-requirements.md`.

Read `{ASSETS_DIR}/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- If user said "use recommendations" on a previous gate, that does NOT carry forward
- Include context summary from context input
- Generate questions covering: feature scope, user types, core functionality, data entities, integrations, business rules, constraints, priorities
- **MANDATORY**: Include explicit personas question

Present the decision file:

```
📍 Requirements: Decision Gate D1 (2 of 6 phases)

- **Decisions**: [X] questions covering scope, users, features, integrations

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-requirements.md`, fill answers, say "done"
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

### Action: validate-d1

After D1 answers are filled, validate for conflicts.

**Validation Process**:
1. Parse all answers from the decisions file (read Decisions Summary section)
2. Load context from context.md (team size, scope, timeline)
3. Check each rule below against user answers
4. Collect conflicts, adjust severity by context
5. If conflicts found → present grouped by severity (🔴 High → 🟡 Medium → 🟢 Low), ask for resolution
6. If clean or all resolved → write decision summary to manifest `decisions.requirements` (compact key-value pairs from Decisions Summary section) → proceed to generation

**D1 Validation Rules**:

| Rule | Severity | Detection | Questions | Options |
|---|---|---|---|---|
| Scope vs Timeline Mismatch | 🟡 Medium | Scope="Full product"/"Enterprise" AND timeline<3mo AND stories>15 | Is timeline realistic? Can we prioritize for phased delivery? | 1. Reduce to MVP 2. Extend timeline 3. Increase team 4. Keep (justify) |
| Complex Features Without Personas | 🟢 Low | User types≥3 AND personas=No | Do different user types have significantly different needs? Would personas help clarify requirements? | 1. Generate personas to clarify user needs 2. Skip personas (requirements are clear enough) |
| Many Integrations Without Priority | 🟡 Medium | Integrations≥3, no priority indicated | Which integrations are required for MVP? Can some be deferred? | 1. Prioritize integrations — mark MVP-required vs deferred 2. Reduce to core integrations only 3. Keep all (team has capacity) |
| Broad Scope Without Boundaries | 🟡 Medium | Scope covers 3+ areas, no exclusions | What is explicitly out of scope? Are there natural phase boundaries? | 1. Define explicit out-of-scope items 2. Split into phased delivery with clear boundaries 3. Keep broad scope (small project, manageable) |
| Enterprise Scope Solo Developer | 🔴 High | Scope="Full product"/"Enterprise" AND team=1 | Can scope be reduced to MVP first? Is there a realistic timeline for one person? | 1. Reduce to MVP — prioritize core features only 2. Plan phased delivery with clear milestones 3. Bring in additional help 4. Keep current scope (experienced dev, long timeline) |
| Heavy Integration Load | 🔴 High | Integrations≥5, no phased delivery | Which integrations are critical for launch? Can integrations be added incrementally? | 1. Phase integrations — MVP with 2-3 core, rest later 2. Use mock/stub integrations for non-critical ones 3. Keep all (team has integration experience) |
| Compliance Without Security Stories | 🔴 High | GDPR/HIPAA/SOC2/PCI mentioned, no privacy stories | Which compliance requirements apply? Do we need stories for consent, right-to-delete, audit trails, encryption? | 1. Add compliance-specific stories (consent, data deletion, audit logging, encryption) 2. Defer compliance to separate phase 3. Mark as non-production (compliance not required yet) |
| Performance Without NFR Flag | 🟡 Medium | "scalable"/"real-time"/"high traffic" mentioned, NFR=No | Are there specific performance targets (response time, throughput, concurrent users)? Should we include NFR analysis? | 1. Enable NFR analysis — add performance targets 2. Add performance-related acceptance criteria to key stories 3. Skip NFR (prototype/internal tool) |
| Real-Time Without Technical Stories | 🟡 Medium | "real-time"/"live updates" mentioned, no push stories | Which features need real-time updates vs polling? What's the acceptable latency? | 1. Add explicit real-time stories with technology approach (WebSocket/SSE/polling) 2. Use polling for MVP, upgrade later 3. Clarify "real-time" means near-real-time (acceptable delay) |
| Multi-Platform Without Capacity | 🟡 Medium | Platforms≥3, team≤3 | Which platform is the primary target for launch? Can secondary platforms be deferred? | 1. Launch with primary platform first, add others incrementally 2. Use cross-platform framework (React Native, Flutter) 3. Keep all platforms (team has multi-platform experience) |

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

### Action: requirements-generation

#### External Resources (Conditional)

If `{STEERING_DIR}/resources.md` lists available resources:
- **Design tool**: Use MCP to read screens, user flows → extract user journeys and acceptance criteria
- **Design docs/wireframes**: Read files → identify UI requirements
- **API specs**: Read OpenAPI/GraphQL → identify integration stories and data entities
- **Documentation**: Use web search/fetch → gather domain context
- Cite external sources in generated stories

#### Personas (Conditional)

Generate IF D1 indicated "Yes" for personas or multiple user types.
Read `{ASSETS_DIR}/persona.md` for output structure.
Generate `{SPECS_DIR}/{feature}/personas.md`.

#### Requirements

Derive from D1 decisions + context + personas (if exists).
Read decisions from manifest `decisions.requirements` section. Fall back to reading `## Decisions Summary` from the decisions file if manifest section is missing.
Read `{ASSETS_DIR}/requirements.md` for output structure.
Generate `{SPECS_DIR}/{feature}/requirements.md`.

#### Validate Output

- ✅ All D1 scope features have stories
- ✅ All user types represented
- ✅ All stories have EARS acceptance criteria
- ✅ Stories organized by functional area
- ✅ Priorities assigned

#### Update Steering

Update `{STEERING_DIR}/product.md`:
- **Target Users**: Replace with user types from personas/D1
- **Key Features**: Replace with functional areas from requirements
- Read current file first, preserve Overview and Problem Statement

#### Update Manifest

Update artifacts in manifest:
- Add `requirements` phase entry: `status: "draft"`, `timestamp`, `files: [requirements.md, personas.md]` (include personas.md only if generated)
- Update `steering.updatedBy.product` to include `requirements`

#### Present Results

```
📍 Requirements (2 of 6 phases)

[Summary]

- **Total Stories**: [X] across [Y] functional areas
- **Priority**: [X] High, [Y] Medium, [Z] Low
- **User Types**: [list]
- **Personas**: [Generated / Skipped]

Artifact at `{SPECS_DIR}/{feature}/requirements.md`.

---
🔲 **Your turn**:
- ✅ "proceed" — move to routing decision
- ✏️ "change [what]" — request edits
```

**STOP and wait for approval.**

On approval: update manifest (set `artifacts.requirements.status` to `"approved"`, add `"requirements"` to `state.sharedPhases`). Append audit entry. If platform is Claude Code, update `CLAUDE.md` at project root (set Phase to "requirements", remove nextAction line or set to current state). Then auto-continue to routing-decision (below).

### Action: requirements-edit

1. Read current requirements.md (and personas.md if exists)
2. Apply requested changes
3. Re-validate output (all 5 checks above)
4. If personas affected, update personas.md too
5. Update manifest timestamp
6. Mark downstream artifacts as `outdated` in manifest (units, foundation, design, tasks — any that exist)
7. Present changes with `🔲 **Your turn**` block
8. **STOP** — wait for approval

### Action: routing-decision

After requirements are approved, analyze complexity and project context to recommend next phase.

#### Step 1: Analyze Complexity

Read requirements.md and count:
- Total user stories
- Distinct functional domains/areas
- Distinct user types/personas
- External integrations

#### Step 2: Analyze Project Context

Read context.md Summary section and extract:
- **Project type**: Greenfield or Brownfield
- **Impact**: New standalone / Extends existing / Cross-cutting
- **Architecture**: Existing architecture pattern (if brownfield)

#### Step 3: Recommend

Apply context-aware routing logic:

**Brownfield feature enhancement** (type=Brownfield AND impact="Extends existing" or "New standalone within existing"):
- The existing codebase already has module boundaries. Decomposition adds little value.
- Recommend **design** unless the feature is truly cross-cutting (touches 4+ existing modules) or introduces a new domain that doesn't fit existing structure.
- Thresholds for decomposition are raised: 10+ stories AND 3+ domains AND cross-cutting impact.

**Brownfield cross-cutting change** (type=Brownfield AND impact="Cross-cutting"):
- The change spans multiple existing modules. Decomposition helps plan the cross-cutting work.
- Use standard thresholds: 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations.

**Greenfield project** (type=Greenfield):
- No existing structure to build on. Decomposition helps define boundaries from scratch.
- Use standard thresholds: 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations.

**Summary**:

| Context | Recommend Design (skip decomposition) | Recommend Decomposition |
|---|---|---|
| Brownfield + extends existing | Default — unless 10+ stories AND 3+ domains AND cross-cutting | 10+ stories AND 3+ domains AND cross-cutting |
| Brownfield + cross-cutting | Below all standard thresholds | 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations |
| Greenfield | Below all standard thresholds | 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations |

#### Step 4: Present

```
📍 Requirements Complete — What's Next?

Your project has [X stories] across [Y areas] with [Z user types] and [W integrations].
[If brownfield: "This is a [feature enhancement / cross-cutting change] in an existing [architecture] codebase."]

👉 Recommendation: [Phase 3: Decompose into units / Phase 4: Go straight to design]
Reason: [brief explanation — include why brownfield context influenced the recommendation if applicable]

---
🔲 **Your turn**:
- ✅ "proceed" — follow recommendation
- 🔀 "go to [design/units]" — override recommendation
- 🧪 "prototype" — build a quick throwaway prototype first
```

**STOP and wait.** When user responds, auto-continue to the chosen skill (see Skill Handoff below).

---

## Skill Handoff

When the user makes a routing choice, auto-continue to the next skill:

1. Resolve the next skill path based on user's choice:
   - "proceed" (recommendation = decomposition) OR "go to units" → `{PLATFORM_DIR}/skills/aidlc-decomposition/SKILL.md`
   - "proceed" (recommendation = design) OR "go to design" → `{PLATFORM_DIR}/skills/aidlc-design/SKILL.md`
   - "prototype" → `{PLATFORM_DIR}/skills/aidlc-prototype/SKILL.md`
2. Read that file
3. Follow its instructions — begin the next phase in the same conversation

Where `{PLATFORM_DIR}` is the detected platform directory (`.kiro`, `.claude`, `.cursor`, `.windsurf`).

If the next skill's SKILL.md cannot be found (not installed), fall back to recommending manual activation:
```
👉 Next: Activate the **aidlc-{skill}** skill to continue.
```

---

## EARS Notation Reference

For EARS patterns and best practices, read `{SKILL_DIR}/references/ears-notation.md` when generating acceptance criteria.

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, audit, templates, validation, platform detection).
- Tools — Kiro: `fsWrite`, `readMultipleFiles`. Claude Code: `Write`/`Edit`, parallel `Read`. Cursor/Windsurf: `Write`/`Edit`, sequential reads.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.
- Errors: report clearly with what happened and what to do. Offer rebuild/retry. Never lose work silently.

### Audit Trail
Append to `{WORKFLOW_DIR}/{feature}/audit.md` after: decision gate, validation, generation, approval, edit.

Use the standard audit entry format:

```
### [{ISO timestamp}] {Phase}: {Action}

**Phase**: requirements
**Action**: {decision-gate | validation | generation | approval | edit | routing-decision}
**Artifacts**: {files created or modified}
**Outcome**: {result summary — e.g., "8 stories across 3 areas, 2 High / 4 Medium / 2 Low, personas generated"}
```
