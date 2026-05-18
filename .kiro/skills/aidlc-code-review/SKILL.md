---
name: aidlc-code-review
description: Review implemented code against design specs, coding standards, and best practices. Checks for correctness, security, performance, test coverage, and design compliance. Produces a severity-classified review report.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: code-review, quality, security, testing, compliance, standards, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Code Review Skill

You review implemented code with a critical eye. Check that implementation matches design specs, follows coding standards, handles errors properly, has adequate test coverage, and avoids common security pitfalls. Be thorough but pragmatic — flag what matters, not what's pedantic.

When active:
1. Follow ONLY the process below
2. Be specific — cite file paths, line ranges, and code snippets
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-code-review v1.0.0 active — {platform} detected.
Ready to review code against design specs and best practices.
```

---

## Quick Start

1. Determine scope: full review / scoped (specific paths) / diff / task-specific
2. Read source code + optional design docs, foundation, tasks
3. Check: design compliance, correctness, security, error handling, performance, test quality, code quality
4. Classify findings (🔴 Critical, 🟡 Major, 🟢 Minor, 💡 Suggestion)
5. Generate report → offer to apply fixes

**Reads**: Source code, optionally: design docs, foundation.md, tasks.md, git diff
**Writes**: code-review.md

---

## Environment Detection

1. `.kiro/` → Kiro. `SPECS_DIR=.kiro/specs`, `STEERING_DIR=.kiro/steering`, `SKILL_DIR=.kiro/skills/aidlc-code-review`
2. `.claude/` → Claude Code. `SPECS_DIR=.claude/specs`, etc.
3. `.cursor/` → Cursor. `SPECS_DIR=.cursor/specs`, etc.
4. `.windsurf/` → Windsurf. `SPECS_DIR=.windsurf/specs`, etc.

Common: `WORKFLOW_DIR=.aidlc/workflow`

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Source code | Files to review | Any source files in the workspace |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Design documents | Architecture and implementation specs to check compliance against | Markdown (design.md + design/*), YAML, JSON, OpenAPI |
| Tasks | Task list to verify coverage | Markdown (tasks.md), YAML, JSON |
| Foundation conventions | Shared coding standards | Markdown (foundation.md), YAML, JSON |
| Git diff | Changes to review (instead of full codebase) | Git diff output, PR diff |
| Specific files/folders | Scope the review to particular paths | User-specified paths |

### Outputs
| Artifact | Default Path |
|---|---|
| code-review.md | `{WORKFLOW_DIR}/{feature}/code-review.md` |

---

## Initialization

1. Detect environment
2. Resolve feature name:
   - Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` for existing manifests
   - If exactly one manifest → use its `feature` field
   - If multiple manifests → present list, ask user which feature to work on
   - If no manifests → infer from `{SPECS_DIR}/` folders (if exactly one, use it; if multiple, list and ask; if none, ask user)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Determine review scope:
   - **Full review**: user says "review the code" → scan all source files referenced by design/implementation.md
   - **Scoped review**: user says "review src/auth/" → review only specified paths
   - **Diff review**: user says "review my changes" or "review this PR" → review only changed files (use git diff or #Git Diff context)
   - **Task review**: user says "review task 2.3" → review files changed by that specific task
5. Resolve optional inputs: design docs, tasks, foundation from manifest or conventional paths

---

## Process

### Action: review-code

#### Step 1: Gather Context

Read available context to inform the review:

- **Design documents** (if available): understand intended architecture, components, data model, API contracts, implementation conventions
- **Foundation conventions** (if available): coding standards, naming patterns, error handling format, shared types strategy
- **Tasks** (if available): understand what was supposed to be implemented, check completeness
- **Tech stack** from `{STEERING_DIR}/tech.md` (if available): know the expected frameworks, libraries, patterns

If no design docs available, review against general best practices only.

#### Step 2: Read Source Code

Based on the determined scope:
- **Full review**: read source files following the directory structure from design/implementation.md. Prioritize: entry points, API routes, data models, business logic, middleware, tests.
- **Scoped review**: read all files in the specified paths
- **Diff review**: read only changed files
- **Task review**: read files listed in the task's implementation details

For large codebases, prioritize:
1. Entry points and API handlers
2. Business logic and domain models
3. Data access and database interactions
4. Authentication and authorization
5. Error handling and validation
6. Tests
7. Configuration and infrastructure

#### Step 3: Review Categories

Check each category. Skip categories that don't apply to the reviewed code.

**Design Compliance** (if design docs available):
- Does the implementation match the component structure from design/components.md?
- Do data models match design/data-model.md? (field names, types, relationships, indexes)
- Do API endpoints match design/api-spec.md? (paths, methods, request/response schemas, error codes)
- Does the directory structure match design/implementation.md?
- Are integration patterns consistent with design/integration.md?
- Are technology choices consistent with D3 decisions? (no unauthorized libraries or frameworks)

**Correctness**:
- Logic errors (off-by-one, null handling, race conditions)
- Edge cases not handled (empty arrays, missing fields, boundary values)
- Async/await correctness (missing awaits, unhandled promise rejections)
- State management issues (stale state, mutation of shared state)
- Data validation (input validation present, output sanitization)

**Security**:
- SQL injection (parameterized queries used?)
- XSS (output encoding, content security policy)
- Authentication bypass (all protected routes check auth?)
- Authorization gaps (role checks on sensitive operations?)
- Secret handling (no hardcoded secrets, env vars used properly?)
- Input validation (size limits, type checking, sanitization)
- CORS configuration (not wildcard in production)
- Rate limiting on sensitive endpoints
- Dependency vulnerabilities (known CVEs in dependencies)

**Error Handling**:
- All async operations have error handling
- Errors are logged with context (request ID, user ID, operation)
- User-facing errors don't leak internal details
- Error responses follow the agreed format (from foundation.md or design)
- Graceful degradation for external service failures
- Retry logic where appropriate (with backoff, not infinite)

**Performance**:
- N+1 query patterns (database calls in loops)
- Missing database indexes for common queries
- Unbounded queries (no pagination, no limits)
- Memory leaks (event listeners not cleaned up, growing caches)
- Unnecessary re-renders (frontend) or recomputation
- Large payloads without compression or streaming

**Test Quality**:
- Test coverage: are critical paths tested?
- Test isolation: do tests depend on each other or external state?
- Assertion quality: are tests checking the right things? (not just "no error thrown")
- Edge cases: are boundary conditions tested?
- Mocking: are external dependencies properly mocked?
- Test naming: do test names describe the behavior being tested?
- Missing tests: which components/endpoints/flows have no tests?

**Code Quality**:
- Naming clarity (variables, functions, files)
- Function size (functions doing too many things)
- Duplication (copy-pasted logic that should be extracted)
- Dead code (unused imports, unreachable branches, commented-out code)
- Consistent patterns (same problem solved differently in different places)
- Documentation (complex logic explained, public APIs documented)
- Type safety (proper TypeScript types, no `any` abuse, no unsafe casts)

**Convention Compliance** (if foundation.md available):
- Naming conventions followed
- Error format matches agreed standard
- Logging format matches agreed standard
- File organization matches agreed structure
- Shared types used (not redefined locally)

#### Step 4: Classify Findings

For each finding:

- 🔴 **Critical**: Bug, security vulnerability, data loss risk, or design violation that would cause production issues. Must fix.
- 🟡 **Major**: Significant quality issue, missing error handling, inadequate test coverage, or performance problem. Should fix.
- 🟢 **Minor**: Style issue, naming improvement, minor optimization, documentation gap. Nice to fix.
- 💡 **Suggestion**: Not a problem, but a better approach exists. Optional.

#### Step 5: Generate Report

Write `{WORKFLOW_DIR}/{feature}/code-review.md`:

```markdown
# Code Review — {feature}

## Review Summary

- **Date**: {ISO timestamp}
- **Scope**: {Full / Scoped: paths / Diff / Task: ID}
- **Files Reviewed**: {count}
- **Findings**: {X} critical, {Y} major, {Z} minor, {W} suggestions
- **Design Compliance**: {Compliant / Partially Compliant / Non-Compliant} (if design docs available)
- **Test Coverage Assessment**: {Adequate / Gaps Identified / Insufficient}

## Findings

### 🔴 Critical

#### CR-1: {Title}
**File**: `{path}` (lines {start}-{end})
**Category**: {Security / Correctness / Design Compliance}
**Description**: {What's wrong}
**Code**:
```{language}
{problematic code snippet}
```
**Fix**:
```{language}
{suggested fix}
```
**Impact**: {What could go wrong}

---

### 🟡 Major

#### MJ-1: {Title}
[Same structure]

---

### 🟢 Minor

#### MN-1: {Title}
[Same structure — code snippets optional for minor issues]

---

### 💡 Suggestions

#### SG-1: {Title}
**File**: `{path}`
**Description**: {Better approach}
**Rationale**: {Why it's better}

---

## Design Compliance Summary
[If design docs available]

| Design Artifact | Status | Notes |
|---|---|---|
| Components (design/components.md) | ✅ Compliant / ⚠️ Deviations | {brief notes} |
| Data Model (design/data-model.md) | ✅ / ⚠️ | {notes} |
| API Spec (design/api-spec.md) | ✅ / ⚠️ | {notes} |
| Integration (design/integration.md) | ✅ / ⚠️ | {notes} |
| Implementation (design/implementation.md) | ✅ / ⚠️ | {notes} |

## Test Coverage Summary

| Area | Tests Exist | Coverage Assessment |
|---|---|---|
| {Component/Module} | ✅ / ❌ | {Adequate / Gaps: what's missing} |

## Missing Tests
- {Component X}: no unit tests for {specific logic}
- {Endpoint Y}: no integration test for error cases
- {Flow Z}: no E2E test

## Recommendations

### Must Fix (Before Merge/Deploy)
1. {CR-1}: {one-line summary}

### Should Fix (Before Next Release)
1. {MJ-1}: {one-line summary}

### Consider
1. {SG-1}: {one-line summary}
```

#### Step 6: Present Results

```
📍 Code Review Complete

- **Files Reviewed**: {count}
- **Critical**: {X} issues
- **Major**: {Y} issues
- **Minor**: {Z} issues
- **Suggestions**: {W}
- **Design Compliance**: {status}
- **Test Coverage**: {status}

Report at `{WORKFLOW_DIR}/{feature}/code-review.md`.

{If critical issues:}
⚠️ Critical issues found:
- CR-1: {brief} — `{file}`
- CR-2: {brief} — `{file}`

---
🔲 **Your turn**:
- 🔧 "fix CR-1" — apply the suggested fix
- 🔧 "fix all critical" — apply all critical fixes
- 🔧 "fix all" — apply all suggested fixes (critical + major + minor)
- ✅ "done" — acknowledge review
- 🔍 "re-review" — run again after fixes
```

**STOP and wait.**

### Action: apply-fixes

When user says "fix [issue]" or "fix all":

1. For each fix to apply:
   - Read the current file
   - Apply the suggested change from the review report
   - Verify the fix doesn't break existing tests (run test suite)
2. After applying fixes:
   - Re-run the review on changed files only (quick re-check)
   - Present: files changed, tests passing, remaining issues
3. If "fix all": apply in order — critical first, then major, then minor. Stop if a fix breaks tests.

---

## Standalone Usage (Outside AIDLC Workflow)

Works without the AIDLC manifest or workflow:

```
"Review the code in src/"
"Review my recent changes"
"Review src/auth/ against our security standards"
```

Without design docs, the review focuses on general best practices: correctness, security, error handling, performance, test quality, code quality.

With design docs (user provides paths), it also checks design compliance.

---

## Behavioral Rules

### Rules
- Language: user's language for content, English for paths/code/tech terms. Silent on internal operations (manifest, file scanning, path resolution, platform detection).
- Tools — Kiro: `readMultipleFiles`, `readCode`, `fsWrite`. Claude Code: parallel `Read`, `Write`. Cursor/Windsurf: sequential reads, `Write`.
- Recovery: read `{STEERING_DIR}/aidlc-workflow.md` → manifest → SKILL.md → resume from current action.

### Review Principles
- Be specific — cite exact files, line numbers, and code snippets
- Be actionable — every finding has a suggested fix or clear next step
- Be proportional — don't flag 50 minor style issues when there are 3 critical bugs
- Be honest — if code is good, say so. Don't manufacture issues.
- Prioritize: security > correctness > design compliance > performance > test coverage > code quality > style

### Audit Trail
Append to `{WORKFLOW_DIR}/{feature}/audit.md` after review:

```
### [{ISO timestamp}] Code Review: {scope}

**Phase**: code-review
**Action**: Reviewed {X} files ({scope})
**Artifacts**: {WORKFLOW_DIR}/{feature}/code-review.md
**Outcome**: {X} critical, {Y} major, {Z} minor, {W} suggestions. Design compliance: {status}.
```

### Error Recovery
- **No source files found**: Report "No source files found at the specified paths. Check the paths or specify different ones."
- **Design docs not found**: Proceed with general best practices review. Note: "No design docs available — reviewing against general best practices only."
- **Large codebase**: If too many files to review in one pass, prioritize critical paths (entry points, auth, data access) and report: "Reviewed {X} of {Y} files. Priority areas covered. Run scoped reviews for remaining areas."
