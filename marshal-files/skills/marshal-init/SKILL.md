---
name: marshal-init
description: First-time MARSHAL setup in a repository. Assumes scripts/install-marshal.sh has placed the durable assets under .marshal/ (and can run it if not); then does the repo integration the install needs judgment for — merging the MARSHAL entry-point into the repo's AGENTS.md, scaffolding and populating the .agent-config/ config-sync source via marshal-promote-assets, running the cyncia sync, updating .gitignore, and offering the initial knowledge bootstrap. Idempotent.
---

# marshal-init

Setup skill — runs once per repo, **after** the install script has placed MARSHAL's files.

## Division of labor (install vs. init)

- **`scripts/install-marshal.sh` owns installation.**
  It downloads MARSHAL at a ref and installs / updates the durable assets under `.marshal/` — including the canonical `marshal.md` and the `LICENSE` (both placed inside `.marshal/`) — reconciles `config.yml`, writes `.marshal/VERSION`, and installs [cyncia](https://github.com/crestreach/cyncia).
  It is idempotent — re-run it to update.
  **This skill never re-copies those files** — refer to the script (and `README.md`) for the install/update contract.
- **`marshal-init` (this skill) owns repo integration.**
  The steps that need judgment and a human in the loop: wiring the MARSHAL entry-point into the repo's `AGENTS.md`, scaffolding and populating the `.agent-config/` config-sync source, running the sync, updating `.gitignore`, and bootstrapping knowledge.

By the time this skill can run, the install script has already placed it under `.marshal/`, so `.marshal/` is present.

## Prerequisites

- A repo (any layout), fresh or with an existing top-level `AGENTS.md`.
- `.marshal/` installed by `scripts/install-marshal.sh`.
  If it is missing or partial, run the installer first (`scripts/install-marshal.sh`, or the install one-liner in the MARSHAL project README); this skill can invoke it but does not reimplement it.

## Inputs (read at start)

- The repo root and any existing top-level `AGENTS.md`.
- The installed `.marshal/` (assets, [`config.yml`](../../config.yml), [`ENTRYPOINT.md`](../../ENTRYPOINT.md), and the [`AGENTS.md`](../../AGENTS.md) entry-point snippet).
- Existing `.agent-config/` (or similarly named config-sync source) if present.
- Existing `.cyncia/` checkout if present.

## Workflow

1. **Confirm the install.**
   Check for `.marshal/` (and `.marshal/marshal.md`).
   If absent or incomplete, run `scripts/install-marshal.sh` (or ask the user to) — the script downloads and places everything and installs cyncia.
   Do **not** re-copy MARSHAL files here.
2. **Merge the MARSHAL entry-point into the repo's `AGENTS.md`.**
   Take the `.marshal/AGENTS.md` snippet and merge it into the repo's authoritative `AGENTS.md` — the root `AGENTS.md` in the direct layout, or `.agent-config/AGENTS.md` in the separate-source layout.
   Propose the merge for approval (per `extensions.autonomy`); do not silently overwrite user-authored content.
3. **Decide on tool fan-out.**
   If the user does not want their durable assets fanned out to tool-native layouts, skip to step 7 — MARSHAL runs fine read-in-place from `.marshal/`.
4. **Provision the `.agent-config/` config-sync source** (or whatever the user already calls it) if absent:
   - `.agent-config/AGENTS.md` — the user's authoritative `AGENTS.md` (start from the merged snippet in step 2 if the user wants).
   - `.agent-config/{skills,agents,rules,mcp-servers}/` — empty directories with `.gitkeep` placeholders.
     See the sync tool's [README](https://github.com/crestreach/cyncia#source-tree-format) for the source-tree format.
5. **Promote MARSHAL durable assets into `.agent-config/`** by running [`marshal-promote-assets`](../marshal-promote-assets/SKILL.md).
   It copies the built-ins (`skills/`, `skills-fallback/`, `agents/`, `rules/` — `marshal-` prefix) and the extensions (`extensions/{skills,agents,rules}/` — `mx-` prefix) from `.marshal/` into `.agent-config/` as-is, keeping every name unchanged.
6. **Run the sync (ask first).**
   Invoke `.cyncia/scripts/sync-all.sh -i .agent-config -o .` to fan everything out into the tool-native layouts cyncia is configured to emit (the set is cyncia's, see `.cyncia/cyncia.conf`).
   Warn the user that the sync overwrites the generated directories on every run; only the source trees (`.marshal/` + `.agent-config/`) are hand-edited.
7. **Update `.gitignore`** if the user agrees:
   ignore the generated tool-layout directories and generated root files (`CLAUDE.md`, `.mcp.json`), and the transient per-change working tree `.marshal/work/` (the artifact chain is rebuilt per change; `.marshal/archive/` is retained, so do **not** ignore it).
8. **Offer the initial knowledge bootstrap.**
   Trigger [`marshal-delegate-to-knowledge-init`](../marshal-delegate-to-knowledge-init/SKILL.md) (curator `init` mode) to build the initial knowledge snapshot.
   This is **not** silent: it is offered as the final init step and the user can run it now or defer it to a later session.
   Under `auto` autonomy the curator writes the snapshot and returns a summary; under `review` it returns a diff for approval.

## Outputs

- The MARSHAL entry-point merged into the repo's authoritative `AGENTS.md`.
- (Optional) `.agent-config/` scaffolded and populated with MARSHAL durable assets (built-ins keep their `marshal-` prefix; extensions keep their `mx-` prefix).
- (Optional) Tool-layout files written by the sync.
- (Optional) Updated `.gitignore`.
- An initial knowledge tree under `.marshal/knowledge/` produced by the bootstrap (applied with a summary under `auto`, or a diff for approval under `review`) — unless deferred.

## Exit criteria

- `.marshal/` is present (installed by the script) and the entry-point snippet is merged into the repo's authoritative `AGENTS.md`.
- If the user opted in: `.cyncia` is installed, `.agent-config/` exists, MARSHAL assets are promoted into it, and the sync has run cleanly at least once.
- Initial knowledge snapshot is created (applied under `auto`, or a diff approved under `review`) — or explicitly deferred to a later session.

## Next steps

- **Updates / re-installs:** re-run `scripts/install-marshal.sh` (idempotent) — it reconciles `config.yml` and refreshes the assets, `marshal.md`, and `LICENSE` without touching `.marshal/knowledge/`, `.marshal/work/`, or `.marshal/marshal-override.md`.
- **Promotion + sync (during init):** [`marshal-promote-assets`](../marshal-promote-assets/SKILL.md) is invoked from step 5, followed by the cyncia sync in step 6.
- **Knowledge bootstrap (final step, opt-in):** [`marshal-delegate-to-knowledge-init`](../marshal-delegate-to-knowledge-init/SKILL.md), which delegates to [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) in `init` mode with fresh context.
  Pass: path to `.marshal/knowledge/` (empty) and any detected language / framework hints.
  In environments without subagent support, the fallback skill `marshal-knowledge-init` runs the same logic inline.
