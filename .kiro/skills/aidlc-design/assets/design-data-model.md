# Data Model Template

**Path**: `{SPECS_DIR}/{feature}/design/data-model.md`

Entities, relationships, and storage strategy.

```markdown
# Data Model

## Overview
**Database**: [PostgreSQL/MongoDB/DynamoDB/etc.]
**ORM/Client**: [Prisma/TypeORM/Mongoose/etc.]

---

## Entities

### [Entity 1 Name]

**Purpose**: [What this entity represents]

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| id | UUID | Yes | PK | Unique identifier |
| [field] | [type] | [Yes/No] | [constraints] | [description] |
| createdAt | Timestamp | Yes | Auto | Creation time |

**Relationships**:
- Has Many: `[RelatedEntity]` via `[foreign_key]`
- Belongs To: `[ParentEntity]` via `[foreign_key]`

**Indexes**:
- Unique: `[field]`
- Composite: `[field1, field2]` — [purpose]

**Business Rules**:
1. [Rule 1]
2. [Rule 2]

---

### [Entity 2 Name]

[Same structure]

---

## Entity Relationship Diagram

```
┌─────────────┐         ┌─────────────┐
│   Entity1   │         │   Entity2   │
├─────────────┤         ├─────────────┤
│ PK: id      │────1:N──│ FK: entity1 │
│     name    │         │     value   │
└─────────────┘         └─────────────┘
```

---

## Data Access Patterns

| Query | Frequency | Index Used |
|-------|-----------|------------|
| [Description] | [High/Medium/Low] | [Index name] |
```
