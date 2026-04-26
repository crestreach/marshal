---
name: marshal-code-archaeologist
description: Fresh-context recon subagent for MARSHAL stage 3. Reads the change brief plus existing knowledge, narrows the repo surface, and returns a draft repo-recon.md plus an unknowns list.
---

# marshal-code-archaeologist

**Draft — v2 subagent.** Not yet implemented; structure only.

## Purpose

Run MARSHAL stage 3 (Analysis) in isolation. Produces a tight
`repo-recon.md` so the caller's context is not loaded with intermediate
exploration details.

## When to invoke

- After stage 2 (Intake), once `change-brief.md` exists.
- Whenever recon needs to be redone (e.g. brief changed materially).

## Inputs

- `change-brief.md`.
- `.marshal/knowledge/INDEX.md` and relevant topic indexes.
- Read-only repo access.

## Outputs

- A draft `repo-recon.md` per the stage 3 template (likely files,
  bounded context, services, contracts, invariants, test seams,
  unknowns, explicit exclusions).
- A list of knowledge files that look stale or missing (passed to the
  caller, who may invoke `marshal-knowledge-research` /
  `marshal-knowledge-curator`).

## Workflow

1. Read the change brief.
2. Read the entry point + indexes; pull only the topic files whose
   `repo_paths` plausibly intersect the brief.
3. Walk likely code paths with semantic-aware tools.
4. Identify invariants and test seams; mark unknowns.
5. **Explicitly exclude** irrelevant areas, with one-line reasons.
6. Produce the draft and the stale-knowledge list.

## Skills and references used

- [marshal-analysis](../skills/marshal-analysis/SKILL.md)
- [activation-protocol](../references/activation-protocol.md)

## Delegation / handoff contract

- Returns the draft only — does not commit it. Caller (driver or human)
  reviews and saves under the change folder.

## Out of scope

- Producing a delivery plan (that is `marshal-planner`).
- Writing knowledge files (that is `marshal-knowledge-curator`).
