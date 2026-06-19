# MARSHAL — entry-point snippet (merge into your repo's AGENTS.md)

This file is **not** a sync source on its own.
It is a short snippet that should be **manually copied / merged into the host repository's root `AGENTS.md`** so AI assistants pick up MARSHAL alongside any other repo-level guidelines you keep there.

Keep this file **short**.
The rich entry point lives in [ENTRYPOINT.md](./ENTRYPOINT.md).

---

## Snippet to merge

### Marshal

This repository uses **MARSHAL** — an AI-assisted SDLC defined in [marshal.md](.marshal/marshal.md).

Before doing any repo work:

1. Read [`.marshal/ENTRYPOINT.md`](.marshal/ENTRYPOINT.md) — it explains the process, the knowledge layer, and the available `marshal-*` skills and agents.
2. Read `.marshal/knowledge/INDEX.md` for the agent-maintained repo knowledge.
   Descend into folder / topic / subtopic indexes only as needed.
3. Honor the autonomy mode in `.marshal/config.yml` — by default (`auto`), knowledge updates are written without per-change approval and a summary of what changed is returned; under `review` every write produces a full diff for human approval first.

If the task is trivial (e.g. small docs typo) and does not require repo knowledge, you may skip steps 2–3.


### Agent configuration management (cyncia)

This repo manages all of its AI-assistant configuration — guidelines (`AGENTS.md`), rules, skills, agents, and MCP servers — through installed cyncia files under [`.cyncia`](./.cyncia).
The single generic source tree lives in [`.agent-config/`](./.agent-config); per-tool layouts (`.cursor/`, `.claude/`, `.github/`, `.junie/`, `.vscode/`, `.codex/`, `.agents/`, root `AGENTS.md`, `AGENTS.override.md`, `CLAUDE.md`) are generated from it.
The `agent-conf-sync` skill invokes the sync via `.cyncia/scripts/sync-all.sh` (POSIX) or `.cyncia/scripts/sync-all.ps1` (Windows).

When asked to **create or update** any of (or if any of the following gets updated):

- a guideline (the root `AGENTS.md`)
- a rule
- a skill
- a subagent
- an MCP server entry

read [`.cyncia/README.md`](./.cyncia/README.md) for the source-tree format (frontmatter fields, secret-token translation, agent ↔ MCP linkage), author the file under the appropriate folder of `.agent-config/` (`.agent-config/{rules,skills,agents,mcp-servers}/`), and then re-run the sync (skill `agent-conf-sync`) to fan it out to the per-tool directories.
Do not hand-edit generated `.cursor/`, `.claude/`, `.github/`, `.junie/`, `.vscode/`, `.codex/agents/`, `.agents/skills/`, root `AGENTS.md`, root `AGENTS.override.md`, or `CLAUDE.md` files — they are overwritten on the next sync.


### Hierarchical `AGENTS.md`

This repository follows the hierarchical `AGENTS.md` convention (the same one Codex/Cursor and other AI tools recognize): the root `AGENTS.md` holds repo-wide guidance, and any subdirectory **may** also contain its own `AGENTS.md` with guidance scoped to that folder.

Rules:

- Per-folder `AGENTS.md` is **optional**.
  Only add one when a directory has rules, conventions, or context that genuinely differs from the rest of the repo.
- Scope is the folder it lives in plus all of its subfolders, unless a deeper `AGENTS.md` overrides a specific point.
- Closer `AGENTS.md` files **override** farther ones for overlapping guidance; non-overlapping guidance is additive.
- Before working in a folder, agents should read every `AGENTS.md` on the path from the repo root down to that folder, in order, and apply them with deeper files winning on conflicts.
- Keep each `AGENTS.md` short and focused; link out to longer docs rather than duplicating them.
