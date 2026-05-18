# Components Template

**Path**: `{SPECS_DIR}/{feature}/design/components.md`

Component breakdown with responsibilities, interfaces, and interactions.

```markdown
# Components

## Overview
[Brief overview of component architecture and how components interact]

---

## [Component 1 Name]

**Purpose**: [What this component does and why it exists]

**Technology**: [Language/framework/key libraries]

**Responsibilities**:
- [Responsibility 1]
- [Responsibility 2]
- [Responsibility 3]

**Exposes**:
- `[method/endpoint]` — [Description]
- `[event-name]` — [When triggered, payload]

**Consumes**:
- `[Component/Service]` — [What it uses]
- `[event-name]` — [How it handles]

**Internal Structure**:
```
component-name/
  ├── controllers/     # [Purpose]
  ├── services/        # [Purpose]
  ├── models/          # [Purpose]
  └── tests/           # [Purpose]
```

**Key Decisions**:
1. [Decision]: [Rationale]

**Source**: [D3 decisions / Design tool: component name / Design system: token name / "Derived from requirements"]

**Error Handling**: [How this component handles errors]

---

## [Component 2 Name]

[Same structure]

---

## Component Interactions

```
[ASCII diagram showing how components interact]

┌──────────────┐         ┌──────────────┐
│ Component 1  │────────>│ Component 2  │
└──────────────┘         └──────────────┘
       │
       v
┌──────────────┐
│ Component 3  │
└──────────────┘
```

**Data Flow**: [Describe how data flows through the components]
```
