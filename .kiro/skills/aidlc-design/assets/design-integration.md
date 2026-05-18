# Integration Template

**Path**: `{SPECS_DIR}/{feature}/design/integration.md`

```markdown
# Integration Specifications

## Overview
[Brief overview of integration strategy]

---

## External Integrations

### [Service Name]

**Purpose**: [Why this integration is needed]
**Type**: [REST API/GraphQL/gRPC/Message Queue]
**Auth**: [API Key/OAuth/JWT] — stored in [Secrets Manager/Vault]

**Key Endpoints**:
- `[METHOD] [URL]` — [Purpose]
- `[METHOD] [URL]` — [Purpose]

**Error Handling**:
- Retry: [Strategy — e.g., "Exponential backoff, 3 attempts"]
- Timeout: [Duration]
- Fallback: [What happens when unavailable]

---

## Inter-Unit Communication

[For systems with multiple units or components that communicate asynchronously — skip if single unit with no async]

**Pattern**: [Synchronous REST / Async events / Mixed]
**Transport**: [Message broker/event bus technology — e.g., SQS, Kafka, EventBridge, RabbitMQ]

### Synchronous Contracts

[If units communicate via REST/gRPC]

#### [Unit A] → [Unit B]: [Purpose]
- **Method**: [REST/gRPC]
- **Endpoint**: `[METHOD] [path]`
- **Request**: `{field: type}`
- **Response**: `{field: type}`

---

### Domain Events

[Event catalog — each event that flows between components/units]

#### [domain].[entity].[action]

**Producer**: [Component/Unit that publishes]
**Consumers**: [Components/Units that subscribe and what they do]
**Trigger**: [When this event is emitted]

**Schema**: `{ eventId, eventType, timestamp, version, payload: { ... } }`

#### [domain].[entity].[action]

[Same structure for each event]

---

### Message Infrastructure

[If using message queues/event bus]

| Queue/Topic | Purpose | Producers | Consumers | DLQ | Retry Policy |
|-------------|---------|-----------|-----------|-----|-------------|
| [name] | [purpose] | [services] | [services] | [Yes/No] | [policy] |

**Message Format**: [JSON/Protobuf/Avro]
**Ordering**: [FIFO/Best-effort]
**Deduplication**: [Strategy — idempotency keys, message IDs]

---

## Integration Testing

**Strategy**: [How integrations are tested]
**Mocking**: [Which services are mocked in dev/test]
**Contract Testing**: [Tool — e.g., "Pact"] (if applicable)
```
