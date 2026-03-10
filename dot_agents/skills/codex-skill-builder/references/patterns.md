# Pattern selection

## Framing

### Problem-first

Use when users describe outcomes and expect the skill to orchestrate the right tools.

Encode:

- the desired result
- the step order
- data passed between steps
- validation points

### Tool-first

Use when users already have access to a tool or MCP server and need the best workflow.

Encode:

- when to choose the tool
- how to use it well
- common mistakes
- relevant conventions

## Common patterns

### Sequential workflow orchestration

Use when the work must happen in a fixed order.

Encode:

- numbered steps
- prerequisites for each step
- rollback or fallback behavior
- success criteria per stage

### Multi-service coordination

Use when the workflow spans multiple services or MCP servers.

Encode:

- phases by service
- artifacts handed from one phase to the next
- centralized error handling
- explicit transitions between phases

### Iterative refinement

Use when a first pass is expected to be incomplete and quality improves with rework.

Encode:

- first-draft step
- validation step
- issue list
- refinement loop
- stopping rule

### Context-aware tool selection

Use when the same user outcome maps to different tools depending on file type, scale, environment, or risk.

Encode:

- decision criteria
- preferred tool per case
- fallback option
- explanation of why a choice was made

### Domain-specific intelligence

Use when tool access alone is not enough and the skill must apply policy, compliance, brand, or business logic.

Encode:

- rules before action
- required checks
- audit trail or documentation expectations
- escalation paths
