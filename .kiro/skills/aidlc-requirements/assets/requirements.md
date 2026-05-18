# Requirements — Output Template

Generate `{SPECS_DIR}/{feature}/requirements.md` with this structure.
All acceptance criteria MUST use EARS notation (see SKILL.md → EARS Notation Reference).

```markdown
# Requirements

## Summary
<!-- 10-line max. Downstream phases read ONLY this section. -->
- **Total Stories**: [X] across [Y] functional areas
- **Priority**: [X] High, [Y] Medium, [Z] Low
- **User Types**: [list]
- **Key Entities**: [list top 3-5 data entities mentioned]
- **Integrations**: [list external systems]
- **Core Flows**: [1-line per major user flow, max 5]

## Overview
User stories organized by functional area with EARS notation acceptance criteria.

---

## Functional Area 1: [Name]

### US-001: [Story Title]
**As a** [persona/user type]
**I want** [action/capability]
**So that** [benefit/value]

**Priority**: [High/Medium/Low]

**Acceptance Criteria**:
1. **WHEN** [trigger], **THEN** [expected behavior]
2. **IF** [condition], **THEN** [behavior], **ELSE** [alternative]
3. **WHILE** [state], **IF** [condition], **THEN** [behavior]

**Dependencies**: [Other stories or "None"]
**Source**: [D1 decisions / Design: screen name / API spec: endpoint / "User request"]

---

### US-002: [Story Title]

[Same structure]

---

## Functional Area 2: [Name]

### US-003: [Story Title]

[Same structure]

---

## Story Summary

| ID | Title | Area | Priority | Dependencies |
|----|-------|------|----------|--------------|
| US-001 | [Title] | [Area] | High | None |
| US-002 | [Title] | [Area] | High | US-001 |

---

## Story-Persona Matrix

[If personas exist]

| Story | [Persona 1] | [Persona 2] | [Persona 3] |
|-------|-------------|-------------|-------------|
| US-001 | ✓ Primary | — | ✓ Secondary |
| US-002 | — | ✓ Primary | — |

---

## Non-Functional Considerations

[Brief notes on cross-cutting concerns — detailed in NFR phase]
- Performance expectations
- Security requirements
- Scalability needs

---

## External References
[If external resources were used — otherwise omit]

| Source | Stories Derived | What was used |
|--------|----------------|---------------|
| [URL or doc path] | [US-001, US-003] | [Screen name, flow, or component] |
```
