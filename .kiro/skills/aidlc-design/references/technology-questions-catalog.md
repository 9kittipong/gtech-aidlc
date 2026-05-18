# Technology Questions Catalog

Reference catalog for D3 (Design Decisions). Load ONLY the sub-catalogs relevant to the project.

## Sub-Catalog Loading Rules

| Sub-Catalog | Load When |
|---|---|
| `tech-catalog-backend.md` | System has backend services (ALWAYS for most projects) |
| `tech-catalog-frontend.md` | System has web UI |
| `tech-catalog-mobile.md` | System has mobile app |
| `tech-catalog-infra.md` | Cloud-deployed with provisioned resources |
| `tech-catalog-distributed.md` | Architecture = microservices or distributed |
| `tech-catalog-nfr.md` | Production deployment, performance targets, or compliance |

Select 8-15 questions total based on project complexity.

## Example Question Format

```markdown
### D3-X: [Topic Name]
**Question**: [Specific question about this technology choice]
- 1) [Option 1] ([brief rationale]) **(Recommended)** [if applicable]
- 2) [Option 2] ([brief rationale])
- 3) [Option 3] ([brief rationale])
- 4) Other (please specify): _______

**Answer**: 
```

## Notes

- Architecture Pattern (monolith/microservices/serverless) is decided in D2, not D3
- Always include the Correctness & Property-Based Testing question (in backend catalog)
- Always include Repository Structure question (in backend catalog)
- Adapt questions to the specific project requirements
