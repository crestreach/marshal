# MARSHAIL Entry Point

This is the rich entry point for agents working in a MARSHAIL-enabled repo.
Read this once per fresh session.
It is intentionally compact so it is cheap to keep in context.

Reference: [marshail.md](marshail.md) — full process spec.
Reference: [marshail-override.md](marshail-override.md) — **optional** repo-specific overrides on top of `marshail.md`.
Read it after `marshail.md`; anything in it takes precedence over the canonical spec on the points it addresses.
If the file is empty, MARSHAIL behaves as specified in `marshail.md`.
Knowledge contract: [references/knowledge-contract.md](references/knowledge-contract.md).
Active implementation: read `knowledge.representation_ref` in [config.yml](config.yml).
Default: [references/knowledge-markdown-spine.md](references/knowledge-markdown-spine.md).

## What MARSHAIL is (one paragraph)

MARSHAIL is an AI-assisted SDLC. It moves a change through explicit stages (Specification → Intake → Analysis → optional Architecture → Plan → Implementation round[Implement → Verify → Review / PR] → Rollout → Learn).
Only **the Plan stage** is mandatory — every other stage is optional and may be skipped when it would not add value (skip more for trivial changes, fewer for risky ones).
Each run’s scope is recorded at the top of `delivery-plan.md`.
Each stage that is run produces durable artifacts that feed the next.
Phase learnings are captured separately and promoted to durable guidance only when they are reusable.

## Stages, agents, and skills

MARSHAIL workflow logic lives in **subagents** under `.marshail/agents/`.
The shipped layout is:

- `.marshail/agents/<name>.md` — the canonical workflow for a stage / role.
  This is the single source of truth.
- `.marshail/skills/marshail-delegate-to-<x>/SKILL.md` — thin wrapper skills that match user intent (high-recall trigger phrases) and delegate to the matching subagent in fresh context.
- `.marshail/skills-fallback/marshail-<x>/SKILL.md` — equivalent skills for environments **without** subagent support; they instruct the assistant to follow the agent's source-of-truth file inline in the current session.
  Same names as the full-bodied skills they replace.

Each delegated agent is meant to work **independently** and to keep its internals out of the caller's context: it returns only what the caller needs (a summary or an artifact path), not its full working detail.
This keeps long runs cheap and avoids context pollution (see the general rule "share only what is needed across agent boundaries").

The Plan stage is the only mandatory stage; all others are optional unless noted.

| Stage | Subagent | Delegate skill | Fallback skill | Artifact | Optional? |
|---|---|---|---|---|---|
| Specification | `marshail-specifier` | `marshail-delegate-to-specify` | `marshail-specify` | `specification.md` | optional |
| Intake | `marshail-framer` | `marshail-delegate-to-intake` | `marshail-intake` | `change-brief.md` | optional |
| Analysis | `marshail-code-archaeologist` | `marshail-delegate-to-analysis` | `marshail-analysis` | `repo-recon.md` | optional |
| Architecture | `marshail-architect` | `marshail-delegate-to-architecture` | `marshail-architecture` | `architecture-notes.md` | optional |
| Plan | `marshail-planner` | `marshail-delegate-to-plan` | `marshail-plan` | `delivery-plan.md` | **mandatory** |
| Implement | `marshail-implementer` | `marshail-delegate-to-implement` | `marshail-implement` | code + `implementation-report.md` + `logs/phase-<n>.changelog.md` | required when there is code to write |
| Verify | `marshail-verifier` | `marshail-delegate-to-verify` | `marshail-verify` | `verification-report.md` | required before any PR |
| Review / PR | `marshail-reviewer` | `marshail-delegate-to-pr` | `marshail-pr` | PR description | optional (skip for non-shared work) |
| Rollout | `marshail-releaser` | `marshail-delegate-to-rollout` | `marshail-rollout` | `rollout-note.md` | optional |
| Learn | `marshail-learner` | `marshail-delegate-to-learn` | `marshail-learn` | `learning-rollup.md` | optional |

The full end-to-end orchestrator is `marshail-driver` (delegate skill `marshail-delegate-to-driver`); it has no fallback because its value is subagent orchestration with isolated context per stage.

