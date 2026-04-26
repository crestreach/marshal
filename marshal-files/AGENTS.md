# MARSHAL — entry-point snippet (merge into your repo's AGENTS.md)

This file is **not** a sync source on its own. It is a short snippet that
should be **manually copied / merged into the host repository's root
`AGENTS.md`** so AI assistants pick up MARSHAL alongside any other
repo-level guidelines you keep there.

The [ai-dev-agent-config-sync](https://github.com/crestreach/ai-dev-agent-config-sync)
tool requires a single `AGENTS.md` at the source root — that role belongs
to your repo's own `AGENTS.md`, not to this file. Once the snippet below is
merged in, run the sync tool against `.marshal/` as the source root to fan
everything (skills, agents, rules, the merged `AGENTS.md`) out into
tool-native layouts (`.cursor/`, `.claude/`, `.github/`, `.junie/`).

Keep this file **short**. The rich entry point lives in
[ENTRYPOINT.md](./ENTRYPOINT.md).

---

## Snippet to merge

This repository uses **MARSHAL** — an AI-assisted SDLC defined in
[marshal.md](../marshal.md).

Before doing any repo work:

1. Read [`.marshal/ENTRYPOINT.md`](./ENTRYPOINT.md) — it explains the
   process, the knowledge layer, and the available `marshal-*` skills and
   agents.
2. Read `.marshal/knowledge/INDEX.md` for the agent-maintained repo
   knowledge. Descend into folder / topic / subtopic indexes only as
   needed.
3. Honor the autonomy mode in `.marshal/config.yml` — by default,
   knowledge updates require human approval.

If the task is trivial (e.g. small docs typo) and does not require repo
knowledge, you may skip steps 2–3.

### Hierarchical `AGENTS.md`

This repository follows the hierarchical `AGENTS.md` convention (the same
one Codex/Cursor and other AI tools recognize): the root `AGENTS.md` holds
repo-wide guidance, and any subdirectory **may** also contain its own
`AGENTS.md` with guidance scoped to that folder.

Rules:

- Per-folder `AGENTS.md` is **optional**. Only add one when a directory
  has rules, conventions, or context that genuinely differs from the
  rest of the repo.
- Scope is the folder it lives in plus all of its subfolders, unless a
  deeper `AGENTS.md` overrides a specific point.
- Closer `AGENTS.md` files **override** farther ones for overlapping
  guidance; non-overlapping guidance is additive.
- Before working in a folder, agents should read every `AGENTS.md` on
  the path from the repo root down to that folder, in order, and apply
  them with deeper files winning on conflicts.
- Keep each `AGENTS.md` short and focused; link out to longer docs
  rather than duplicating them.
