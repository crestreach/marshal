# MARSHAL Entry Point

This is the rich entry point for agents working in a MARSHAL-enabled repo.
Read this once per fresh session.
It is intentionally compact so it is cheap to keep in context.

Reference: [marshal.md](../marshal.md) — full process spec.
Reference: [marshal-override.md](marshal-override.md) — **optional** repo-specific overrides on top of `marshal.md`.
Read it after `marshal.md`; anything in it takes precedence over the canonical spec on the points it addresses.
If the file is empty, MARSHAL behaves as specified in `marshal.md`.
Knowledge contract: [references/knowledge-contract.md](references/knowledge-contract.md).
Active implementation: read `knowledge.representation_ref` in [config.yml](config.yml).
Default: [references/knowledge-markdown-spine.md](references/knowledge-markdown-spine.md).

## What MARSHAL is (one paragraph)

MARSHAL is an AI-assisted SDLC. It moves a change through explicit stages (Specification → Intake → Analysis → optional Architecture → Plan → Implementation round[Implement → Verify → PR] → Rollout → Learn).
Only **the Plan stage** is mandatory — every other stage is optional and may be skipped when it would not add value (skip more for trivial changes, fewer for risky ones).
Each run’s scope is recorded at the top of `delivery-plan.md`.
Each stage that is run produces durable artifacts that feed the next.
Phase learnings are captured separately and promoted to durable guidance only when they are reusable.

## Stages, agents, and skills

MARSHAL workflow logic lives in **subagents** under `.marshal/agents/`.
The shipped layout is:

- `.marshal/agents/<name>.md` — the canonical workflow for a stage / role.
  This is the single source of truth.
- `.marshal/skills/marshal-delegate-to-<x>/SKILL.md` — thin wrapper skills that match user intent (high-recall trigger phrases) and delegate to the matching subagent in fresh context.
- `.marshal/skills-fallback/marshal-<x>/SKILL.md` — equivalent skills for environments **without** subagent support; they instruct the assistant to follow the agent's source-of-truth file inline in the current session.
  Same names as the full-bodied skills they replace.

Each delegated agent is meant to work **independently** and to keep its internals out of the caller's context: it returns only what the caller needs (a summary or an artifact path), not its full working detail.
This keeps long runs cheap and avoids context pollution (see the general rule "share only what is needed across agent boundaries").

The Plan stage is the only mandatory stage; all others are optional unless noted.

| Stage | Subagent | Delegate skill | Fallback skill | Artifact | Optional? |
|---|---|---|---|---|---|
| Specification | `marshal-specifier` | `marshal-delegate-to-specify` | `marshal-specify` | `specification.md` | optional |
| Intake | `marshal-framer` | `marshal-delegate-to-intake` | `marshal-intake` | `change-brief.md` | optional |
| Analysis | `marshal-code-archaeologist` | `marshal-delegate-to-analysis` | `marshal-analysis` | `repo-recon.md` | optional |
| Architecture | `marshal-architect` | `marshal-delegate-to-architecture` | `marshal-architecture` | `architecture-notes.md` | optional |
| Plan | `marshal-planner` | `marshal-delegate-to-plan` | `marshal-plan` | `delivery-plan.md` | **mandatory** |
| Implement | `marshal-implementer` | `marshal-delegate-to-implement` | `marshal-implement` | code + `logs/phase-N.changelog.md` | required when there is code to write |
| Verify | `marshal-verifier` | `marshal-delegate-to-verify` | `marshal-verify` | `verification-report.md` | required before any PR |
| PR | `marshal-reviewer` | `marshal-delegate-to-pr` | `marshal-pr` | PR description | optional (skip for non-shared work) |
| Rollout | `marshal-releaser` | `marshal-delegate-to-rollout` | `marshal-rollout` | `rollout-note.md` | optional |
| Learn | `marshal-learner` | `marshal-delegate-to-learn` | `marshal-learn` | `learning-rollup.md` | optional |

The full end-to-end orchestrator is `marshal-driver` (delegate skill `marshal-delegate-to-driver`); it has no fallback because its value is subagent orchestration with isolated context per stage.

