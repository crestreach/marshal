---
name: marshail-init
description: First-time MARSHAIL setup in a repository. Assumes scripts/install-marshail.sh has placed the durable assets under .marshail/ (and can run it if not); then does the repo integration the install needs judgment for — merging the MARSHAIL entry-point into the repo's AGENTS.md, scaffolding and populating the .agent-config/ config-sync source via marshail-promote-assets, running the cyncia sync, updating .gitignore, and offering the initial knowledge bootstrap. Idempotent.
---

# marshail-init

Setup skill — runs once per repo, **after** the install script has placed MARSHAIL's files.

## Division of labor (install vs. init)

- **`scripts/install-marshail.sh` owns installation.**
  It downloads MARSHAIL at a ref and installs / updates the durable assets under `.marshail/` (which include the canonical `marshail.md`) plus the repo-root `LICENSE` inside `.marshail/`, reconciles `config.yml`, writes `.marshail/VERSION`, and installs [cyncia](https://github.com/crestreach/cyncia).
  It is idempotent — re-run it to update.
  **This skill never re-copies those files** — refer to the script (and `README.md`) for the install/update contract.
- **`marshail-init` (this skill) owns repo integration.**
  The steps that need judgment and a human in the loop: wiring the MARSHAIL entry-point into the repo's `AGENTS.md`, scaffolding and populating the `.agent-config/` config-sync source, running the sync, updating `.gitignore`, and bootstrapping knowledge.

By the time this skill can run, the install script has already placed it under `.marshail/`, so `.marshail/` is present.

## Prerequisites

- A repo (any layout), fresh or with an existing top-level `AGENTS.md`.
- `.marshail/` installed by `scripts/install-marshail.sh`.
  If it is missing or partial, run the installer first (`scripts/install-marshail.sh`, or the install one-liner in the MARSHAIL project README); this skill can invoke it but does not reimplement it.

## Inputs (read at start)

- The repo root and any existing top-level `AGENTS.md`.
- The installed `.marshail/` (assets, [`config.yml`](../../config.yml), [`ENTRYPOINT.md`](../../ENTRYPOINT.md), and the [`AGENTS.md`](../../AGENTS.md) entry-point snippet).
- Existing `.agent-config/` (or similarly named config-sync source) if present.
- Existing `.cyncia/` checkout if present.

## Workflow

1. **Confirm the install.**
   Check for `.marshail/` (and `.marshail/marshail.md`).
   If absent or incomplete, run `scripts/install-marshail.sh` (or ask the user to) — the script downloads and places everything and installs cyncia.
   Do **not** re-copy MARSHAIL files here.
2. **Merge the MARSHAIL entry-point into the repo's `AGENTS.md`.**
   Take the `.marshail/AGENTS.md` snippet and merge it into the repo's authoritative `AGENTS.md` — the root `AGENTS.md` in the direct layout, or `.agent-config/AGENTS.md` in the separate-source layout.
   Propose the merge for approval (per `extensions.autonomy`); do not silently overwrite user-authored content.
3. **Decide on tool fan-out.**
   If the user does not want their durable assets fanned out to tool-native layouts, skip to step 7 — MARSHAIL runs fine read-in-place from `.marshail/`.
4. **Provision the `.agent-config/` config-sync source** (or whatever the user already calls it) if absent:
   - `.agent-config/AGENTS.md` — the user's authoritative `AGENTS.md` (start from the merged snippet in step 2 if the user wants).
   - `.agent-config/{skills,agents,rules,mcp-servers}/` — empty directories with `.gitkeep` placeholders.
     See the sync tool's [README](https://github.com/crestreach/cyncia#source-tree-format) for the source-tree format.
5. **Promote MARSHAIL durable assets into `.agent-config/`** by running [`marshail-promote-assets`](../marshail-promote-assets/SKILL.md).
   It copies the built-ins (`skills/`, `skills-fallback/`, `agents/`, `rules/` — `marshail-` prefix) and the extensions (`extensions/{skills,agents,rules}/` — `mx-` prefix) from `.marshail/` into `.agent-config/` as-is, keeping every name unchanged.
6. **Run the sync (ask first).**
   Invoke `.cyncia/scripts/sync-all.sh -i .agent-config -o .` to fan everything out into the tool-native layouts cyncia is configured to emit (the set is cyncia's, see `.cyncia/cyncia.conf`).
   Warn the user that the sync overwrites the generated directories on every run; only the source trees (`.marshail/` + `.agent-config/`) are hand-edited.
7. **Update `.gitignore`** if the user agrees:
   ignore the generated tool-layout directories and generated root files (`CLAUDE.md`, `.mcp.json`), and the transient per-change working tree `.marshail/work/` (the artifact chain is rebuilt per change; `.marshail/archive/` is retained, so do **not** ignore it).
8. **Offer the initial knowledge bootstrap.**
   Trigger [`marshail-delegate-to-knowledge-init`](../marshail-delegate-to-knowledge-init/SKILL.md) (curator `init` mode) to build the initial knowledge snapshot.
   This is **not** silent: it is offered as the final init step and the user can run it now or defer it to a later session.
   Under `auto` autonomy the curator writes the snapshot and returns a summary; under `review` it returns a diff for approval.

## Outputs

- The MARSHAIL entry-point merged into the repo's authoritative `AGENTS.md`.
- (Optional) `.agent-config/` scaffolded and populated with MARSHAIL durable assets (built-ins keep their `marshail-` prefix; extensions keep their `mx-` prefix).
- (Optional) Tool-layout files written by the sync.
- (Optional) Updated `.gitignore`.
- An initial knowledge tree under `.marshail/knowledge/` produced by the bootstrap (applied with a summary under `auto`, or a diff for approval under `review`) — unless deferred.

## Exit criteria

- `.marshail/` is present (installed by the script) and the entry-point snippet is merged into the repo's authoritative `AGENTS.md`.
- If the user opted in: `.cyncia` is installed, `.agent-config/` exists, MARSHAIL assets are promoted into it, and the sync has run cleanly at least once.
- Initial knowledge snapshot is created (applied under `auto`, or a diff approved under `review`) — or explicitly deferred to a later session.

## Next steps

- **Updates / re-installs:** re-run `scripts/install-marshail.sh` (idempotent) — it reconciles `config.yml` and refreshes the assets, `marshail.md`, and `LICENSE` without touching `.marshail/knowledge/`, `.marshail/work/`, or `.marshail/marshail-override.md`.
- **Promotion + sync (during init):** [`marshail-promote-assets`](../marshail-promote-assets/SKILL.md) is invoked from step 5, followed by the cyncia sync in step 6.
- **Knowledge bootstrap (final step, opt-in):** [`marshail-delegate-to-knowledge-init`](../marshail-delegate-to-knowledge-init/SKILL.md), which delegates to [`marshail-knowledge-curator`](../../agents/marshail-knowledge-curator.md) in `init` mode with fresh context.
  Pass: path to `.marshail/knowledge/` (empty) and any detected language / framework hints.
  In environments without subagent support, the fallback skill `marshail-knowledge-init` runs the same logic inline.