**Two communication models** (mixable): call a specialist agent **directly** for one stage, or talk only to `marshail-driver` as a **single point of contact** that coordinates the specialists.
In the driver-mediated model the human-in-the-loop level ranges from hands-off (return only for key decisions and approval gates) to collaborative (decide together, phase by phase), inferred from the prompt and `config.yml` autonomy and adjustable at any stage boundary.
See `marshail-driver` and `marshail.md` for the full description and the turn-based mediation tradeoff.

The agent file states the prerequisites, inputs, outputs, and handoff.
Do not duplicate workflow content into the wrapper skills.

## Knowledge layer

Agent-maintained knowledge about this repo lives under `.marshail/knowledge/`.
It is **separate** from the synced skills/rules/agents tree.

Knowledge is MARSHAIL's agent-managed mid- and long-term memory.
The knowledge contract is separate from the active implementation: read `knowledge.contract_ref` and `knowledge.representation_ref` in `.marshail/config.yml` before assuming a storage layout, metadata fields, indexing strategy, or update protocol.
The default implementation is **MARSHAIL Markdown Spine**, documented in [`references/knowledge-markdown-spine.md`](references/knowledge-markdown-spine.md) — the single source of truth for the layout, metadata, indexing, splitting, and staleness mechanics.

To use it: start at the always-loaded root `.marshail/knowledge/INDEX.md`, then descend through the area indexes to the specific topic files only as the task needs them — using each file's summary to decide whether to open it.
The tree is hierarchical and recursive (no fixed depth); the active implementation defines the exact layout and metadata.

Knowledge content is not limited to code facts — it covers logic, architecture, design rationale, decisions, and conventions.

## Knowledge agents and skills

All knowledge maintenance work runs through the [`marshail-knowledge-curator`](agents/marshail-knowledge-curator.md) subagent (modes `init`, `from-changes`, `from-learning`, `rescan`, `rebuild`, `branch-merge`).
Read-only research uses the [`marshail-researcher`](agents/marshail-researcher.md) subagent.

| When | Subagent / mode | Delegate skill | Fallback skill |
|---|---|---|---|
| First-time bootstrap of `.marshail/knowledge/` | `marshail-knowledge-curator` (`init`) | `marshail-delegate-to-knowledge-init` | `marshail-knowledge-init` |
| After an implementation cycle, after the Learn stage, or on schedule | `marshail-knowledge-curator` (`from-changes` / `from-learning` / `rescan`) | `marshail-delegate-to-knowledge-maintain` | `marshail-knowledge-maintain` |
| Read-only deep-dive on a narrow topic | `marshail-researcher` | `marshail-delegate-to-knowledge-research` | `marshail-knowledge-research` |
| Reconciling knowledge changes from two branches | `marshail-knowledge-curator` (`branch-merge`) | `marshail-delegate-to-knowledge-branch-merge` | `marshail-knowledge-branch-merge` |
| Post-feature restructure of the knowledge tree | `marshail-knowledge-curator` (`rebuild`) | `marshail-delegate-to-knowledge-rebuild` | `marshail-knowledge-rebuild` |

## Approval and autonomy

`.marshail/config.yml` (`knowledge.autonomy`) controls how **knowledge writes** are applied.
Default `auto`: the curator applies the knowledge update and returns a short summary (no per-change approval) — knowledge is agent-managed memory that is rarely read by humans.
Set `review` to get a diff for approval before each knowledge write.
This gate governs knowledge writes only, not code or plan changes.

## Knowledge write discipline

Every agent that writes knowledge follows the same rule:

- Honor `.marshail/config.yml` `knowledge.autonomy`:
  - `auto` (default): write without per-change approval and return a summary of what changed.
  - `review`: produce a diff and wait for the human's approval before applying; group related edits into one diff.
- Never silently rewrite knowledge mid-task — either apply under `auto`, propose a diff under `review`, or drop a note into `knowledge/learn/inbox/` for later promotion.
- Follow the active knowledge implementation for which metadata to refresh and how to regenerate indexes after a write.

## Mid-process knowledge capture

