# MARSHAL Entry Point

This is the rich entry point for agents working in a MARSHAL-enabled repo.
Read this once per fresh session. It is intentionally compact so it is
cheap to keep in context.

Reference: [marshal.md](../marshal.md) — full process spec.
Reference: [design/knowledge-design.md](design/knowledge-design.md) — knowledge layer design.
Shared format spec: [references/knowledge-format.md](references/knowledge-format.md).

## What MARSHAL is (one paragraph)

MARSHAL is an AI-assisted SDLC. It moves a change through explicit stages
(Specification → Intake → Analysis → optional Architecture → Plan →
Implementation round[Implement → Verify → PR] → Rollout → Learn). Only
**stage 4 Plan** is mandatory — every other stage is optional and may be
skipped when it would not add value (skip more for trivial changes, fewer
for risky ones). Each run’s scope is recorded at the top of
`delivery-plan.md`. Each stage that is run produces durable artifacts that
feed the next. Phase learnings are captured separately and promoted to
durable guidance only when they are reusable.

## Stages and skills

Stages map to `marshal-*` skills. Use the relevant one when working in
that stage. Stage 4 Plan is the only mandatory stage; all others are
optional unless noted.

| Stage | Skill | Artifact | Optional? |
|---|---|---|---|
| 1. Specification | `marshal-specify` | `specification.md` | optional |
| 2. Intake | `marshal-intake` | `change-brief.md` | optional |
| 3. Analysis | `marshal-analysis` | `repo-recon.md` | optional |
| 3.5. Architecture | `marshal-architecture` | `architecture-notes.md` | optional |
| 4. Plan | `marshal-plan` | `delivery-plan.md` | **mandatory** |
| 5a. Implement | `marshal-implement` | code + `logs/phase-N.changelog.md` | required when there is code to write |
| 5b. Verify | `marshal-verify` | `verification-report.md` | required before any PR |
| 5c. PR | `marshal-pr` | PR description | optional (skip for non-shared work) |
| 6. Rollout | `marshal-rollout` | `rollout-note.md` | optional |
| 7. Learn | `marshal-learn` | `learning-rollup.md` | optional |

Each skill states its own prerequisites, inputs, outputs, and handoff so it
can run in isolated context.

## Knowledge layer

Agent-maintained knowledge about this repo lives under
`.marshal/knowledge/`. It is **separate** from the synced
skills/rules/agents tree.

Read order:

1. `.marshal/knowledge/INDEX.md` (always-loaded; link list + summaries).
2. The folder index for the area you need (`repo/INDEX.md`,
   `domains/<x>/INDEX.md`, `decisions/`, `learn/rollups/`).
3. Specific topic files only when you need them. Topics may be split into
   their own sub-index plus subtopic files when they exceed
   `knowledge.topic_max_lines` in `.marshal/config.yml`; descend
   recursively as needed (no fixed depth).

Knowledge files have YAML frontmatter with `id`, `kind`, `summary`,
`repo_paths`, `importance`, `confidence`, `updated`,
`verified_against_commit`. Use `repo_paths` to find the right file from a
code path; use `summary` to decide whether to open a file.

Knowledge content is not limited to code facts — it covers logic,
architecture, design rationale, decisions, and conventions.

Knowledge content is not limited to code facts — it covers logic,
architecture, design rationale, decisions, and conventions.

## Knowledge skills

| Skill | When to use |
|---|---|
| `marshal-knowledge-init` | First-time bootstrap of `.marshal/knowledge/`. |
| `marshal-knowledge-maintain` | After an implementation cycle (mode `from-changes`); after stage 7 (mode `from-learning`); on schedule (mode `rescan`). Also splits oversize topics into sub-indexes. |
| `marshal-knowledge-research` | When the index does not answer a question — gather a condensed delta. |
| `marshal-knowledge-branch-merge` | When merging branches that both updated knowledge files. |
| `marshal-knowledge-rebuild` | After a large feature, to incorporate new / deleted code and changed logic. |

## Approval and autonomy

`.marshal/config.yml` controls write behavior. Default: every knowledge
update produces a diff for human approval. `auto` mode skips approval and
is intended for later, mature use only.

## Generated assets and config sync

Durable assets MARSHAL produces or maintains live under `.marshal/`:

- `skills/<name>/SKILL.md` — one folder per skill.
- `agents/<name>.md` — one file per subagent.
- `rules/<name>.md` — one file per rule (frontmatter: `description`,
  `applies-to`, `always-apply`).
- `knowledge/...` — read in place; **not** part of the sync source.
- `AGENTS.md` — a snippet to merge **manually** into the host repo's
  root `AGENTS.md` (which is the file the sync tool requires at its
  source root).

MARSHAL agents may **create or update** any of skills / agents / rules
on request, or as part of stage 7 Learn when a recurring lesson is worth
promoting. Diffs go through the autonomy gate in `.marshal/config.yml`.

To fan these out into tool-native layouts (Cursor, Claude Code, GitHub
Copilot, JetBrains Junie), point
[ai-dev-agent-config-sync](https://github.com/crestreach/ai-dev-agent-config-sync)
at `.marshal/` as its source root — see `marshal.md` § Generated assets
and config sync.

## Marshal-shipped agents (subagents)

These do not exist yet in v1. The skills above mark in their bodies which
operations are good candidates to be promoted to dedicated subagents with
fresh context. Proposed names: `marshal-driver`, `marshal-researcher`,
`marshal-knowledge-curator`, `marshal-code-archaeologist`,
`marshal-planner`, `marshal-reviewer`. Stubs live in `.marshal/agents/`.

## What this entry point is not

- It is **not** the place for repo-specific facts. Those go under
  `.marshal/knowledge/`.
- It is **not** the place for tool-specific configuration. That comes from
  the config-sync mechanism.
- It is **not** the project's `AGENTS.md`. That stays user-owned at the
  repo root.
