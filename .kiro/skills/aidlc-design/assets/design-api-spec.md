# API Specification Template

**Path**: `{SPECS_DIR}/{feature}/design/api-spec.md`

```markdown
# API Specification

## Overview
**API Style**: [REST/GraphQL/gRPC]
**Base URL**: `https://api.example.com/v1`
**Auth**: [JWT/OAuth 2.0/API Keys] via `Authorization: Bearer <token>`

## API Conventions
- **Pagination**: [Cursor-based/Offset-based] — `?page=1&limit=20`
- **Filtering**: `?filter[field]=value`
- **Sorting**: `?sort=field:desc`
- **Rate Limit**: [X requests/minute authenticated, Y unauthenticated]
- **Versioning**: [URL-based `/api/v1/`]

## Error Format
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": [{"field": "fieldName", "message": "Error"}]
  }
}
```

---

## Endpoints

### [Resource Group 1]

#### [METHOD] /api/v1/[resource]
- **Description**: [What it does]
- **Auth**: [Required role or "Public"]
- **Source**: [D3 decisions / OpenAPI spec: operation ID / "Derived from requirements"]
- **Request**:
```json
{"field1": "string", "field2": 123}
```
- **Response 200**:
```json
{"id": "uuid", "field1": "string", "createdAt": "ISO-8601"}
```
- **Errors**: 400 Invalid request, 401 Unauthorized, 404 Not found

#### [METHOD] /api/v1/[resource]/{id}
- **Description**: [What it does]
- **Auth**: [Required role]
- **Response 200**:
```json
{"id": "uuid", "field1": "string"}
```
- **Errors**: 401 Unauthorized, 404 Not found

---

### [Resource Group 2]

[Same structure]
```
