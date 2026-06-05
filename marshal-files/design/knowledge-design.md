# MARSHAL Knowledge Layer — Design

Status: **draft v0.1** — agreed direction, details to be refined as skills are built out.
Companion to [marshal.md](../../marshal.md).

This document describes how MARSHAL stores agent-managed knowledge about a
repository, and how it interacts with the existing tool-agnostic
configuration sync mechanism. Knowledge is MARSHAL's mid- and long-term
memory, but the term used throughout the system is **knowledge**.

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
  knowledge body behind an exchangeable MARSHAL representation reference.

## 2. Two trees, two mechanisms

MARSHAL keeps a clean separation:

| Tree | Owner | Content | Synced to tool layouts? |
|---|---|---|---|
| `<user-config-source>/` | user / project / company | project-specific `agents/`, `skills/`, `rules/`, `mcp-servers/`, `AGENTS.md` | yes, via [cyncia](https://github.com/crestreach/cyncia) |
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
- The general knowledge contract and active implementation references
  (`knowledge.contract_ref` and `knowledge.representation_ref` in
  `.marshal/config.yml`).
- The read order: `ENTRYPOINT.md` → `knowledge/INDEX.md` → topic indexes →
  topic files.
- The list of `marshal-*` skills/agents available, by name, with one-line
  descriptions.
- The autonomy mode and approval rules.
- The location of `.marshal/config.yml` and how to read its flags.

The top-level project `AGENTS.md` (user-owned) only needs a one-line
reference to `.marshal/ENTRYPOINT.md` so non-Marshal-aware tooling still
finds it.

## 4. Default implementation: MARSHAL Markdown Spine

The default implementation is **MARSHAL Markdown Spine**, documented by
[`../references/knowledge-markdown-spine.md`](../references/knowledge-markdown-spine.md).
The general contract is documented by
[`../references/knowledge-contract.md`](../references/knowledge-contract.md).
The active implementation is configured by `knowledge.representation_ref`
in `.marshal/config.yml`; alternate implementations must satisfy the same
discovery, metadata, update, staleness, and promotion contract.

```text
.marshal/
  AGENTS.md                        # short pointer; gets synced
  ENTRYPOINT.md                    # rich entry point; read by Marshal-aware agents
  config.yml                       # autonomy, scan policy, paths
  design/                          # design docs for the Marshal layer itself
  references/                      # shared reference bundle (format, activation, promotion)
  agents/                          # marshal-* subagent definitions (synced; built-in)
  skills/                          # marshal-* skills (synced; built-in)
  skills-fallback/                 # marshal-* fallback skills (synced; built-in)
  rules/                           # marshal-* rules (synced; built-in)
  mcp-servers/                     # marshal-* MCP cards (synced; optional)
  extensions/                      # repo-specific extensions (mx--prefixed at creation)
    skills/
    agents/
    rules/
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

## 5. Default file frontmatter contract

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

## 6. Default index strategy: hybrid

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
4. If a needed topic is missing or stale, the agent invokes the
   `marshal-researcher` subagent (via `marshal-delegate-to-knowledge-research`)
   to gather a condensed delta, then optionally feeds it back via the
   `marshal-knowledge-curator` subagent (via
   `marshal-delegate-to-knowledge-maintain`).

Path-scoped auto-attach (Cursor/Claude rules style) is **not** used for
knowledge in v1. That activation mode is already covered by the existing
config-sync rules mechanism.

## 8. Staleness model (no hooks)

- `verified_against_commit` + `updated` are stamped on every file.
- The `marshal-knowledge-curator` subagent does the work explicitly via
  modes:
  - **`from-changes`** — invoked after an implementation cycle; diffs HEAD
    against `verified_against_commit` for each file's `repo_paths` and
    proposes patches.
  - **`from-learning`** — promotes items from `learn/inbox/` to canonical
    files (or `learn/rollups/`), aligned with marshal.md §5.
  - **`rescan`** — full sweep; flags or refreshes stale files.
  - **`branch-merge`** and **`rebuild`** — the larger reconciliation cases.
- All write paths produce a diff for human approval unless
  `knowledge.autonomy: auto` is set in `.marshal/config.yml`.

## 9. Approval and autonomy

```yaml
# .marshal/config.yml
knowledge:
  autonomy: auto          # auto | review
  rescan_period_days: 30  # advisory; rescan must be triggered explicitly
```

`auto` is the default: knowledge writes are applied without per-change
approval and a summary of what changed is returned. `review` is the
opt-in stricter mode, producing a full diff for human approval before
each write.

## 10. Subagents and skills

Workflow logic lives in **subagents** under `.marshal/agents/<name>.md`.
For each subagent, two skill wrappers ship: a delegate skill under
`.marshal/skills/marshal-delegate-to-<x>/SKILL.md` (for environments with
subagent support) and a fallback skill under
`.marshal/skills-fallback/marshal-<x>/SKILL.md` (for environments without).

| Subagent | Purpose | Wrapper skills (delegate / fallback) |
|---|---|---|
| `marshal-knowledge-curator` | Knowledge bootstrap + maintenance + reconciliation (modes: `init`, `from-changes`, `from-learning`, `rescan`, `rebuild`, `branch-merge`). | `marshal-delegate-to-knowledge-{init,maintain,rebuild,branch-merge}` / `marshal-knowledge-{init,maintain,rebuild,branch-merge}` |
| `marshal-researcher` | Read-only topic / codebase deep-dive returning a condensed delta. | `marshal-delegate-to-knowledge-research` / `marshal-knowledge-research` |
| `marshal-specifier` | Stage 1 (optional) — produce `specification.md`. | `marshal-delegate-to-specify` / `marshal-specify` |
| `marshal-framer` | Stage 2 (optional) — produce `change-brief.md`. | `marshal-delegate-to-intake` / `marshal-intake` |
| `marshal-code-archaeologist` | Stage 3 (optional) — produce `repo-recon.md`. | `marshal-delegate-to-analysis` / `marshal-analysis` |
| `marshal-architect` | Stage 3.5 (optional) — produce `architecture-notes.md`. | `marshal-delegate-to-architecture` / `marshal-architecture` |
| `marshal-planner` | Stage 4 (**mandatory**) — produce `delivery-plan.md`. | `marshal-delegate-to-plan` / `marshal-plan` |
| `marshal-implementer` | Stage 5a — drive implementation cycles. | `marshal-delegate-to-implement` / `marshal-implement` |
| `marshal-verifier` | Stage 5b — produce `verification-report.md`. | `marshal-delegate-to-verify` / `marshal-verify` |
| `marshal-reviewer` | Stage 5c (optional) — PR boundary, summary, fixup loop. | `marshal-delegate-to-pr` / `marshal-pr` |
| `marshal-releaser` | Stage 6 (optional) — produce `rollout-note.md`. | `marshal-delegate-to-rollout` / `marshal-rollout` |
| `marshal-learner` | Stage 7 (optional) — produce `learning-rollup.md`, draft new repo-specific rules / skills / subagents under `.marshal/extensions/{rules,skills,agents}/` (`mx-` prefix at creation), and feed `marshal-knowledge-curator` mode `from-learning`. | `marshal-delegate-to-learn` / `marshal-learn` |
| `marshal-helper` | On-demand procedural / conceptual help on MARSHAL itself. | `marshal-delegate-to-help` / `marshal-help` |
| `marshal-driver` | Full end-to-end orchestrator across stages. | `marshal-delegate-to-driver` / — |

Main-session skills (no subagent counterpart): `marshal-init`,
`marshal-load`, `marshal-promote-assets`. They live under `.marshal/skills/`
only.

## 11. Shared bundle

The general contract and active implementation references are named by
`knowledge.contract_ref` and `knowledge.representation_ref` in
`.marshal/config.yml`. The default reference bundle lives under
`.marshal/references/`:

```text
.marshal/references/
  knowledge-contract.md          # required capabilities for any implementation
  knowledge-markdown-spine.md    # default implementation
  activation-protocol.md         # read order, autonomy, approval
  promotion-rules.md             # what is promotable from learning files
```

Knowledge skills (`marshal-knowledge-*`) and subagents (`marshal-researcher`,
`marshal-knowledge-curator`, …) read the configured contract and
implementation references plus the shared activation and promotion
references. Keeping the bundle outside any single skill folder makes it
equally accessible to skills, agents, and any future tooling.

## 12. Out of scope for v1 (future extensions)

- **Generated maps** (`symbol-map.md`, `dependency-map.md`) using
  tree-sitter / ctags / LSP. Useful for medium-large repos. Defer to v1.5.
- **Vector retrieval sidecar** (mem0 / Letta archival style). The markdown
  tree remains canonical truth even if added.
- **Subagents** for the candidates listed in §10. v1 stays skill-only;
  promotion happens once the workflows are proven.
- **`auto` autonomy mode** with non-interactive write paths.
- **Cross-repo / user-scoped knowledge.** Repo-scoped only in v1.

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
