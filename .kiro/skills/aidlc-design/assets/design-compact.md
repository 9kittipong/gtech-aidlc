# Compact Design Template

**Path**: `{SPECS_DIR}/{feature}/design.md`
**Use when**: Simple projects (≤10 user stories, single domain) — single file, no design/ folder

```markdown
# Design: [Feature Name]

## Summary
- **Architecture**: [Style] — [1-sentence rationale]
- **Stack**: [Frontend] / [Backend] / [Database]
- **Components**: [X] — [list names]
- **Entities**: [Y] — [list names]
- **Endpoints**: [Z] — [list key ones]

## Architecture

**Pattern**: [From D3]

```
[ASCII system context diagram]
```

---

## Components

### [Component Name]
- **Purpose**: [What it does]
- **Technology**: [From D3]
- **Responsibilities**: [Key responsibilities]
- **Exposes**: [APIs/events this component provides]
- **Consumes**: [APIs/events this component uses]

---

## Data Model

### [Entity Name]
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK | Unique identifier |
| [field] | [type] | [constraints] | [description] |

**Relationships**: [Entity relationships]
**Indexes**: [Key indexes beyond PK]

---

## API Specification

**API Conventions**: [Pagination approach], [rate limit], [versioning strategy]

### [METHOD] [path]
- **Description**: [What it does]
- **Auth**: [Required role or "Public"]
- **Request**: `{field: type}`
- **Response 200**: `{field: type}`
- **Errors**: 400 [reason], 401 [reason], 404 [reason]

---

## Integration Points

| External System | Protocol | Purpose | Error Handling |
|----------------|----------|---------|----------------|
| [System] | [REST/gRPC] | [Why] | [Retry/fallback strategy] |

---

## Implementation

### Directory Structure
```
[Planned directory layout]
```

### Dev Setup
```bash
[Setup commands]
```

### Conventions
- **Files**: [naming convention]
- **Code**: [architecture pattern — layered/clean/etc.]
- **Tests**: [framework and run command]

---

## Non-Functional Requirements
[If NFR questions answered in D3]

- **Performance**: [Targets]
- **Security**: [Approach]
- **Scalability**: [Strategy]

---

## Correctness Properties
[If PBT selected in D3]

| Property | Description | Validates |
|----------|-------------|-----------|
| [Name] | [What it verifies] | [US-XXX] |

---

## Traceability

| Requirement | Component | API | Data |
|-------------|-----------|-----|------|
| US-001 | [Component] | [Endpoint] | [Entity] |

---

## External References
[If external resources were used — otherwise omit this section]

| Source | Type | Used in |
|--------|------|---------|
| [URL or doc path] | [Design system / API spec / Documentation] | [Which section] |
```
