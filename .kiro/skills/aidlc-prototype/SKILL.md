---
name: aidlc-prototype
description: Build a throwaway spike to validate requirements. Demonstrates core user flows with minimal code — no architecture, no tests, no production concerns.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, prototype, spike, validation, throwaway, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Prototype Skill

You build throwaway spikes to validate requirements. Write the minimum code needed to demonstrate core user flows — no architecture, no tests, no production concerns. Hardcoded data is fine. Ugly UI is fine. The goal is learning, not shipping.

When active:
1. Follow ONLY the process below
2. WAIT for user confirmation at each checkpoint
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-prototype v1.0.0 active — {platform} detected.
Ready to build a throwaway prototype to validate requirements.
```

Then proceed to initialization.

---

## Quick Start

1. Select top 3-5 highest-priority stories → present scope → wait for confirmation
2. Build minimal throwaway code in `.aidlc/prototype/{feature}/` — no architecture, no tests, hardcoded data
3. Report discoveries and suggested requirement changes
4. User chooses: update requirements / proceed to design / discard prototype

**Reads**: requirements.md (or inline stories), design resources
**Writes**: `.aidlc/prototype/{feature}/` (throwaway code + README)

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-prototype`
2. `.claude/` → Claude Code. `SPECS_DIR=.claude/specs`, `STEERING_DIR=.claude/steering`, `SKILL_DIR=.claude/skills/aidlc-prototype`
3. `.cursor/` → Cursor. `SPECS_DIR=.cursor/specs`, etc.
4. `.windsurf/` → Windsurf. `SPECS_DIR=.windsurf/specs`, etc.

Common: `WORKFLOW_DIR=.aidlc/workflow`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| User stories with priorities | What to prototype — stories describing core user experience | Markdown (requirements.md), YAML, JSON, CSV, plain text, inline |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Design resources | Figma links, design system docs, wireframes | Via MCP, URLs, file paths |

### Outputs
| Artifact | Default Path | Description |
|---|---|---|
| Prototype code | `.aidlc/prototype/{feature}/` | Throwaway code demonstrating core flows |
| README.md | `.aidlc/prototype/{feature}/README.md` | How to run, what's demonstrated, what's faked |

---

## Initialization

1. Detect environment (set SPECS_DIR, STEERING_DIR, SKILL_DIR, WORKFLOW_DIR)
2. Resolve feature name:
   - Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` for existing manifests
   - If exactly one manifest → use its `feature` field
   - If multiple manifests → present list, ask user which feature to work on
   - If no manifests → infer from `{SPECS_DIR}/` folders (if exactly one, use it; if multiple, list and ask; if none, ask user)
3. Read manifest if it exists — use artifact paths to locate requirements
4. Resolve requirements input:
   - Manifest artifact `requirements` → read files from `{SPECS_DIR}/{feature}/`
   - Conventional path `{SPECS_DIR}/{feature}/requirements.md`
   - User-provided path or inline content
   - If not found: ask user for stories (inline is fine)

---

## Process

### Action: prototype

#### Step 1: Gather Design Context

Check for available design resources:

1. Read `{STEERING_DIR}/resources.md` if it exists — check Design Resources section
2. For each available source, extract visual direction:
   - **Design tool** (Figma, etc.): If design tool MCP is available, read screens, component inventory, design tokens (colors, typography, spacing). Use these to style the prototype.
   - **Design system docs**: Read referenced docs → extract color palette, font stack, component naming, spacing scale. Apply to prototype UI.
   - **Wireframes/mockups**: Read referenced files → use as layout reference for prototype screens.
3. If no design resources exist → use a clean default (system fonts, neutral colors, simple layout). Note this in the prototype README.

The goal is not pixel-perfect fidelity — it's making the prototype feel like the real product so user feedback is about flows and features, not visual polish.

#### Step 2: Scope the Prototype

Read requirements. Select the top 3-5 highest-priority stories that represent the core user experience. Skip:
- Infrastructure stories (auth, deployment, monitoring)
- Edge cases and error handling
- Low-priority nice-to-haves

Present the selected stories to the user:

```
📍 Prototype Scope

I'll prototype these stories:
1. [Story ID]: [title] (Priority: High)
2. [Story ID]: [title] (Priority: High)
3. [Story ID]: [title] (Priority: High)
...

