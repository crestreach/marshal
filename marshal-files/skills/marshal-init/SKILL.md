---
name: marshal-init
description: First-time MARSHAL setup in a repository. Creates the .marshal/ scaffolding, copies default config, optionally installs ai-dev-agent-config-sync (as a submodule) and an agent-config/ source tree, runs marshal-promote-assets to wire MARSHAL durable assets into agent-config/, optionally runs the sync to fan everything out into tool-native layouts, and triggers marshal-knowledge-init for the initial knowledge snapshot. Idempotent.
---

# marshal-init

Setup skill — runs once per repo.

## Prerequisites

- A repo (any layout). Either fresh or with an existing top-level
  `AGENTS.md`.

## Inputs (read at start)

- The repo root.
- Existing `AGENTS.md` if present.
- Existing `.marshal/` if present (for idempotent re-runs).
- Existing `agent-config/` (or similarly named config-sync source
  tree) if present.
- Existing `ai-dev-agent-config-sync` checkout (submodule, vendored
  copy, or installed binary) if present.

## Workflow

1. **Detect existing `.marshal/`.** If present, prompt before
   proceeding. The skill is idempotent — only the missing parts are
   created.
2. **Create the `.marshal/` skeleton:**
   - [`AGENTS.md`](../../AGENTS.md) (the snippet that gets **merged**
     into the host repo's root `AGENTS.md`),
     [`ENTRYPOINT.md`](../../ENTRYPOINT.md),
     [`config.yml`](../../config.yml).
   - `skills/`, `agents/`, [`rules/`](../../rules/) — the canonical
     MARSHAL durable assets (`marshal-*` skills, subagents, rules).
   - `knowledge/INDEX.md`, `knowledge/repo/INDEX.md`,
     `knowledge/learn/inbox/`, `knowledge/learn/rollups/`.
3. **Merge the AGENTS.md snippet.** Surface
   [`.marshal/AGENTS.md`](../../AGENTS.md) and ask the user to merge
   it into the repo's root `AGENTS.md`. Do **not** auto-edit the root
   file — the sync tool treats it as user-owned and will overwrite
   only generated tool layouts, not the source `AGENTS.md`.
4. **Install [ai-dev-agent-config-sync](https://github.com/crestreach/ai-dev-agent-config-sync)
   if needed.** Detect it first (look for `ai-dev-agent-config-sync/`
   at the repo root, or any directory containing `scripts/sync-all.sh`
   the user already uses). If absent, **ask the user** which install
   method they want and execute it:
   - **Git submodule (recommended):**
     `git submodule add https://github.com/crestreach/ai-dev-agent-config-sync.git ai-dev-agent-config-sync`
   - **Subtree:** see the sync tool's
     [README](https://github.com/crestreach/ai-dev-agent-config-sync#installation)
     for the `git subtree add` invocation.
   - **Skip:** the user can run MARSHAL without fanning durable assets
     out to tool layouts. In that case, jump to step 7.
5. **Provision an `agent-config/` source tree** (or whatever the user
   already calls their config-sync source root). If absent, scaffold
   it with the required structure:
   - `agent-config/AGENTS.md` — the user's authoritative
     `AGENTS.md` for the repo (start with the merged snippet from
     step 3 if the user wants).
   - `agent-config/{skills,agents,rules,mcp-servers}/` — empty
     directories with `.gitkeep` placeholders.
   See the sync tool's
   [README](https://github.com/crestreach/ai-dev-agent-config-sync#source-tree-format)
   for the source-tree format.
6. **Promote MARSHAL durable assets into `agent-config/`** by running
   [`marshal-promote-assets`](../marshal-promote-assets/SKILL.md). It
   copies `.marshal/{skills,agents,rules}/` into
   `agent-config/{skills,agents,rules}/` with the `mx_` prefix on
   every promoted basename so MARSHAL items remain visibly distinct
   from non-MARSHAL items in the shared tree.
7. **Run the sync (optional, ask first).** Invoke
   `ai-dev-agent-config-sync/scripts/sync-all.sh -i agent-config -o .`
   to fan everything out into tool-native layouts (`.cursor/`,
   `.claude/`, `.github/`, `.junie/`, `.vscode/` plus root `AGENTS.md`,
   `CLAUDE.md`, `.mcp.json`). Warn the user that the sync overwrites
   the generated directories on every run; only the source tree
   (`.marshal/` + `agent-config/`) is hand-edited.
8. **Update `.gitignore`** if the user agrees: ignore the generated
   directories (`.claude/`, `.cursor/`, `.github/`, `.junie/`,
   `.vscode/`) and the generated root files (`CLAUDE.md`, `.mcp.json`)
   so they are not committed alongside the source tree.
9. **Hand off** to
   [`marshal-knowledge-init`](../marshal-knowledge-init/SKILL.md) to
   build the initial knowledge snapshot.

## Outputs

- `.marshal/` directory populated with scaffolding.
- (Optional) `ai-dev-agent-config-sync/` installed as a submodule.
- (Optional) `agent-config/` scaffolded as the config-sync source
  tree, with MARSHAL durable assets promoted into it (`mx_` prefix).
- (Optional) Tool-layout files written by the sync.
- (Optional) Updated `.gitignore`.
- An initial knowledge tree under `.marshal/knowledge/` produced by
  `marshal-knowledge-init` (separate diff for approval).

## Exit criteria

- `.marshal/` exists with required files.
- The user has been pointed at `.marshal/AGENTS.md` for manual merge
  into the repo's root `AGENTS.md`.
- If the user opted in: `ai-dev-agent-config-sync` is installed,
  `agent-config/` exists, MARSHAL assets are promoted into it, and
  the sync has run cleanly at least once.
- Initial knowledge snapshot is approved (or marked deferred).

## Handoff

- **Next skill (during init):**
  [`marshal-promote-assets`](../marshal-promote-assets/SKILL.md) —
  invoked from step 6 above.
- **Final handoff:**
  [`marshal-knowledge-init`](../marshal-knowledge-init/SKILL.md).
- **Pass:** path to `.marshal/knowledge/` (empty); optional list of
  detected language / framework hints.

## Subagent

For the heavy knowledge bootstrap step,
[`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md)
is the v2 subagent that wraps `marshal-knowledge-init` with fresh
context.
