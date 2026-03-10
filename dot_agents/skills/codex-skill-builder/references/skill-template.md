# Skill template

## Folder shape

```text
your-skill-name/
├── SKILL.md
├── agents/
│   └── openai.yaml          # optional
├── references/             # optional
├── scripts/                # optional
└── assets/                 # optional
```

## Minimal `SKILL.md`

```md
---
name: your-skill-name
description: [What the skill does]. Use when the user wants to [job], says things like "[trigger 1]" or "[trigger 2]", or when Codex needs to work with [files/tools/context]. Do not use for [adjacent task].
---

# Skill title

## Default posture

- State the scope in one or two bullets.
- State whether this should stay instruction-only or use scripts and why.

## Workflow

### 1. Understand input

- What inputs must exist?
- What should Codex inspect first?

### 2. Execute

- Ordered steps with explicit inputs and outputs
- Validation checkpoints for fragile steps

### 3. Finalize

- Definition of done
- Cleanup rules
- What files should exist at the end?

## References

- `references/...` for long docs or examples
```

## Minimal `agents/openai.yaml`

```yaml
interface:
  display_name: "Your Skill Name"
  short_description: "Short user-facing description."
  default_prompt: |
    Help me use this skill for ...
```

## Add a validator when useful

If the skill creates or edits structured files repeatedly, add a small validator script to catch common issues deterministically.
