# Knowledge Implementation — MARSHAL Markdown Spine

The default MARSHAL knowledge implementation is **MARSHAL Markdown Spine**.
It stores canonical knowledge as small markdown files under
`.marshal/knowledge/`, with a root index, folder indexes, and progressively
disclosed topic files.

It is active when `.marshal/config.yml` sets:

```yaml
knowledge:
  contract_ref: references/knowledge-contract.md
  representation_ref: references/knowledge-markdown-spine.md
```

This implementation satisfies the general
[knowledge contract](knowledge-contract.md). Agents read this file before
creating, reading, updating, splitting, merging, or rebuilding knowledge in
the markdown tree.

See also: [knowledge-design.md](../design/knowledge-design.md) for design
rationale.

## Tree

```text
.marshal/knowledge/
  INDEX.md                       # always-loaded; root index
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
  decisions/
    adr-NNNN-<slug>.md
  generated/                     # mechanical, v1.5+
  learn/
    inbox/                       # raw phase learnings (Marshal §5)
    rollups/                     # promoted, deduped
```

Knowledge content covers code facts, logic, architecture, design rationale,
decisions, and conventions — not just code.

## Frontmatter

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

Required: `id`, `kind`, `summary`, `importance`, `confidence`, `updated`.
Recommended: `repo_paths` (enables staleness detection),
`verified_against_commit`.

## Index rules

- **Discovery is source of truth.** A directory walk plus frontmatter defines
  what exists. Files dropped from an `INDEX.md` are not lost.
- **Every `INDEX.md` is regenerated**, never hand-edited except to fix bugs
  in the index logic itself.
- Each `INDEX.md` lists files in its scope as `- [path](path): summary`,
  ordered by `importance` then tree position.
- The root `INDEX.md` lists folder indexes only, not every leaf file.
- Cap on root: ~150 lines, configurable in `.marshal/config.yml`.

## Staleness

A file is **stale** when any path in its `repo_paths` has changed in git
between `verified_against_commit` and current HEAD. Detection is on demand
via `marshal-knowledge-maintain` (mode `from-changes` or `rescan`). There
are no git hooks.

## Update protocol

All writes follow the autonomy setting in `.marshal/config.yml`:

- `review`: produce a unified diff and wait for human approval.
- `auto`: apply the update directly and report the changed files.

Update paths:

- `marshal-knowledge-init` creates the initial tree and indexes from this
  implementation reference.
- `marshal-knowledge-maintain from-changes` re-verifies files whose
  `repo_paths` intersect changed paths and refreshes touched indexes.
- `marshal-knowledge-maintain from-learning` promotes approved learning
  items from `learn/inbox/` into canonical knowledge or archives them in
  `learn/rollups/`.
- `marshal-knowledge-maintain rescan` checks every knowledge file for
  staleness and size-limit violations.
- `marshal-knowledge-branch-merge` reconciles divergent knowledge updates
  across branches.
- `marshal-knowledge-rebuild` may restructure the tree after major repo
  changes.

When topic or index files exceed configured size caps, split them into a
sub-index plus smaller topic files. Splits may recurse without a fixed
depth. When subtopics become trivial, merge them back into the parent.