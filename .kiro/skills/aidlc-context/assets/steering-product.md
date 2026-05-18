# Steering: Product — Output Template

Generate `{STEERING_DIR}/product.md` with this structure.

**Kiro only**: Add `inclusion: always` YAML front-matter.
**Progressive enrichment**: Phase 1 creates, Phase 2 updates Target Users and Key Features.
**Brownfield**: Populate from codebase analysis + user's request.
**Greenfield**: Populate from user's request. Mark unknowns as "To be defined during requirements."

```markdown
# Product Context

## Summary
<!-- 3-line max -->
- **Product**: [1-sentence description]
- **Users**: [user type list]
- **Type**: [Greenfield/Brownfield] — [Scope]

## Overview

[One paragraph describing the product/feature — from user's request]

## Problem Statement

[What problem this solves — why it's being built. What's the current pain point or gap?]

## Target Users

- [User type 1]: [Brief description and primary goal]
- [User type 2]: [Brief description and primary goal]

## Key Features

- [Feature area 1]: [Brief description]
- [Feature area 2]: [Brief description]

## Domain Language

Key terms used in this project. The AI should use these terms consistently throughout all artifacts.

| Term | Definition | Example |
|------|-----------|---------|
| [Domain term 1] | [What it means in this context] | [Usage example] |
| [Domain term 2] | [Definition] | [Example] |

[Brownfield: Extract from existing code — class names, module names, database table names that represent domain concepts.]
[Greenfield: Extract from user's request and problem statement. Expand during requirements phase.]

## Success Criteria

How we know this feature/product is successful:

- [Metric 1]: [Target — e.g., "User can complete checkout in under 3 steps"]
- [Metric 2]: [Target — e.g., "Reduce support tickets for password reset by 50%"]

[If unknown: "To be defined during requirements phase."]

## Constraints & Assumptions

**Constraints** (hard limits that shape decisions):
- [Timeline: e.g., "Must ship by Q3 2026"]
- [Budget: e.g., "No paid third-party services" or "AWS only"]
- [Regulatory: e.g., "Must comply with GDPR" or "None identified"]
- [Technical: e.g., "Must integrate with existing auth system" or "Must support IE11"]

**Assumptions** (things we believe to be true but haven't verified):
- [e.g., "Users have modern browsers", "API rate limits won't be an issue"]

[Brownfield: Include constraints from existing system — "Must not break existing API contracts", "Database schema changes require migration".]

## Existing User Journeys
[Brownfield only — omit for greenfield]

How users currently accomplish the task this feature addresses:

- **Current flow**: [Step 1] → [Step 2] → [Step 3]
- **Pain points**: [What's slow, confusing, or broken]
- **Workarounds**: [What users do to get around the pain]

## Project Type

- **Type**: [Greenfield / Brownfield]
- **Scope**: [New product / New feature / Enhancement / Cross-cutting change]
```
