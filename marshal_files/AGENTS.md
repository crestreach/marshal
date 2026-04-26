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
