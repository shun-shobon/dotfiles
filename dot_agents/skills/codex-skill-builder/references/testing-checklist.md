# Testing checklist

## Define success first

Use a small set of must-pass checks:

- outcome: did the task complete?
- process: did Codex invoke the skill and follow the intended steps?
- style: does the output follow the conventions in the skill?
- efficiency: did it avoid thrashing or unnecessary commands?

## Start narrow

Before broad coverage, iterate on one challenging request until the skill works well. Then expand to more prompts and edge cases.

## Triggering tests

Prepare at least three kinds of prompts:

### Should trigger

- obvious request
- paraphrased request
- file- or tool-specific request

### Should not trigger

- unrelated request
- adjacent request that belongs to another skill
- generic request that is broader than this skill's scope

## Functional tests

Check at least:

- correct files are created or edited
- scripts run successfully if included
- references are sufficient for the task
- error handling and fallback guidance are usable
- final output matches the skill's definition of done

## Baseline comparison

Compare one task with and without the skill.

Look for:

- fewer corrections
- fewer failed commands or API calls
- less back-and-forth
- more consistent structure

## Early testing posture

Early in development, trigger the skill explicitly and watch where it breaks. This surfaces hidden assumptions before you rely on implicit invocation.

## Iteration signals

### Under-triggering

Symptoms:

- skill does not load on obvious tasks
- users must explicitly invoke it often

Fixes:

- make `description` more concrete
- add phrases users actually say
- mention relevant files, tools, or contexts

### Over-triggering

Symptoms:

- skill loads for unrelated requests
- scope feels fuzzy

Fixes:

- narrow `description`
- add negative triggers
- split overloaded skills
