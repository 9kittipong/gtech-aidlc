---
name: aidlc-foundation
description: Define shared conventions, contracts, and infrastructure for incremental multi-unit projects. Generates foundation specification, manages infrastructure units, and coordinates unit selection for downstream phases.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, foundation, conventions, infrastructure, contracts, incremental, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Foundation Skill

You establish the shared foundation that keeps parallel workstreams aligned. Define repository structure, authentication, error handling, communication patterns, database strategy, and infrastructure units. This skill runs in incremental mode after units are defined.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-foundation v1.0.0 active — {platform} detected.
Ready to define shared conventions and infrastructure for your units.
```

---

## Quick Start

1. Generate DF decision gate → user fills answers (or "use recommendations")
2. Validate DF for conflicts → resolve if any
3. Generate foundation spec (repo structure, auth, error handling, comms, DB, shared types)
4. Add infrastructure units to units.md → update steering/tech.md
5. Present results → wait for approval
6. On approval → present unit selection for first unit → hand off to design

**Reads**: context.md (Summary), requirements.md, units.md
**Writes**: decisions-foundation.md, foundation.md, units.md (updated), steering/tech.md

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-foundation`
2. `.claude/` → Claude Code. `SPECS_DIR=.claude/specs`, etc.
3. `.cursor/` → Cursor. `SPECS_DIR=.cursor/specs`, etc.
4. `.windsurf/` → Windsurf. `SPECS_DIR=.windsurf/specs`, etc.

Common: `WORKFLOW_DIR=.aidlc/workflow`, `ASSETS_DIR={SKILL_DIR}/assets`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | Stack, architecture, scope | Markdown (context.md), YAML, JSON, plain text, inline |
| User stories | Requirements for scoping | Markdown (requirements.md), YAML, JSON, CSV, plain text |
| Units | Decomposition with boundaries and dependencies | Markdown (units.md), YAML, JSON |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Existing foundation | Pre-existing conventions or architecture doc | Markdown, YAML, JSON, plain text |

If user provides existing foundation, validate and enrich rather than generate from scratch.

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-foundation.md | `{WORKFLOW_DIR}/{feature}/decisions-foundation.md` |
| foundation.md | `{SPECS_DIR}/{feature}/foundation.md` |
| units.md (update) | `{SPECS_DIR}/{feature}/units.md` (infrastructure units added) |

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
   - Context (manifest → user override → conventional path → ask)
   - Requirements (manifest → user override → conventional path → ask)
   - Units (manifest → user override → conventional path `{SPECS_DIR}/{feature}/units.md` → ask)

---

## Process

### Action: foundation-decisions

Generate the DF decisions file at `{WORKFLOW_DIR}/{feature}/decisions-foundation.md`.

Read `{ASSETS_DIR}/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- If user said "use recommendations" on a previous gate, that does NOT carry forward
- Include context from units.md, requirements.md, and context.md
- The architecture pattern from D2 (in units.md Summary) informs which questions to ask

**Generate questions covering**:
- **Team structure**: Solo / Small team (2-3) / Multiple teams (4+)
- **Repository strategy**: Monorepo / Multi-repo / Hybrid
- **Shared foundations level**: Everything shared / Interfaces only / Minimal
- **API architecture**: API Gateway / BFF / Direct / Hybrid (only for microservices/distributed)
- **Frontend hosting**: Same monorepo / Separate repo / CDN-only (if frontend units exist)
- **Shared UI components**: Design system package / Component library / None (if multiple frontend units)
- **Authentication**: JWT / Session / OAuth2 / API keys
- **Error handling format**: RFC 7807 / Custom envelope / Framework default
- **Inter-unit communication**: REST / Events / gRPC / Mixed
- **Database strategy**: Shared DB separate schemas / DB per unit / Mixed
- **Shared types strategy**: Shared package / Code generation / Manual sync
- **Infrastructure units needed**: Gateway / BFF / Auth service / Event bus / None
- **Infrastructure unit strategy**: Combined (single Foundation unit) / Separate (individual infra units) — recommend combined for solo/small teams, separate for multiple teams with independent deploy needs

For solo developers: still ask technical questions but mark team/process questions as skippable.

Present:

```
📍 Foundation: Decision Gate DF

- **Decisions**: [X] questions covering team, repo, API, auth, comms, DB, infrastructure

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-foundation.md`, fill answers, say "done"
🤖 Or say "use recommendations" to auto-fill with recommended options

---
🔲 **Your turn**:
- ✏️ Fill answers in the file and say "done"
- 🤖 "use recommendations" — auto-fill for THIS gate
```

**STOP and wait.**

---

### Action: validate-df

**DF Validation Rules**:

