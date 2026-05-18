# Decision Gate Template

**Path**: `{WORKFLOW_DIR}/{feature}/decisions-*.md` (always `.aidlc/workflow/`)

Pure template structure for all decision files (D1, D2, D3, D4).

**Question Guidelines** (for the AI generating questions):
- Be specific and contextual — not "What database?" but "What database for user data and orders?"
- Offer 3-4 options with brief pros/cons, mark recommended, include "Other"
- One decision per question — ask about the system, not documentation

```markdown
# [Phase] Decisions

## Context Summary
[Auto-populated from previous phases - key information that informs decisions]

---

## Decision Questions

### D[N]-1: [Question Title]
**Question**: [Clear, specific question about the feature/system]
- 1) [Option 1 with brief explanation]
- 2) [Option 2 with brief explanation] **(Recommended)**
- 3) [Option 3 with brief explanation]
- 4) Other (please specify): _______

**Answer**: 

---

### D[N]-2: [Question Title]
**Question**: [Clear, specific question]
- 1) [Option 1]
- 2) [Option 2] **(Recommended)**
- 3) [Option 3]
- 4) Other (please specify): _______

**Answer**: 

---

[Continue with additional questions - adapt count to project complexity]

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D[N]-1 [Short Label]: [User's answer]
- D[N]-2 [Short Label]: [User's answer]
- ...

---

**Instructions**: Fill in your answers above and respond with "[phase] decisions complete"
```
