---
name: marshal-knowledge-init
description: First-time bootstrap of the MARSHAL knowledge layer. Scans the repo, detects bounded contexts, drafts repo/ and domains/ knowledge files, and builds initial INDEX.md files. Produces a single diff for human approval.
---

# marshal-knowledge-init

Knowledge skill — runs once per repo (typically by `marshal-init`).

## Prerequisites

- `.marshal/` scaffolding exists (see
  [`marshal-init`](../marshal-init/SKILL.md)).
- `.marshal/knowledge/` is empty or near-empty.

## Inputs (read at start)

- Repo source tree (read-only).
- Build / package manifests for language and dependency hints.
- Contract config: [`../../config.yml`](../../config.yml) (`knowledge.contract_ref`).
- Implementation config: [`../../config.yml`](../../config.yml) (`knowledge.representation_ref`).
- Default contract: [`../../references/knowledge-contract.md`](../../references/knowledge-contract.md).
- Default implementation: [`../../references/knowledge-markdown-spine.md`](../../references/knowledge-markdown-spine.md).
- [`../../references/activation-protocol.md`](../../references/activation-protocol.md)

## Workflow

1. Detect repo languages, package layout, build tools.
2. Identify bounded contexts (heuristics: top-level package dirs,
   monorepo workspace files, route prefixes, schema modules, service
   boundaries).
3. Follow the knowledge contract and active implementation for storage layout,
   metadata, discovery, and update rules.
4. Draft `repo/{overview, architecture, bounded-contexts, entrypoints,
   build-test-run, conventions}.md`.
5. For each detected domain, draft
   `domains/<name>/{INDEX, purpose, logic, contracts, hotspots,
   tests}.md` skeletons populated with high-level summaries.
6. Stamp every file with `updated: <today>` and
   `verified_against_commit: <HEAD short SHA>`.
7. Generate root `INDEX.md` and per-folder `INDEX.md` files from
   frontmatter (one-line `summary` per file, ordered by `importance`).
8. Cap files against the limits in [`config.yml`](../../config.yml):
   `knowledge.root_index_max_lines` for `INDEX.md`,
   `knowledge.subindex_max_lines` for per-folder indexes,
   `knowledge.topic_max_lines` for topic files. If a draft exceeds its
   cap, split it (see
   [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
   *Multi-level splits*) before presenting the diff. Splits may nest
   recursively; pick the most natural dimension per topic and record
   it in the resulting sub-index.
9. Present the entire generated tree as one unified diff for human
   approval (or apply directly in `auto` autonomy mode).

## Outputs

- `.marshal/knowledge/repo/*.md`
- `.marshal/knowledge/domains/<name>/*.md` (one folder per detected
  context)
- `.marshal/knowledge/INDEX.md` and per-folder `INDEX.md` files

## Exit criteria

- Knowledge tree exists and is approved (or applied under `auto`).
- All files carry valid frontmatter and a current
  `verified_against_commit`.

## Handoff

- **Caller:** typically [`marshal-init`](../marshal-init/SKILL.md).
- **Pass back:** a summary of detected contexts and any heuristics
  that could not be resolved (open follow-ups for the human).

## Subagent

V2 candidate:
[`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md)
runs this in fresh context and returns a single proposed diff.
