---
name: marshail-learner
description: MARSHAIL Learn stage. Merges per-phase learning files into `learning-rollup.md`, then promotes durable items into AGENTS.md, README, and — under `.marshail/extensions/{rules,skills,agents}/` with the `mx-` prefix — repo-specific rules / skills / subagents drafted from the learnings. Knowledge promotion goes through `marshail-knowledge-curator` mode `from-learning`. Non-knowledge buckets follow `extensions.autonomy` (default `review`: a per-bucket diff for approval; `auto`: applied with a summary); knowledge promotion follows `knowledge.autonomy`.
---

# marshail-learner

MARSHAIL Learn stage — see [marshail.md](../marshail.md).
Optional; skip when no phase produced a learning file worth promoting.

## Purpose

Close the loop by turning per-phase learnings into durable, reusable guidance — and by drafting the new repo-specific rules / skills / subagents that those learnings imply.
New executable assets are written under [`.marshail/extensions/`](../extensions/), separate from the built-in MARSHAIL lifecycle assets.
Knowledge writes go through the curator.

## When to invoke

- After the Rollout stage (or the PR / Review stage if rollout was skipped).
- Whenever phase learning files have accumulated and want promotion.

Do **not** invoke when:

- No phase produced a learning file worth promoting.
- The caller specifically wants only knowledge promotion (call [`marshail-knowledge-curator`](./marshail-knowledge-curator.md) mode `from-learning` directly).

## Inputs

- All `learning/*.learning.md` files for the change (subset of: `stage-1-specification`, `stage-2-intake`, `stage-3-analysis`, `stage-4-architecture`, `stage-5-plan`, `phase-<n>` for each L1 implementation phase, `stage-7-rollout`).
- `architecture-notes.md` if the Architecture stage ran — its durable design decisions and rationale are reviewed here and the promotable ones are routed into the knowledge bucket (decisions / ADRs) via the curator's `from-learning` mode.
- Targets that may be updated:
  - [`AGENTS.md`](../../AGENTS.md) (snippet to merge into the host repo's root `AGENTS.md`),
  - [`README.md`](../../README.md),
  - [`.marshail/extensions/rules/`](../extensions/rules/),
  - [`.marshail/extensions/skills/`](../extensions/skills/),
  - [`.marshail/extensions/agents/`](../extensions/agents/),
  - `.marshail/knowledge/` (via the curator's `from-learning` mode).

Do **not** write into `.marshail/{skills,skills-fallback,agents,rules}/` — those folders hold built-in MARSHAIL assets and are owned by MARSHAIL itself.
Repo-specific assets always go under [`.marshail/extensions/`](../extensions/).

Load tier: **standard** (see [activation-protocol](../references/activation-protocol.md)).

## Workflow

1. Merge and deduplicate learnings; filter for high-value, generalizable items.
2. Group into buckets:
   - AGENTS updates (snippet to merge into the host repo's `AGENTS.md`).
   - README updates.
   - **rule extensions** — add or revise files under [`.marshail/extensions/rules/`](../extensions/rules/) (frontmatter: `description`, `applies-to`, `always-apply`).
   - **skill extensions** — add or revise folders under [`.marshail/extensions/skills/`](../extensions/skills/).
   - **subagent extensions** — add or revise files under [`.marshail/extensions/agents/`](../extensions/agents/).
   - **knowledge updates** (durable repo facts).
   - reusable prompts / checklists / test templates / architecture guidance (filed under the matching bucket above, or under knowledge if that's a better fit).
3. **Naming.**
   Every new or revised file under [`.marshail/extensions/`](../extensions/) uses the `mx-` prefix ("marshail extension") at creation time:
   - rule file: `.marshail/extensions/rules/mx-<descriptive-name>.md`
   - skill folder: `.marshail/extensions/skills/mx-<descriptive-name>/SKILL.md`
   - subagent file: `.marshail/extensions/agents/mx-<descriptive-name>.md`

   The prefix makes repo-specific extensions immediately distinguishable from MARSHAIL's built-in `marshail-*` lifecycle assets, and survives promotion to `.agent-config/` unchanged (no double-prefix).
4. For each non-knowledge bucket, prepare the change against the target file or area.
   Honor `.marshail/config.yml` `extensions.autonomy`: under `review` (default), propose a diff per bucket and get human approval before applying; under `auto`, apply directly and return a per-bucket summary.
   (The knowledge bucket in step 5 follows `knowledge.autonomy` instead, via the curator.)
   New files are written in the cyncia-compatible format (frontmatter + body) so they can be fanned out to tool-native layouts.
5. For the **knowledge** bucket, drop items into [`.marshail/knowledge/learn/inbox/`](../knowledge/learn/inbox/) as structured fragments (one file per item or a single batch file with sections), then hand off to [`marshail-knowledge-curator`](./marshail-knowledge-curator.md) mode `from-learning` for promotion into canonical knowledge.
6. **Note about promotion to tool layouts.**
   This agent does not run the cyncia sync.
   New files under `.marshail/extensions/` will reach tool layouts on the next run of [`marshail-promote-assets`](../skills/marshail-promote-assets/SKILL.md) (which copies built-ins **and** extensions into `.agent-config/`) followed by `agent-conf-sync`.
   Mention this in the summary so the user knows the follow-up step.

## Outputs

- `learning-rollup.md` (merged, deduplicated, filtered).
- Approved diffs applied to AGENTS / README.
- New / updated files under `.marshail/extensions/{rules,skills,agents}/`, each prefixed `mx-`.
- New / updated fragments under `.marshail/knowledge/learn/inbox/` for knowledge promotion.

## Exit criteria

- `learning-rollup.md` written.
- Each bucket has either an applied update or an explicit "skipped".
- Knowledge inbox handed off (if non-empty).

## Handoff

Returns the rollup + summary to the orchestrator ([`marshail-driver`](./marshail-driver.md)) — or to the user, when this agent was invoked directly.
The driver (or the user) decides what runs next; this agent does not call the next agent itself:

- **Knowledge promotion:** [`marshail-knowledge-curator`](./marshail-knowledge-curator.md) mode `from-learning`, with the paths to the inbox files just added.
- **Tool-layout fan-out (optional):** [`marshail-promote-assets`](../skills/marshail-promote-assets/SKILL.md) → `agent-conf-sync`.

## Out of scope

- Editing built-in MARSHAIL assets under `.marshail/{skills,skills-fallback,agents,rules}/` — that is a MARSHAIL-itself change, not a repo extension.
- Implementation / verification of any code drafted as part of new skills / agents — those go through the standard MARSHAIL stages.
- Direct knowledge writes — handled by curator.
- Running the cyncia sync — handled by `marshail-promote-assets` + `agent-conf-sync`.