Some agents (e.g. [`marshail-code-archaeologist`](agents/marshail-code-archaeologist.md), [`marshail-researcher`](agents/marshail-researcher.md), and occasionally any stage agent) discover durable, reusable knowledge while doing their work.
Two `.marshail/config.yml` settings govern what they do with it, and **every** agent that wants to augment knowledge follows the same rule:

- `knowledge.capture_during_process`:
  - **true** (default): write a knowledge-shaped note into `knowledge/learn/inbox/` (the archaeologist also attaches its stale-knowledge pointer list) so later stages can reuse it instead of rediscovering it.
  - **false**: do **not** touch the knowledge inbox mid-process; record the finding in the current stage's learning file (`learning/stage-<n>-<name>.learning.md`, or `learning/phase-<n>.learning.md` during implementation) instead, to be promoted only in the Learn stage.
- `knowledge.curator_invocation` (only relevant when a note was written to the inbox):
  - **agent**: the agent calls [`marshail-knowledge-curator`](agents/marshail-knowledge-curator.md) itself right after writing the note.
  - **driver** (default): the agent does **not** call the curator; it reports back to its caller (the driver, or the user when invoked directly) that it populated the inbox, and the caller runs the curator.

Agents never edit canonical knowledge directly — promotion always goes through the curator.

## Generated assets and config sync

Durable assets MARSHAIL comes with, produces, or maintains live under `.marshail/`:

- `agents/<name>.md` — one file per subagent.
  **Source of truth for workflow logic.**
- `skills/marshail-delegate-to-<x>/SKILL.md` — thin delegate wrappers, one folder per stage / role.
  Each delegates to the matching subagent.
- `skills-fallback/marshail-<x>/SKILL.md` — fallback skills for environments without subagent support; they point back to the agent file as the source of truth.
- `skills/marshail-{init,load,promote-assets}/SKILL.md` — main-session skills with no subagent counterpart.
- `rules/<name>.md` — one file per rule (frontmatter: `description`, `applies-to`, `always-apply`).
  Built-in MARSHAIL rules.
- `extensions/{skills,agents,rules}/` — **repo-specific extensions** drafted by [`marshail-learner`](agents/marshail-learner.md) (or hand-authored) on top of the built-ins.
  Every basename is `mx-`-prefixed at creation.
  Lives outside the built-in folders so it survives MARSHAIL upgrades.
- `knowledge/...` — read in place; **not** part of the sync source.
- `AGENTS.md` — a snippet to merge **manually** into the host repo's root `AGENTS.md` (which is the file the sync tool requires at its source root).

MARSHAIL agents may **create or update** built-in `skills/` / `agents/` / `rules/` only when MARSHAIL itself is being changed.
Repo-specific guidance generated from learnings or on user request goes under `extensions/{skills,agents,rules}/` with the `mx-` prefix at creation.
These extension / guidance writes follow `extensions.autonomy` in `.marshail/config.yml` (default `review`: a diff for approval before applying) — distinct from `knowledge.autonomy`, which governs knowledge writes.

To fan these out into the tool-native layouts cyncia is configured to target, the [`marshail-promote-assets`](skills/marshail-promote-assets/SKILL.md) skill copies both built-ins and extensions into `.agent-config/`, then [cyncia](https://github.com/crestreach/cyncia)'s sync fans it out — see `marshail.md` § Generated assets and config sync.

## Getting unstuck / asking about MARSHAIL

If at any point you (or the user) are unsure which stage to be in, which skill to invoke, or how MARSHAIL applies to the situation, invoke [`marshail-delegate-to-help`](skills/marshail-delegate-to-help/SKILL.md) (it delegates to [`marshail-helper`](agents/marshail-helper.md)).
It reads `marshail.md` and the `.marshail/` tree, answers the question, and either points you at the right next skill / agent or hands off to [`marshail-driver`](agents/marshail-driver.md) when work needs to actually progress.

## What this entry point is not

- It is **not** the place for repo-specific facts.
  Those go under `.marshail/knowledge/`.
- It is **not** the place for tool-specific configuration.
  That comes from the config-sync mechanism.
- It is **not** the project's `AGENTS.md`.
  That stays user-owned at the repo root.