| Rule | Severity | Detection | Questions | Options |
|---|---|---|---|---|
| Microservices with Shared Schema | 🔴 High | arch=Microservices AND DB=shared schema | Shared schema violates microservices data isolation. Intentional? | 1. Separate schemas per unit 2. DB per unit 3. Switch to Modular Monolith 4. Keep (acknowledge trade-off) |
| Event-Driven Without Broker | 🔴 High | comms=Event-driven/Mixed AND no Event Bus infra unit | Event-driven needs a broker. Add as infrastructure unit? | 1. Add Event Bus infra unit 2. Use cloud-managed broker (no dedicated unit) 3. Switch to REST |
| API Gateway Without Gateway Unit | 🟡 Medium | API=Gateway/Hybrid AND no Gateway infra unit | Gateway pattern needs a gateway service. Add as infrastructure unit? | 1. Add API Gateway infra unit 2. Use cloud-managed gateway (no dedicated unit) 3. Switch to Direct |
| BFF Without Frontend Diversity | 🟡 Medium | API=BFF AND single frontend type | BFF is most useful with multiple client types. Is this needed? | 1. Switch to API Gateway (simpler) 2. Keep BFF (anticipating mobile/admin later) 3. Switch to Direct |
| Multi-Repo with Heavy Shared Types | 🟡 Medium | repo=Multi-repo AND types=Shared package | Shared packages across repos need publishing/versioning. Manageable? | 1. Switch to monorepo (easier sharing) 2. Use code generation instead 3. Keep multi-repo + published packages |
| Solo Dev with Complex Infrastructure | 🟡 Medium | team=Solo AND infra units≥2 | Multiple infra units add operational overhead for a solo dev. | 1. Reduce to essential infra only 2. Use managed services instead 3. Keep (experienced with ops) |
| Manual Sync Multiple Teams | 🔴 High | team=Multiple teams AND types=Manual sync | Manual sync across teams leads to drift. Use automated approach? | 1. Shared package 2. Code generation 3. Keep manual (strong sync discipline) |
| Session Auth with Stateless Microservices | 🔴 High | auth=Session AND arch=Microservices | Session-based auth requires shared session store across all services. Token-based auth is standard for microservices. | 1. Switch to JWT/token-based auth 2. Use OAuth2 with token introspection 3. Add shared session store (Redis) 4. Keep session-based (single gateway handles sessions) |
| Event-Driven Without Idempotency | 🔴 High | comms=Event-driven/Mixed AND no idempotency mentioned | Event-driven systems deliver at-least-once. Without idempotency, duplicate events cause data corruption. | 1. Add idempotency keys to all event handlers 2. Use exactly-once delivery (Kafka transactions, SQS FIFO) 3. Design handlers to be naturally idempotent (upserts, conditional writes) 4. Accept at-least-once with manual dedup (low-volume) |
| Shared DB Microservices No Schema Isolation | 🔴 High | arch=Microservices AND DB=Shared AND no schema isolation | Shared database without schema isolation means any service can read/write any table, defeating microservices boundaries. | 1. Separate schemas per unit with cross-schema access rules 2. Database per unit (true isolation) 3. Shared DB with strict ORM-level access control 4. Switch to Modular Monolith |
| Multiple Frontends Without Shared UI | 🟡 Medium | frontend units≥2 AND shared UI=None | Multiple frontends without shared components lead to inconsistent UX and duplicated code. | 1. Create shared UI component library 2. Use common CSS framework/theme 3. Keep separate (frontends are very different) 4. Defer shared UI to after initial implementation |

**Context-Based Severity Adjustments**:
- Team Size: Solo → infra complexity HIGH; Multiple teams → coordination risks HIGH
- Architecture: Microservices → data isolation rules HIGH; Monolith → relaxed

Present conflicts grouped by severity, ask for resolution. User can skip validation.

After resolution, write decision summary to manifest `decisions.foundation` (compact key-value pairs from Decisions Summary section).

---

### Action: foundation-generation

Generate `{SPECS_DIR}/{feature}/foundation.md` using `{ASSETS_DIR}/foundation-core.md` template. If team size > 1, also load `{ASSETS_DIR}/foundation-team.md` for team-specific sections.

- Read decisions from manifest `decisions.foundation` section. Fall back to reading `## Decisions Summary` from DF file if manifest section is missing.
- Adapt content based on team size (skip Team Assignments, Sync Schedule, Risks for solo)

**Infrastructure Unit Management**:

1. Generate `foundation.md` from DF decisions
2. Read current `units.md`
3. Check DF decision for infrastructure unit strategy:

**IF combined** (single Foundation unit):
   - Add "Foundation" infrastructure unit to `units.md`
   - Type: infrastructure, Priority: foundation, Stories: none
   - Responsibilities: scaffold, shared packages, auth middleware, error handling, DB setup, dev tooling, CI/CD, PLUS identified infra components
   - Dependencies: none (all other units depend on this)
   - Write updated `units.md`