**Two communication models** (mixable): call a specialist agent **directly** for one stage, or talk only to `marshal-driver` as a **single point of contact** that coordinates the specialists.
In the driver-mediated model the human-in-the-loop level ranges from hands-off (return only for key decisions and approval gates) to collaborative (decide together, phase by phase), inferred from the prompt and `config.yml` autonomy and adjustable at any stage boundary.
See `marshal-driver` and `marshal.md` for the full description and the turn-based mediation tradeoff.

The agent file states the prerequisites, inputs, outputs, and handoff.
Do not duplicate workflow content into the wrapper skills.

## Knowledge layer

Agent-maintained knowledge about this repo lives under `.marshal/knowledge/`.
It is **separate** from the synced skills/rules/agents tree.

Knowledge is MARSHAL's agent-managed mid- and long-term memory.
The knowledge contract is separate from the active implementation: read `knowledge.contract_ref` and `knowledge.representation_ref` in `.marshal/config.yml` before assuming a storage layout, metadata fields, indexing strategy, or update protocol.
The default implementation is **MARSHAL Markdown Spine**, documented in [`references/knowledge-markdown-spine.md`](references/knowledge-markdown-spine.md).

Default Markdown Spine read order:

1. `.marshal/knowledge/INDEX.md` (always-loaded; link list + summaries).
2. The folder index for the area you need (`repo/INDEX.md`, `domains/<x>/INDEX.md`, `decisions/`).
3. Specific topic files only when you need them.
   Topics may be split into their own sub-index plus subtopic files when they exceed `knowledge.topic_max_lines` in `.marshal/config.yml`; descend recursively as needed (no fixed depth).

Knowledge files have YAML frontmatter with `id`, `kind`, `summary`, `repo_paths`, `importance`, `confidence`, `updated`, `verified_against_commit`.
Use `repo_paths` to find the right file from a code path; use `summary` to decide whether to open a file.

Knowledge content is not limited to code facts — it covers logic, architecture, design rationale, decisions, and conventions.

## Knowledge agents and skills

All knowledge maintenance work runs through the [`marshal-knowledge-curator`](agents/marshal-knowledge-curator.md) subagent (modes `init`, `from-changes`, `from-learning`, `rescan`, `rebuild`, `branch-merge`).
Read-only research uses the [`marshal-researcher`](agents/marshal-researcher.md) subagent.

| When | Subagent / mode | Delegate skill | Fallback skill |
|---|---|---|---|
| First-time bootstrap of `.marshal/knowledge/` | `marshal-knowledge-curator` (`init`) | `marshal-delegate-to-knowledge-init` | `marshal-knowledge-init` |
| After an implementation cycle, after the Learn stage, or on schedule | `marshal-knowledge-curator` (`from-changes` / `from-learning` / `rescan`) | `marshal-delegate-to-knowledge-maintain` | `marshal-knowledge-maintain` |
| Read-only deep-dive on a narrow topic | `marshal-researcher` | `marshal-delegate-to-knowledge-research` | `marshal-knowledge-research` |
| Reconciling knowledge changes from two branches | `marshal-knowledge-curator` (`branch-merge`) | `marshal-delegate-to-knowledge-branch-merge` | `marshal-knowledge-branch-merge` |
| Post-feature restructure of the knowledge tree | `marshal-knowledge-curator` (`rebuild`) | `marshal-delegate-to-knowledge-rebuild` | `marshal-knowledge-rebuild` |

## Approval and autonomy

`.marshal/config.yml` (`knowledge.autonomy`) controls how **knowledge writes** are applied.
Default `auto`: the curator applies the knowledge update and returns a short summary (no per-change approval) — knowledge is agent-managed memory that is rarely read by humans.
Set `review` to get a diff for approval before each knowledge write.
This gate governs knowledge writes only, not code or plan changes.

## Knowledge write discipline

Every agent that writes knowledge follows the same rule:

- Honor `.marshal/config.yml` `knowledge.autonomy`:
  - `auto` (default): write without per-change approval and return a summary of what changed.
  - `review`: produce a diff and wait for the human's approval before applying; group related edits into one diff.
- Never silently rewrite knowledge mid-task — either apply under `auto`, propose a diff under `review`, or drop a note into `knowledge/learn/inbox/` for later promotion.
- Follow the active knowledge implementation for which metadata to refresh and how to regenerate indexes after a write.

