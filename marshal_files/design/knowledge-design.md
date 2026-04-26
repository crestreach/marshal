# MARSHAL Knowledge Layer — Design

Status: **draft v0.1** — agreed direction, details to be refined as skills are built out.
Companion to [marshal.md](../../marshal.md).

This document describes how MARSHAL stores agent-managed memory and knowledge
about a repository, and how it interacts with the existing tool-agnostic
configuration sync mechanism.

## 1. Goals

- Give agents a **reliable map of where to look next** without loading half
  the repo into context.
- Separate **stable repo knowledge** (logic, architecture, conventions,
  invariants) from **process learnings** (per-phase outputs of MARSHAL).
- Make knowledge **diffable and reviewable** (markdown in git).
- Allow **progressive disclosure** — only the smallest relevant slice loads
  at any time.
- Allow knowledge to **evolve with the code** without git hooks or background
  daemons, via explicit dated stamps and an explicit maintenance skill.
- Keep the system **tool-agnostic** by piggybacking on the existing
  config-sync mechanism for any tool-facing assets, and keeping the
  knowledge body itself in a single Marshal-owned format.

## 2. Two trees, two mechanisms

MARSHAL keeps a clean separation:

| Tree | Owner | Content | Synced to tool layouts? |
|---|---|---|---|
| `<user-config-source>/` | user / project / company | project-specific `agents/`, `skills/`, `rules/`, `mcp-servers/`, `AGENTS.md` | yes, via [ai-dev-agent-config-sync](https://github.com/crestreach/ai-dev-agent-config-sync) |
| `.marshal/` (config-sync source) | MARSHAL baseline | `marshal-*`-prefixed `agents/`, `skills/`, `rules/`, `mcp-servers/`, plus `AGENTS.md` | yes, via the same sync tool, run separately against `.marshal/` |
| `.marshal/knowledge/` | agents (under human approval) | repo knowledge: code notes, logic, architecture, decisions, learnings | **no** — read directly via the entry point |

Two separate sync invocations cover both authored trees. The knowledge tree
is never synced — agents read it directly through `.marshal/ENTRYPOINT.md`.

## 3. Entry point

`.marshal/AGENTS.md` is intentionally short. Its only job is to make every
tool's instruction file (after sync) say something like:

> This repo uses MARSHAL. Before doing repo work, read `.marshal/ENTRYPOINT.md`.

`.marshal/ENTRYPOINT.md` is the rich, agent-targeted entry point. It
contains the minimum context an agent needs to operate efficiently in a
fresh session:

- A short summary of MARSHAL itself (link to `marshal.md` for detail).
- The knowledge format spec (or a pointer to it).
- The read order: `ENTRYPOINT.md` → `knowledge/INDEX.md` → topic indexes →
  topic files.
- The list of `marshal-*` skills/agents available, by name, with one-line
  descriptions.
- The autonomy mode and approval rules.
- The location of `.marshal/config.yml` and how to read its flags.

The top-level project `AGENTS.md` (user-owned) only needs a one-line
reference to `.marshal/ENTRYPOINT.md` so non-Marshal-aware tooling still
finds it.

## 4. Knowledge tree layout

```text
.marshal/
  AGENTS.md                        # short pointer; gets synced
  ENTRYPOINT.md                    # rich entry point; read by Marshal-aware agents
  config.yml                       # autonomy, scan policy, paths
  design/                          # design docs for the Marshal layer itself
  references/                      # shared reference bundle (format, activation, promotion)
  agents/                          # marshal-* subagent definitions (synced)
  skills/                          # marshal-* skills (synced)
  rules/                           # marshal-* rules (synced)
  mcp-servers/                     # marshal-* MCP cards (synced; optional)
  knowledge/                       # NOT synced
    INDEX.md                       # always-loaded; link list + 1-line summaries
    repo/
      INDEX.md
      overview.md
      architecture.md
      bounded-contexts.md
      entrypoints.md
      build-test-run.md
      conventions.md
    domains/
      <domain>/
        INDEX.md
        purpose.md
        logic.md                   # business logic, rules, invariants
        contracts.md               # APIs, schemas, events
        hotspots.md
        tests.md
    decisions/                     # lightweight ADRs
      adr-NNNN-<slug>.md
    generated/                     # mechanically built; v1.5+
      symbol-map.md
      dependency-map.md
    learn/
      inbox/                       # raw per-phase learning files
      rollups/                     # promoted, deduped
```

Knowledge content is **not limited to code facts**. It also covers logic,
architectural rationale, design notes, decisions, and conventions — anything
that helps an agent reason about *why* the code is shaped the way it is.

## 5. File frontmatter contract

Every knowledge file starts with:

```yaml
---
id: domains/payments/contracts        # stable slug, matches path
kind: reference|how-to|explanation|decision|generated
summary: One-line description (used verbatim in INDEX.md).
repo_paths:
  - "src/billing/**"
  - "src/payments/**"
parent: domains/payments/INDEX        # optional
children: []                          # optional
links: [repo/architecture]            # optional cross-refs
importance: high|medium|low
confidence: high|medium|low
updated: 2026-04-26                   # ISO date
verified_against_commit: 0a3f75e      # short SHA
---
```

`repo_paths` + `verified_against_commit` are how staleness is detected.
There are no git hooks; the maintenance skill explicitly diffs HEAD against
the recorded SHA on demand or on schedule.

## 6. Index strategy: hybrid

- **Discovery is the source of truth.** A directory walk plus frontmatter
  authoritatively defines what knowledge exists. No file is "lost" if
  dropped from any index.
- **`INDEX.md` is regenerated, not hand-edited.** Each `INDEX.md` lists its
  scope's files with their `summary` from frontmatter, ordered by
  `importance` then tree position.
- **Per-folder `INDEX.md`** at every level keeps the always-loaded root
  index short. Agents follow indexes downward.
- **Root `INDEX.md`** is the only knowledge file the entry point asks
  agents to load by default. Cap: ~150 lines.

## 7. Activation pattern

Single mode in v1: **pull / progressive disclosure.**

1. The tool's instruction file (synced from `.marshal/AGENTS.md`) tells the
   agent to read `.marshal/ENTRYPOINT.md`.
2. `ENTRYPOINT.md` instructs the agent to read `knowledge/INDEX.md`.
3. The agent descends into the topic indexes and topic files it needs.
4. If a needed topic is missing or stale, the agent invokes
   `marshal-knowledge-research` to gather a condensed delta, then optionally
   feeds it back via `marshal-knowledge-maintain`.

Path-scoped auto-attach (Cursor/Claude rules style) is **not** used for
knowledge in v1. That activation mode is already covered by the existing
config-sync rules mechanism.

## 8. Staleness model (no hooks)

- `verified_against_commit` + `updated` are stamped on every file.
- The maintenance skill modes do the work explicitly:
  - **`from-changes`** — invoked after an implementation cycle; diffs HEAD
    against `verified_against_commit` for each file's `repo_paths` and
    proposes patches.
  - **`from-learning`** — promotes items from `learn/inbox/` to canonical
    files (or `learn/rollups/`), aligned with marshal.md §5.
  - **`rescan`** — full sweep; flags or refreshes stale files.
  - (separate skills) `marshal-knowledge-branch-merge` and
    `marshal-knowledge-rebuild` for the larger reconciliation cases.
- All write paths produce a diff for human approval unless
  `knowledge.autonomy: auto` is set in `.marshal/config.yml`.

## 9. Approval and autonomy

```yaml
# .marshal/config.yml
knowledge:
  autonomy: review        # review | auto
  rescan_period_days: 30  # advisory; rescan must be triggered explicitly
```

`review` is the default. `auto` is intended for later, after the system
proves trustworthy on the repo.

## 10. Skills (v1) and subagent candidates (v2)

All entries below live under `.marshal/skills/<name>/SKILL.md` and follow
the Anthropic Agent Skills format used by the config-sync tool.

| Skill | Purpose | v2 subagent candidate |
|---|---|---|
| `marshal-load` | Session bootstrap: read entry point + INDEX. | — |
| `marshal-init` | First-time Marshal setup in a repo (creates `.marshal/`, configs, runs knowledge-init). | — |
| `marshal-knowledge-init` | Build initial knowledge snapshot from current code. | `marshal-knowledge-curator` |
| `marshal-knowledge-maintain` | Modes: `from-changes`, `from-learning`, `rescan`. | `marshal-knowledge-curator` |
| `marshal-knowledge-research` | Topic / codebase deep-dive returning a condensed delta. | `marshal-researcher` |
| `marshal-knowledge-branch-merge` | Reconcile knowledge files diverged on two branches. | `marshal-knowledge-curator` |
| `marshal-knowledge-rebuild` | Post-feature rescan to incorporate new / deleted code and changed logic. | `marshal-knowledge-curator` |
| `marshal-specify` | Stage 1 (optional) — produce `specification.md`. | `marshal-driver` (process orchestrator) |
| `marshal-intake` | Stage 2 (optional) — produce `change-brief.md`. | `marshal-driver` (process orchestrator) |
| `marshal-analysis` | Stage 3 (optional) — produce `repo-recon.md`. | `marshal-code-archaeologist` |
| `marshal-architecture` | Stage 3.5 (optional) — produce `architecture-notes.md`. | — |
| `marshal-plan` | Stage 4 (**mandatory**) — produce `delivery-plan.md`. | `marshal-planner` |
| `marshal-implement` | Stage 5a — drive implementation cycles. | — |
| `marshal-verify` | Stage 5b — produce `verification-report.md`. | — |
| `marshal-pr` | Stage 5c (optional) — PR boundary, summary, fixup loop. | `marshal-reviewer` |
| `marshal-rollout` | Stage 6 (optional) — produce `rollout-note.md`. | — |
| `marshal-learn` | Stage 7 (optional) — produce `learning-rollup.md` and feed `marshal-knowledge-maintain from-learning`. | — |

## 11. Shared bundle

The format spec lives in **one** place — a top-level shared folder under
`.marshal/` — referenced by every skill and subagent that needs it:

```text
.marshal/references/
  knowledge-format.md            # frontmatter + tree layout spec
  activation-protocol.md         # read order, autonomy, approval
  promotion-rules.md             # what is promotable from learning files
```

Knowledge skills (`marshal-knowledge-*`) and subagents (`marshal-researcher`,
`marshal-knowledge-curator`, …) reference these files via relative paths.
Keeping the bundle outside any single skill folder makes it equally
accessible to skills, agents, and any future tooling.

## 12. Out of scope for v1 (future extensions)

- **Generated maps** (`symbol-map.md`, `dependency-map.md`) using
  tree-sitter / ctags / LSP. Useful for medium-large repos. Defer to v1.5.
- **Vector retrieval sidecar** (mem0 / Letta archival style). The markdown
  tree remains canonical truth even if added.
- **Subagents** for the candidates listed in §10. v1 stays skill-only;
  promotion happens once the workflows are proven.
- **`auto` autonomy mode** with non-interactive write paths.
- **Cross-repo / user-scoped memory.** Repo-scoped only in v1.

## 13. Open follow-ups

- Concrete bootstrap heuristics for `marshal-knowledge-init` (how to detect
  bounded contexts in arbitrary repos).
- Branch-merge skill: define exactly which fields of frontmatter are
  treated as conflicting vs. mergeable (e.g. `repo_paths` is a set union;
  `summary` is a 3-way merge candidate; `verified_against_commit` keeps the
  newest).
- Whether `.marshal/AGENTS.md` should be the literal sync source for tool
  instruction files, or if Marshal ships a tool-specific snippet to inject
  alongside the user's existing `AGENTS.md`.
