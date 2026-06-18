# Knowledge Implementation — MARSHAL Markdown Spine

The default MARSHAL knowledge implementation is **MARSHAL Markdown Spine**.
It stores canonical knowledge as small markdown files under `.marshal/knowledge/`, organized as a hierarchical, progressively-disclosed tree.

This implementation satisfies the general [knowledge contract](knowledge-contract.md), which carries the goals, the two-tree separation, and the read-order rationale.
This file is the **single source of truth for the knowledge layout, metadata, indexing, splitting / merging, and staleness mechanics** — other MARSHAL files refer here instead of restating them, so the description stays in one place.
Agents read this file before creating, reading, updating, splitting, merging, or rebuilding knowledge in the markdown tree.

## The spine: a recursive tree of nodes

"Spine" is the always-loaded index backbone — the root `INDEX.md` plus the folder indexes — that holds the body of knowledge together.
Topic files hang off the spine and are pulled in only when needed.

Every node in the tree is one of:

- **Topic** — a single markdown file `<slug>.md` (frontmatter + body): one coherent unit of knowledge.
- **Group** — a folder `<slug>/` holding an `INDEX.md` (its sub-index) plus child nodes.
  A group is created when a topic outgrows its size cap, or when an area naturally has several parts.

Groups nest **to any depth**: a child of a group can itself be a group.
There is no fixed number of levels — the tree is as deep as the knowledge needs and no deeper.

Read order is always: root `INDEX.md` → the group `INDEX.md` for the area you need → the specific topic file.
Load the cheap index first and descend only into the branch you need.

## Organizing dimension (chosen, not fixed)

The tree is **not** a fixed schema.
How knowledge is grouped at each level — its **split dimension** — is chosen by the curator (`init` / `rebuild`) to be whatever makes the knowledge easiest for a later agent to find:

- by **subsystem / service / module**,
- by **domain** (area of the product),
- by **layer** (api / domain / data / infra),
- by **concern** (logic, contracts, tests, hotspots, conventions),
- by **feature**, **entity**, **API surface**, **lifecycle**, or **time** — or any other dimension that fits.

Rules:

- The dimension may **differ between siblings and between levels**: one group may split by subsystem while another splits by concern.
- Record the chosen dimension in the group's `INDEX.md` so later agents — and any re-split — understand the grouping.
- A `rebuild` (or a `rescan` review) may **re-split a group along a different dimension** when a better one emerges; surface that as its own change.
- When a group becomes trivially small, **merge** it back into its parent.

## Conventional starting layout (a default, adaptable)

`init` typically starts from the layout below, then adapts it to the repo.
Treat it as a sensible default, **not** a required shape — areas may be renamed, split further, merged, or organized along a different dimension.

```text
.marshal/knowledge/
  INDEX.md            # always-loaded root index: links the top-level areas
  repo/               # repo-wide facts not owned by a single area
    INDEX.md
    overview.md       # what this repo is; top-level layout
    architecture.md   # high-level shape, layering, key flows
    subsystems.md     # map of subsystems / domains and their boundaries
    entrypoints.md    # handlers, jobs, CLIs, public APIs
    build-test-run.md # canonical build / test / run commands
    conventions.md    # repo-specific conventions (only if not already in synced rules)
  domains/            # deep knowledge per subsystem / domain — one group each
    <area>/
      INDEX.md        # sub-index; records this group's split dimension
      purpose.md      # what this area is for
      logic.md        # business logic, rules, invariants
      contracts.md    # APIs, schemas, events
      hotspots.md     # risky / frequently-touched spots
      tests.md        # test seams and coverage notes
  decisions/          # lightweight ADRs
    adr-NNNN-<slug>.md
  learn/
    inbox/            # raw phase learnings awaiting promotion (consumed by from-learning)
```

`domains/<area>/` is one **group** per subsystem / domain; any of its topics may itself become a group when it grows (e.g. `domains/payments/logic/` with its own sub-index).
`decisions/` and `learn/inbox/` are fixed parts of the pipeline.
Knowledge content covers code facts, logic, architecture, design rationale, decisions, and conventions — not just code.

## Frontmatter

Every topic and every `INDEX.md` starts with:

