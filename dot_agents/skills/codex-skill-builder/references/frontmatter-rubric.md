# Frontmatter rubric

## Required shape

Use only this frontmatter in `SKILL.md`:

```yaml
---
name: your-skill-name
description: Explain what the skill does, when it should trigger, and any important boundaries.
---
```

## Rules

- `name` must be kebab-case and match the folder name.
- Use lowercase letters, digits, and hyphens only.
- `description` is the primary trigger mechanism.
- Put all trigger guidance in `description`, not only in the body.
- Aim to keep `description` concrete and reasonably compact. Under ~1024 characters is a good target.
- Add negative triggers when nearby skills or adjacent tasks make over-triggering likely.

## Description formula

Write descriptions in this order:

1. What the skill does
2. When to use it
3. Useful trigger phrases, file types, tools, or contexts
4. Optional "do not use" boundary

Template:

```text
[Primary job]. Use when the user wants to [task family], says things like "[trigger 1]" or "[trigger 2]", or when Codex needs to work with [file types/tools/context]. Do not use for [adjacent task].
```

## Good examples

```yaml
description: Create and revise Codex repo-local skills for release workflows. Use when the user asks to add a skill for changelog prep, release checks, or packaging a release checklist, or wants to improve a SKILL.md or agents/openai.yaml. Do not use for general release automation outside a Codex skill package.
```

```yaml
description: Review and update PDF-processing skills for Codex. Use when the user asks to create a PDF skill, improve trigger behavior, add bundled scripts for repeatable PDF operations, or validate a skill that works with .pdf files.
```

## Bad examples

```yaml
description: Helps with skills.
```

Too vague. It does not separate this skill from nearby skills.

```yaml
description: Implements a reusable skill packaging abstraction with metadata normalization.
```

Too tool-centric and too abstract. Users will not ask for it that way.

```yaml
description: Processes documents.
```

Too broad. It will over-trigger.

## Trigger checklist

Before finalizing, ask:

- Would a user naturally say one of the trigger phrases?
- Does the description distinguish this skill from adjacent skills?
- Does it mention file types or tools when those matter?
- Does it say enough to help Codex decide not to load the skill for unrelated tasks?
