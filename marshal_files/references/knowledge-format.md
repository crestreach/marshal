# Knowledge Format — reference

Shared by all `marshal-knowledge-*` skills. Single source of truth for the
file layout, frontmatter, and index conventions.

See also: [knowledge-design.md](../../../../_notes/knowledge-design.md) for
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

- **Discovery is source of truth.** A directory walk + frontmatter defines
  what exists. Files dropped from an `INDEX.md` are not lost.
- **Every `INDEX.md` is regenerated**, never hand-edited (except to fix
  bugs in the index logic itself).
- Each `INDEX.md` lists files in its scope as
  `- [path](path): summary` ordered by `importance` then tree position.
- The root `INDEX.md` lists folder indexes only (not every leaf file).
- Cap on root: ~150 lines (configurable in `.marshal/config.yml`).

## Staleness

A file is **stale** when any path in its `repo_paths` has changed in git
between `verified_against_commit` and current HEAD. Detection is on demand
via `marshal-knowledge-maintain` (mode `from-changes` or `rescan`). There
are no git hooks.