```yaml
---
id: domains/payments/contracts        # stable slug, matches path
kind: overview|architecture|logic|contract|schema|convention|guide|reference|decision|index
summary: One-line description (used verbatim in the parent INDEX.md).
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

- Required: `id`, `kind`, `summary`, `importance`, `confidence`, `updated`.
- Recommended: `repo_paths` (enables staleness detection), `verified_against_commit`.
- On a group `INDEX.md`, also note the **split dimension** (in the body or a `dimension:` field) so the grouping is self-describing.

### Kinds

`kind` classifies what a file describes, so an agent can tell at a glance how to use it:

- `overview` — what something is: purpose, scope, orientation.
- `architecture` — structure, components, boundaries, and how the pieces fit and flow.
- `logic` — behavior: business rules, invariants, algorithms.
- `contract` — interfaces between parts: APIs, RPC / CLI signatures, events / topics.
- `schema` — data shapes: database schemas, message / payload formats, config / types.
- `convention` — repo-specific standards and patterns.
- `guide` — procedures: build / test / run, runbooks, how-to steps.
- `reference` — factual lookups and maps (e.g. entrypoints, command lists).
- `decision` — a decision record with its rationale (ADR).
- `index` — a folder or sub-index (`INDEX.md`) file.

## Index rules

- **Discovery is the source of truth.**
  A directory walk plus frontmatter defines what exists; a file dropped from an `INDEX.md` is not lost.
- **Every `INDEX.md` is regenerated**, never hand-edited except to fix a bug in the index logic itself.
- Each `INDEX.md` lists its node's **direct children** as `- [path](path): summary`, ordered by `importance` then tree position.
- The root `INDEX.md` lists the **top-level areas** only, not every leaf.
  This is progressive disclosure, not omission: every file stays reachable through the hierarchy (root → group `INDEX.md` → topic), so an agent loads the cheap root first and descends only into the branch it needs.

## Size limits, splitting, and merging

- Caps live in `.marshal/config.yml`: `root_index_max_lines`, `subindex_max_lines`, `topic_max_lines`.
- When a **topic** exceeds `topic_max_lines`, convert it into a **group**: a folder with an `INDEX.md` plus subtopic files, split along a chosen dimension (see *Organizing dimension*).
- When an **`INDEX.md`** exceeds its cap, split the area it covers further.
- Splits **recurse with no fixed depth**; merge trivially-small groups back into their parent.

## Staleness

A file is **stale** when any path in its `repo_paths` has changed in git between `verified_against_commit` and current HEAD.
Detection is on demand via `marshal-knowledge-maintain` (mode `from-changes` or `rescan`); there are no git hooks.

Staleness can also surface **while reading**: if an agent using a topic finds it no longer matches the code (drifted `repo_paths`, outdated facts), it treats the entry as stale and re-researches the topic — refreshing the knowledge (via the curator) rather than trusting the stale entry.

## Update protocol

All writes follow `knowledge.autonomy` in `.marshal/config.yml`:

- `review`: produce a unified diff and wait for human approval.
- `auto`: apply the update directly and report the changed files.

Update paths:

- `marshal-knowledge-init` creates the initial tree and indexes from this implementation reference.
- `marshal-knowledge-maintain from-changes` re-verifies files whose `repo_paths` intersect changed paths and refreshes touched indexes.
- `marshal-knowledge-maintain from-learning` promotes approved learning items from `learn/inbox/` into canonical knowledge and drops the rest.
- `marshal-knowledge-maintain rescan` checks every knowledge file for staleness and size-limit violations.
- `marshal-knowledge-branch-merge` reconciles divergent knowledge updates across branches.
- `marshal-knowledge-rebuild` may restructure the tree after major repo changes, including re-splitting groups along a better dimension.

## Possible future extensions

These are not implemented; they are recorded here as directions the implementation may grow into.
The markdown tree remains the canonical source of truth even if any of them is added.

- **Generated maps** — a `generated/` group of mechanically-built maps (e.g. `symbol-map.md`, `dependency-map.md`) produced with tree-sitter / ctags / LSP, useful for medium-to-large repos.
- **Vector retrieval sidecar** — an embedding-based index alongside the markdown tree for fuzzy recall.
- **Cross-repo / user-scoped knowledge** — knowledge shared beyond a single repository. The current scope is repo-only.
