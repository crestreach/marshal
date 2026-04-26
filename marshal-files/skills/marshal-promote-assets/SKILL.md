---
name: marshal-promote-assets
description: Copies MARSHAL-generated durable assets (rules, skills, subagents) from the project's `.marshal/` directory into the project's agent-config source tree, so the next `agent-conf-sync` run fans them out to all tool layouts. Use when the user asks to "promote MARSHAL skills/agents/rules", "copy from .marshal to agent-config", "wire MARSHAL assets into the sync source", or similar.
---

# marshal-promote-assets

MARSHAL stores its durable assets — rules, skills, and subagents — under a
`.marshal/` directory in the repo. These are the canonical authored
versions. To make them available to all AI assistants (Cursor, Claude,
Copilot, VS Code, Junie), they must be copied into the agent-config
source tree consumed by
[`ai-dev-agent-config-sync`](https://github.com/crestreach/ai-dev-agent-config-sync),
and then synced.

This skill performs the copy step only. Run `agent-conf-sync` afterwards
to fan the result out to tool-specific layouts.

## When to apply

Trigger phrases:

- "promote MARSHAL skills / agents / rules"
- "copy MARSHAL assets into agent-config"
- "wire `.marshal/` into the sync source"
- "sync MARSHAL assets to tools" (do this skill, then `agent-conf-sync`)

Do **not** apply when the user is editing source files in `.marshal/` or
asking about MARSHAL stages — that is normal MARSHAL work.

## Inputs

- **MARSHAL source dir** (default: `.marshal/` at the repo root; the
  current repo's `AGENTS.md` may pin a different path). Otherwise:
  ask the user.
- **Agent-config source dir** (default: read from `AGENTS.md` of the
  current repo, or use the conventional location `agent-config/`).
  Otherwise: ask.
- Optional explicit overrides from the user prompt
  (`from <path>`, `into <path>`).

## Workflow

1. **Resolve paths.** Determine MARSHAL source dir and agent-config
   source dir as described above. Use absolute paths.
2. **Sanity-check.** Confirm the MARSHAL source dir exists and contains
   at least one of `skills/`, `agents/`, `rules/`. Confirm the
   agent-config source dir exists and contains `AGENTS.md`.
3. **Plan copies.** For each of the three asset folders that exists in
   the MARSHAL source dir, copy its contents into the matching folder
   in the agent-config source dir, creating the target folder if
   missing. **Every copied item's basename is prefixed with `mx_`**
   ("marshal extension") to namespace promoted MARSHAL assets in the
   shared agent-config tree, distinguish them from the built-in
   `marshal-` lifecycle skills shipped with MARSHAL itself, and avoid
   collisions with non-MARSHAL items. Apply the prefix unconditionally
   — even if the source name already starts with `marshal-` or
   `marshal_`. The prefix applies to:
   - skill folder name (e.g. `marshal-plan/SKILL.md` → `mx_marshal-plan/SKILL.md`)
   - agent file name (e.g. `marshal-driver.md` → `mx_marshal-driver.md`)
   - rule file name (e.g. `commit-style.md` → `mx_commit-style.md`)

   Mappings:
   - `<marshal_src>/skills/<name>/` → `<agent_config>/skills/mx_<name>/`
     (preserve the inner `SKILL.md` plus any extra files in the same
     folder)
   - `<marshal_src>/agents/<name>.md` → `<agent_config>/agents/mx_<name>.md`
   - `<marshal_src>/rules/<name>.md` → `<agent_config>/rules/mx_<name>.md`

   If the source name already starts with `mx_`, keep it as-is (do
   not double-prefix).
4. **Show the plan**: list the source files / folders and their
   `mx_`-prefixed destinations, then ask for approval before copying
   (default autonomy). Skip the prompt if the user explicitly said
   "go ahead", "just do it", or similar.
5. **Copy.** Use `cp -R` (Unix) or `Copy-Item -Recurse -Force`
   (PowerShell). Overwrite existing files in agent-config — that
   directory is the sync source, not authored content. Apply the
   `mx_` prefix as part of the destination path.
6. **Skip MARSHAL housekeeping files.** Do not copy the MARSHAL source
   dir's own `AGENTS.md`, `ENTRYPOINT.md`, `config.yml`, `references/`,
   `design/`, `knowledge/`, or `rules/README.md`. Only the three
   asset folders.
7. **Filter by glob (optional).** If the user named specific items
   ("just `marshal-plan` and `marshal-implement`"), copy only those.
8. **Suggest follow-up.** End by suggesting the user run
   `agent-conf-sync` to propagate the copied assets into tool layouts.

## Outputs

- Files added or overwritten under
  `<agent_config>/{skills,agents,rules}/`.
- A short summary listing the copied paths.

## Edge cases

- **Conflicting names.** If a non-MARSHAL skill/agent/rule with the
  same name exists in agent-config, surface the conflict and ask
  before overwriting.
- **Out-of-tree MARSHAL.** If the MARSHAL dir is not at the repo
  root (rare), the user must specify the path explicitly.
- **Empty source.** If neither `skills/` nor `agents/` nor `rules/`
  exist in the MARSHAL source, exit with a note instead of copying.
- **Dry-run flag.** If the user says "preview", "dry run", or similar,
  print the copy plan without executing.

## Pairing

This skill is half of a two-step flow:

1. `marshal-promote-assets` — copy `.marshal/` assets into
   agent-config (this skill).
2. `agent-conf-sync` — fan agent-config out to all tool layouts.

When the user asks to "promote MARSHAL assets to all tools", run both
in order.
