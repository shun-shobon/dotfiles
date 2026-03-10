---
name: codex-skill-builder
description: Design, draft, review, and refine Codex agent skills that follow current Codex conventions and the open Agent Skills format. Use when the user wants to create a new skill, update an existing SKILL.md, improve a skill's trigger description, decide whether to add scripts/references/assets, add agents/openai.yaml, or validate and test a skill package before installing it. Common triggers include "create a Codex skill", "make a skill", and "improve this SKILL.md".
---

# Codex Skill Builder

Build skills that are narrow, composable, reliable to trigger, and cheap to load.

## Default posture

- Start from concrete use cases and trigger phrases, not from file layout.
- Prefer instruction-only skills. Add `scripts/` only when deterministic behavior or repeated code materially improves reliability.
- Keep `SKILL.md` focused on workflow, guardrails, and navigation. Move detailed docs, schemas, and large examples to `references/`.
- Use only `name` and `description` in `SKILL.md` frontmatter. Put UI metadata, invocation policy, and dependencies in `agents/openai.yaml`.
- Avoid restating basics Codex already knows. Keep only the information another Codex instance would genuinely need.

## Authoring workflow

### 1. Understand the job

- Capture 2-5 concrete requests that should trigger the skill.
- Capture near-miss requests that should not trigger it.
- Decide whether the skill is problem-first or tool-first. See `references/patterns.md`.
- If an existing skill is provided, inspect current `SKILL.md`, `agents/openai.yaml`, `scripts/`, `references/`, and `assets/` before restructuring anything.

### 2. Define success

- Write a small set of must-pass checks across outcome, process, style, and efficiency.
- At minimum, prepare:
  - trigger tests
  - functional tests
  - one baseline comparison against working without the skill
- See `references/testing-checklist.md`.

### 3. Plan the package

- Required: `SKILL.md`
- Optional: `references/`, `scripts/`, `assets/`, `agents/openai.yaml`
- Do not add `README.md`, changelog files, installation guides, or other human-only docs inside the skill folder.
- Keep one job per skill. Split overloaded skills rather than hiding multiple products in one description.

### 4. Write frontmatter first

- Choose a short kebab-case name that matches the folder.
- Write a description that:
  - says what the skill does
  - says when it should trigger using phrases users would actually say
  - mentions relevant file types, tools, or contexts
  - adds negative triggers or boundaries when over-triggering is likely
- Put all trigger logic in `description`; do not rely on a "When to use" section in the body.
- See `references/frontmatter-rubric.md`.

### 5. Write the body

- Use imperative steps with explicit inputs, outputs, ordering, and stop conditions.
- For fragile sequences, include validation checkpoints and rollback or fallback instructions.
- Reference bundled files explicitly:
  - use `references/...` for detailed documentation, schemas, long examples, and policies
  - use `scripts/...` for deterministic helpers
  - use `assets/...` only for files copied into outputs or used by generated artifacts
- Prefer concise examples over long narrative explanation.
- If quality improves through iteration, include a refinement loop with a clear exit condition.
- Keep `SKILL.md` lean. Prefer staying under roughly 500 lines and keep references one level deep from `SKILL.md`.
- For longer reference files, add a short table of contents near the top.

### 6. Add `agents/openai.yaml` when useful

- Add user-facing metadata in `agents/openai.yaml`.
- Consider `policy.allow_implicit_invocation: false` for narrow skills that would otherwise trigger too often.
- Declare MCP or tool dependencies there when they materially improve installation and use.
- See `references/workflow-checklist.md` for a minimal example.

### 7. Validate and test

- Run `python scripts/validate_skill.py <skill-folder>` when the validator exists.
- Then manually check:
  - obvious trigger prompts
  - paraphrased trigger prompts
  - should-not-trigger prompts
  - one realistic end-to-end run
  - the quality of the final files
- If the skill under-triggers, improve the description with concrete language and user phrasing.
- If it over-triggers, narrow the description and add negative triggers.

### 8. Deliver

- Return only the files that belong in the final skill.
- Default repo-local output path: `.agents/skills/<skill-name>/`
- Use user-level placement only when the skill should apply across repositories.

## Review mode

When the user asks to review or improve an existing skill:

1. Read the current skill files before proposing structure changes.
2. Preserve working behavior unless there is a clear triggering, scope, or reliability problem.
3. Prioritize fixes in this order:
   - name and description quality
   - scope clarity
   - missing validation or error handling
   - poor reference organization
   - unnecessary files or duplicated guidance
4. Return a concise diagnosis plus the concrete file edits.

## Required output for new skills

- `SKILL.md`
- test prompts
- any required bundled files
- optional `agents/openai.yaml`

## Reference guide

- `references/skill-template.md`
- `references/frontmatter-rubric.md`
- `references/workflow-checklist.md`
- `references/patterns.md`
- `references/testing-checklist.md`
