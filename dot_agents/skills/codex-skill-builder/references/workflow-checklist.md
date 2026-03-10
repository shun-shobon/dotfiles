# Workflow checklist

## Creation flow

1. Capture concrete requests that should trigger the skill.
2. Capture near-miss requests that should not trigger it.
3. Decide the scope: one skill, one job.
4. Decide the output scope:
   - repo-local: `.agents/skills/<skill-name>/`
   - user-level: `$HOME/.agents/skills/<skill-name>/`
5. Choose the package contents:
   - `SKILL.md` is always required
   - `references/` for long docs, schemas, examples, policies
   - `scripts/` for deterministic helpers
   - `assets/` for files copied or used in outputs
   - `agents/openai.yaml` for UI metadata, policy, and dependencies
6. Write `name` and `description` first.
7. Write the body in imperative, ordered steps.
8. Add test prompts and validation guidance.
9. Remove unnecessary files.

## Degree of freedom

Use plain instructions when the task has multiple valid approaches.

Add scripts when:
- the same code would otherwise be rewritten repeatedly
- a validator or transformer should behave deterministically
- the sequence is fragile enough that free-form code generation is wasteful

Add assets when Codex needs starter files, templates, icons, or boilerplate to copy or adapt.

## `agents/openai.yaml` example

```yaml
interface:
  display_name: "Skill Name"
  short_description: "Short user-facing summary."
  default_prompt: |
    Help me use this skill for ...
policy:
  allow_implicit_invocation: false
dependencies:
  tools:
    - type: "mcp"
      value: "someServer"
      description: "Optional MCP server"
```

Notes:

- `allow_implicit_invocation: false` is useful for narrow skills that are easy to trigger accidentally.
- Put UI metadata and dependencies here, not in `SKILL.md` frontmatter.
- Only declare dependencies that materially affect usability.

## Existing-skill edits

When updating an existing skill:

- inspect all current files first
- preserve working parts
- delete stale placeholder files
- remove duplicated guidance between `SKILL.md` and `references/`
