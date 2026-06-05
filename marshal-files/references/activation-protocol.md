# Startup context-loading protocol — reference

Shared by every MARSHAL agent and skill.
It answers one question: **what does an agent load at the start of a
session so it can work without researching from zero?**

Each agent names its own **load tier** below in its own definition;
this file defines what each tier means so the agents stay consistent.

## Load tiers

- **Minimal** — the tool instruction file (synced from
  `.marshal/AGENTS.md`), `.marshal/ENTRYPOINT.md`, and
  `.marshal/marshal-override.md` when present.
  Enough to know the process exists and where things live.
  Used by lightweight / procedural agents.
- **Standard** — minimal, plus `.marshal/config.yml` and the
  knowledge entry point (`.marshal/knowledge/INDEX.md`), descending
  into topic indexes only as needed.
  Used by most stage agents.
- **Full** — standard, plus the knowledge contract
  (`knowledge.contract_ref`) and the active knowledge implementation
  (`knowledge.representation_ref`), and the relevant per-change
  artifacts from the working folder (`.marshal/work/<change-id>/`).
  Used by knowledge agents and any agent that writes knowledge.

An agent loads the **smallest tier** that lets it do its job, then
descends into specific knowledge topic files or artifacts on demand.
If knowledge is missing or stale, it asks the researcher for a fresh
note rather than guessing.

## Resume

When `.marshal/work/current` names an active change, also read that
change's resume notes (`.marshal/work/<change-id>/logs/resume.md`) so
the session continues from where the last one left off.

## Knowledge write discipline

- Honor `.marshal/config.yml` `knowledge.autonomy`:
  - `auto` (default): write without per-change approval and return a
    summary of what changed.
  - `review`: produce a diff and wait for the human's approval before
    applying; group related edits into one diff.
- Never silently rewrite knowledge mid-task — either apply under
  `auto`, propose a diff under `review`, or drop a note into
  `learn/inbox/` for later promotion.
- Follow the active knowledge implementation for which metadata to
  refresh and how to regenerate indexes after a write.