Skipping: [brief list of what's excluded and why]

{If design resources found: "Design context: Using [design system name / Figma components / color palette from docs]"}
{If no design resources: "No design resources found — using clean defaults."}

---
🔲 **Your turn**:
- ✅ "go" — build the prototype
- ✏️ "add [story]" or "remove [story]" — adjust scope
```

**STOP and wait for confirmation.**

#### Step 3: Build the Prototype

Implement the confirmed stories with these constraints:
- **No architecture**: Flat file structure, no layers, no patterns
- **No tests**: This code is throwaway
- **No real data layer**: In-memory arrays, JSON files, or hardcoded data
- **No auth**: Skip authentication/authorization entirely
- **No error handling**: Happy path only
- **Single entry point**: One file or minimal files to run
- **ALL code goes to `.aidlc/prototype/{feature}/`** — NEVER write to workspace root

**UI styling** (apply design context from Step 1):
- If design tokens available (from Figma/design system): Use the actual color palette, font stack, spacing scale, and border radius values. Import or inline them.
- If wireframes/mockups available: Follow the layout structure — header placement, navigation pattern, content areas, form layouts.
- If component library specified in design system: Use it directly (e.g., if design system says Material UI, install and use it).
- If no design resources: Use a lightweight CSS framework (e.g., Pico CSS, Simple.css) for clean defaults. Note "no design system specified" in README.

Include a `README.md` in the prototype directory with:
- How to run it (one command)
- What stories it demonstrates
- What's faked/hardcoded
- Design sources used (Figma URL, design system, or "none — using defaults")
- Known limitations

#### Step 4: Report Findings

After building, reflect on what was learned. Present:

```
📍 Prototype Complete

Stories demonstrated: [list]
Run command: [command]
Code location: .aidlc/prototype/{feature}/

## Discoveries
- [Finding 1]: [what was learned]
- [Finding 2]: [what was harder than expected]
- [Finding 3]: [what was missing from requirements]

## Suggested Requirement Changes
- [suggestion 1]
- [suggestion 2]

---
🔲 **Your turn**:
- ✏️ "update requirements" — apply discoveries
- ✅ "proceed" — continue to design
- ✅ "discard" — delete prototype
```

**STOP and wait.**

#### Step 5: Handle Response

- **"update requirements"**: Auto-apply the suggested changes to `{SPECS_DIR}/{feature}/requirements.md` as draft edits. Read the current file, apply changes (add/modify/remove stories based on discoveries), write the updated file. Then present the changes for user review:

```
📍 Requirements Updated (Draft)

Changes applied:
- [Added/Modified/Removed]: [story description]
- [Added/Modified/Removed]: [story description]

🔲 **Your turn**:
- ✅ "approve" — accept changes, continue to design
- ✏️ "change [what]" — adjust the edits
- ↩️ "revert" — undo changes, keep original requirements
```

  **STOP and wait.** On "approve": update manifest (`artifacts.requirements.timestamp`), mark downstream artifacts as `outdated` if they exist. Then auto-continue to the next phase. On "revert": restore the original requirements.md.

- **"proceed"**: The prototype stays for reference. Auto-continue: read the manifest to determine the routing recommendation (from the requirements phase), then read the appropriate next skill (`aidlc-decomposition` or `aidlc-design`) and follow its instructions.
- **"discard"**: Delete the `.aidlc/prototype/{feature}/` directory and all its contents. Confirm deletion. Then auto-continue same as "proceed".

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, audit, templates, platform detection, resource reads).
- Tools — Kiro: `fsWrite`, `readMultipleFiles`. Claude Code: `Write`/`Edit`, parallel `Read`. Cursor/Windsurf: `Write`/`Edit`, sequential reads.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.

### Manifest Rules
- Do NOT update `currentPhase` or `completedPhases` — the prototype is a side-quest, not a workflow phase.
- Do NOT create decision gates or task files for the prototype.
- Only append a single audit entry after completion:

```
### [{ISO timestamp}] Prototype: {feature}

**Phase**: prototype
**Action**: prototype
**Artifacts**: .aidlc/prototype/{feature}/
**Outcome**: Demonstrated [X] stories. Discoveries: [brief list].
```

Append to `{WORKFLOW_DIR}/{feature}/audit.md`. Create the file if it doesn't exist (header: `# Audit Trail — {feature}`).

### Prototype Boundaries
- Keep it minimal — if it takes more than 15-20 minutes of AI time, you're over-engineering.
- Prototype code is explicitly throwaway — it is NOT carried forward to implementation.
- ALL prototype code goes to `.aidlc/prototype/{feature}/` — never pollute the workspace.
- Do NOT create design documents, decision gates, or tasks for the prototype.