## Mid-process knowledge capture

Some agents (e.g. [`marshal-code-archaeologist`](agents/marshal-code-archaeologist.md), [`marshal-researcher`](agents/marshal-researcher.md), and occasionally any stage agent) discover durable, reusable knowledge while doing their work.
Two `.marshal/config.yml` settings govern what they do with it, and **every** agent that wants to augment knowledge follows the same rule:

- `knowledge.capture_during_process`:
  - **true** (default): write a knowledge-shaped note into `knowledge/learn/inbox/` (the archaeologist also attaches its stale-knowledge pointer list) so later stages can reuse it instead of rediscovering it.
  - **false**: do **not** touch the knowledge inbox mid-process; record the finding in the current phase's learnings file (`learning/phase-N.learning.md`) instead, to be promoted only in the Learn stage.
- `knowledge.curator_invocation` (only relevant when a note was written to the inbox):
  - **agent**: the agent calls [`marshal-knowledge-curator`](agents/marshal-knowledge-curator.md) itself right after writing the note.
  - **driver** (default): the agent does **not** call the curator; it reports back to its caller (the driver, or the user when invoked directly) that it populated the inbox, and the caller runs the curator.

Agents never edit canonical knowledge directly — promotion always goes through the curator.

## Generated assets and config sync

Durable assets MARSHAL comes with, produces, or maintains live under `.marshal/`:

- `agents/<name>.md` — one file per subagent.
  **Source of truth for workflow logic.**
- `skills/marshal-delegate-to-<x>/SKILL.md` — thin delegate wrappers, one folder per stage / role.
  Each delegates to the matching subagent.
- `skills-fallback/marshal-<x>/SKILL.md` — fallback skills for environments without subagent support; they point back to the agent file as the source of truth.
- `skills/marshal-{init,load,promote-assets}/SKILL.md` — main-session skills with no subagent counterpart.
- `rules/<name>.md` — one file per rule (frontmatter: `description`, `applies-to`, `always-apply`).
  Built-in MARSHAL rules.
- `extensions/{skills,agents,rules}/` — **repo-specific extensions** drafted by [`marshal-learner`](agents/marshal-learner.md) (or hand-authored) on top of the built-ins.
  Every basename is `mx-`-prefixed at creation.
  Lives outside the built-in folders so it survives MARSHAL upgrades.
- `knowledge/...` — read in place; **not** part of the sync source.
- `AGENTS.md` — a snippet to merge **manually** into the host repo's root `AGENTS.md` (which is the file the sync tool requires at its source root).

MARSHAL agents may **create or update** built-in `skills/` / `agents/` / `rules/` only when MARSHAL itself is being changed.
Repo-specific guidance generated from learnings or on user request goes under `extensions/{skills,agents,rules}/` with the `mx-` prefix at creation.
Diffs go through the autonomy gate in `.marshal/config.yml`.

To fan these out into tool-native layouts (Cursor, Claude Code, GitHub Copilot, JetBrains Junie), the [`marshal-promote-assets`](skills/marshal-promote-assets/SKILL.md) skill copies both built-ins and extensions into `.agent-config/`, then [cyncia](https://github.com/crestreach/cyncia)'s sync fans it out — see `marshal.md` § Generated assets and config sync.

## Getting unstuck / asking about MARSHAL

If at any point you (or the user) are unsure which stage to be in, which skill to invoke, or how MARSHAL applies to the situation, invoke [`marshal-delegate-to-help`](skills/marshal-delegate-to-help/SKILL.md) (it delegates to [`marshal-helper`](agents/marshal-helper.md)).
It reads `marshal.md` and the `.marshal/` tree, answers the question, and either points you at the right next skill / agent or hands off to [`marshal-driver`](agents/marshal-driver.md) when work needs to actually progress.

## What this entry point is not

- It is **not** the place for repo-specific facts.
  Those go under `.marshal/knowledge/`.
- It is **not** the place for tool-specific configuration.
  That comes from the config-sync mechanism.
- It is **not** the project's `AGENTS.md`.
  That stays user-owned at the repo root.
