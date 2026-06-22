# Startup context-loading protocol — reference

Shared by every MARSHAIL agent and skill.
It answers one question: **what does an agent load at the start of a session so it can work without researching from zero?**

Each agent names its own **load tier** below in its own definition; this file defines what each tier means so the agents stay consistent.

## Load tiers

- **Minimal** — the tool instruction file (synced from `.marshail/AGENTS.md`), `.marshail/ENTRYPOINT.md`, and `.marshail/marshail-override.md` when present.
  Enough to know the process exists and where things live.
  Used by lightweight / procedural agents.
- **Standard** — minimal, plus `.marshail/config.yml` and the knowledge entry point (`.marshail/knowledge/INDEX.md`), descending into topic indexes only as needed.
  Used by most stage agents.
- **Full** — standard, plus the knowledge contract (`knowledge.contract_ref`) and the active knowledge implementation (`knowledge.representation_ref`), and the relevant per-change artifacts from the working folder (`.marshail/work/<change-id>/`).
  Used by knowledge agents and any agent that writes knowledge.

An agent loads the **smallest tier** that lets it do its job, then descends into specific knowledge topic files or artifacts on demand.
If knowledge is missing or stale, it asks the researcher for a fresh note rather than guessing.

## Logging and resume

The per-change working folder `.marshail/work/<change-id>/` holds the artifact chain plus a `logs/` folder.
The working folder is created by whichever component starts the change — the driver in the driver-mediated model, or the first specialist agent / skill in the direct model — and `.marshail/work/current` is written at the same time so the active change never has to be guessed.

`logs/` keeps three kinds of file, each with a distinct job so the context stays small:

- **`resume.md`** — a single, short "where are we" file: current stage, active phase / cycle, the next action, and open decisions / questions.
  It is **rewritten (compacted), not appended**, on every update, so it stays cheap to load.
  This is the only log read by default on resume.
- **`<agent>.log.md`** — one append-only log per agent role (e.g. `planner.log.md`, `implementer.log.md`).
  Detailed, not loaded by default; consulted only when the thread for that role must be reconstructed.
- **`stage-<n>-<name>.changelog.md` / `phase-<n>.changelog.md`** — the changelog of record: one `stage-…` file per lifecycle stage (e.g. `stage-3-analysis`), plus one `phase-…` file per delivery-plan L1 phase during Implement (e.g. `phase-2`, optionally `phase-2-<slug>`).

**Fresh-run vs resume.**
Because an agent can run many times for one change (replanning, an implementation cycle per phase), each invocation works against a **run section** in its `<agent>.log.md`:

```
## Run <n> — <ISO-8601 timestamp>
```

The caller does **not** pass a run id.
Instead, each agent **marks its run section finished** when it completes its work (and leaves it unmarked while the work is still in progress).
On the next invocation the agent reads the **last run section** in its `<agent>.log.md` and decides:

- last section **marked finished** → the previous run is done, so this is a **fresh run**: open a new section.
- last section **not finished** → the previous run was interrupted, so **resume** it (continue in the same section).

The **prompt takes precedence** over this heuristic: if the caller (or user) explicitly asks to start over / open a new run, or to continue a specific prior run, honor that regardless of the last section's state.
The agent may read the previous run for continuity but never silently overwrites it.

On resume, an agent reads `resume.md` first (always), then descends into its own `<agent>.log.md` or the phase changelogs only if it needs more detail.
Every agent that changes state appends to its run section and refreshes `resume.md` before handing back; when it has actually finished its work it **marks the run section finished** (the signal the next invocation uses to tell a fresh run from a resume), so the next dispatch — by the driver or directly by the user — can continue from disk.