**IF separate** (individual infra units):
   - Add "Foundation" unit (scaffold, shared packages, dev tooling, CI/CD)
   - Add separate units per infra component (gateway, BFF, auth service, event bus)
   - Mark infra units depending on Foundation
   - Mark domain units depending on relevant infra units
   - Report which infrastructure units were added
   - Write updated `units.md`

4. Update Development Sequence in `units.md` — infrastructure units go in Phase 1

**Validate**:
- ✅ Repository structure defined with directory layout
- ✅ Auth approach defined with contract
- ✅ Error format defined with shared codes
- ✅ Inter-unit communication pattern defined
- ✅ Database strategy defined
- ✅ Shared types strategy defined
- ✅ Integration contracts sketched for all unit pairs
- ✅ Foundation/infrastructure units added to units.md
- ✅ No circular dependencies after adding infrastructure units

**Update Manifest**: Add `foundation` phase entry: `status: "draft"`, `timestamp`, `files: [foundation.md]`. Update `decomposition` phase entry to refresh `timestamp` (units.md was modified with infrastructure units). Update `steering.updatedBy.tech` to include `foundation`.

#### Update Steering

After generating `foundation.md`, update `{STEERING_DIR}/tech.md`:
- Add or update the **Shared Conventions** section with foundation decisions:
  - Authentication approach and contract
  - Error handling format and shared codes
  - Inter-unit communication pattern and conventions
  - Database strategy
  - Shared types strategy
  - Logging and observability approach
- Read current `tech.md` first, preserve existing content, append the Shared Conventions section

This ensures downstream skills (design, implement) that read `tech.md` for conventions have access to foundation decisions without needing to read `foundation.md` directly.

**Present**:

```
📍 Foundation Specification

- **Team**: [Solo / Small team / Multiple teams]
- **Repo**: [strategy]
- **Architecture**: [pattern]
- **Auth**: [approach]
- **Comms**: [pattern]
- **DB**: [strategy]
- **Infrastructure Units**: [list added]

Artifacts:
- `{SPECS_DIR}/{feature}/foundation.md`
- `{SPECS_DIR}/{feature}/units.md` (updated with infrastructure units)

---
🔲 **Your turn**:
- ✅ "approve" — approve foundation and select first unit
- ✏️ "change [what]" — request edits
```

**STOP and wait.**

---

### Action: foundation-edit

1. Read current foundation.md
2. Apply changes
3. If infrastructure units changed: update units.md accordingly
4. Re-validate: all sections defined, infra units match, no circular deps
5. Mark downstream artifacts as `outdated` in manifest (all unit designs and tasks — any that exist)
6. Present with `🔲 **Your turn**` block. **STOP.**

---

### Unit Selection (After Foundation Approved)

On approval: update manifest (`artifacts.foundation.status`: `"approved"`, add `"foundation"` to `state.sharedPhases`). Append audit entry. If platform is Claude Code, update `CLAUDE.md` (set Phase to "foundation").

```
📍 Foundation Approved — Select First Unit

Ready to design and implement units one at a time.

**Infrastructure units** (recommended first):
1. 🏗️ [Foundation] — project scaffold, shared packages, dev tooling
[2. 🏗️ [Gateway] — API routing, rate limiting (if separate)]

**Domain units**:
[3.] 📦 [Unit A] — [purpose] ([X] stories)
[4.] 📦 [Unit B] — [purpose] ([Y] stories)

💡 Infrastructure units should be completed before domain units.

---
🔲 **Your turn**:
- 🎯 "select [unit name]" — start working on that unit
- 📋 "show units" — see full unit details
```

**STOP and wait.**

When user selects a unit:
1. Update manifest: set `units[{unit}].status` to `"in-progress"`, set `units[{unit}].phase` to `"design"`
2. Auto-continue to design (see Skill Handoff)

When user returns after completing a unit:
1. Read manifest to check unit statuses
2. Present unit dashboard (active, available, completed units)
3. On selection: set `units[{unit}].status` to `"in-progress"`, set `units[{unit}].phase` to `"design"`
4. When all units complete → workflow done

---

## Skill Handoff

When the user selects a unit, auto-continue:

1. Read `{PLATFORM_DIR}/skills/aidlc-design/SKILL.md`
2. Follow its instructions — begin the design phase for the selected unit

If the file cannot be found:
```
👉 Next: Activate **aidlc-design** to create the design specification for this unit.
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

**Phase**: foundation
**Action**: {decision-gate | validation | generation | approval | edit}
**Artifacts**: {files created or modified}
**Outcome**: {result summary — e.g., "Monorepo, JWT auth, REST comms, shared DB with separate schemas, 2 infra units added"}
```
