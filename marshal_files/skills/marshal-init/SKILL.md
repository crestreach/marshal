---
name: marshal-init
description: First-time MARSHAL setup in a repository. Creates the .marshal/ scaffolding, copies default config, optionally fans the marshal-* tree into tool layouts via the config-sync tool, and triggers marshal-knowledge-init for the initial knowledge snapshot. Idempotent.
---

# marshal-init

Setup skill — runs once per repo.

## Prerequisites

- A repo (any layout). Either fresh or with an existing top-level
  `AGENTS.md`.
- Optional: the [ai-dev-agent-config-sync](https://github.com/crestreach/ai-dev-agent-config-sync)
  tool installed if the user wants the marshal-* tree fanned out.

## Inputs (read at start)

- The repo root.
- Existing `AGENTS.md` if present.
- Existing `.marshal/` if present (for idempotent re-runs).

## Workflow

1. Detect existing `.marshal/`. If present, prompt before proceeding.
2. Create `.marshal/` skeleton:
   - [`AGENTS.md`](../../AGENTS.md) (a snippet meant to be **manually
     merged** into the host repo's root `AGENTS.md`),
     [`ENTRYPOINT.md`](../../ENTRYPOINT.md), [`config.yml`](../../config.yml).
   - `skills/`, `agents/`, [`rules/`](../../rules/) (sync-source folders).
   - `knowledge/INDEX.md`, `knowledge/repo/INDEX.md`,
     `knowledge/learn/inbox/`, `knowledge/learn/rollups/`.
3. **Do not** auto-edit the repo's root `AGENTS.md`. Surface the
   `.marshal/AGENTS.md` snippet to the user and ask them to merge it
   manually (the sync tool requires the root `AGENTS.md` at its
   source root and treats it as user-owned).
4. Optionally run the config-sync tool against `.marshal/` to fan the
   marshal-* assets into tool layouts. **Ask before running** — the
   sync may overwrite tool files.
5. Hand off to [`marshal-knowledge-init`](../marshal-knowledge-init/SKILL.md)
   to build the initial knowledge snapshot.

## Outputs

- `.marshal/` directory populated with scaffolding.
- (Optional) Tool-layout files written by the sync tool.
- An initial knowledge tree under `.marshal/knowledge/` produced by
  `marshal-knowledge-init` (separate diff for approval).

## Exit criteria

- `.marshal/` exists with required files.
- Initial knowledge snapshot is approved (or marked deferred).
- The user has been pointed at `.marshal/AGENTS.md` for manual merge
  into the repo's root `AGENTS.md`.

## Handoff

- **Next skill:** [`marshal-knowledge-init`](../marshal-knowledge-init/SKILL.md).
- **Pass:** path to `.marshal/knowledge/` (empty); optional list of
  detected language / framework hints.

## Subagent

For the heavy knowledge bootstrap step,
[`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md)
is the v2 subagent that wraps `marshal-knowledge-init` with fresh
context.
