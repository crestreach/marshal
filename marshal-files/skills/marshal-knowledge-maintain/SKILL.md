---
name: marshal-knowledge-maintain
description: Maintain the MARSHAL knowledge layer. Modes - from-changes (after an implementation cycle), from-learning (after stage 7 Learn), rescan (full sweep). Updates topic files and indexes; splits oversize topics into sub-indexes recursively; respects autonomy mode.
---

# marshal-knowledge-maintain

Knowledge skill. For larger reconciliation see
[`marshal-knowledge-branch-merge`](../marshal-knowledge-branch-merge/SKILL.md)
and [`marshal-knowledge-rebuild`](../marshal-knowledge-rebuild/SKILL.md).

## When to use

- After an implementation cycle that changed code → mode `from-changes`.
- At the end of MARSHAL stage 7 (Learn) → mode `from-learning`.
- On demand or schedule → mode `rescan`.

## Prerequisites

- `.marshal/knowledge/` initialized (run `marshal-knowledge-init`
  first).
- For `from-changes`: a list of changed paths or a git diff range.
- For `from-learning`: structured items already dropped into
  `.marshal/knowledge/learn/inbox/` (typically by `marshal-learn`).

## Inputs (read at start)

- Mode + mode-specific inputs (above).
- [`.marshal/config.yml`](../../config.yml) — autonomy, size caps,
  `knowledge.contract_ref`, and `knowledge.representation_ref`.
- `.marshal/knowledge/INDEX.md` and any topic indexes for affected
  areas.
- General knowledge contract named by `knowledge.contract_ref` (default
  [`../../references/knowledge-contract.md`](../../references/knowledge-contract.md)).
- Active knowledge implementation named by `knowledge.representation_ref`
  (default
  [`../../references/knowledge-markdown-spine.md`](../../references/knowledge-markdown-spine.md)).
- [`../../references/activation-protocol.md`](../../references/activation-protocol.md)
- [`../../references/promotion-rules.md`](../../references/promotion-rules.md)

## Workflow (shared)

1. Read entry point + knowledge contract + active implementation +
  relevant indexes.
2. Run mode-specific logic (see below).
3. Refresh `summary`, `repo_paths`, `updated`,
   `verified_against_commit` on touched files.
4. **Check size limits** on every touched file (see *Multi-level
   splits* below). Propose splits where needed.
5. Regenerate every affected `INDEX.md`. Cap each at
   `knowledge.subindex_max_lines` (default 150) — if an index would
   exceed the cap, split the folder it covers further (see below).
6. Propose a unified diff. Apply after human approval (or directly in
   `auto` autonomy mode).

## Multi-level splits

Knowledge files are kept small enough to be cheap to load. Limits live
in [`.marshal/config.yml`](../../config.yml):

- `knowledge.topic_max_lines` (default 400) — soft cap for a topic file.
- `knowledge.subindex_max_lines` (default 150) — cap for any sub-index.
- `knowledge.root_index_max_lines` (default 150) — cap for root INDEX.md.

When a topic file exceeds its cap, propose converting it into a folder:

```
before:
  domains/payments/logic.md           (650 lines)

after:
  domains/payments/logic/INDEX.md     (sub-index, capped)
  domains/payments/logic/<sub>.md     (one per subtopic)
```

Rules:

- Pick the **best split dimension** for the topic. Common dimensions:
  by component, by concern (read/write, sync/async), by feature, by
  lifecycle stage, by entity, by API surface, by time. Document the
  chosen dimension in the new sub-index's body.
- A sub-folder may itself contain another sub-folder — there is **no
  fixed depth**. Apply the same rule recursively whenever a subtopic
  exceeds the cap.
- During reviews (and `rescan`), the dimension may be **revised** if a
  better split emerges. Re-splitting is a normal maintenance action;
  surface it as a separate diff.
- Empty or near-empty subtopics should be merged back into the parent.
- Frontmatter is rewritten to fit each new file (split `repo_paths`,
  re-derive `summary`, keep one `id` per file).

## Modes

### `from-changes`

For each changed path, find knowledge files whose `repo_paths`
intersect. Re-verify the relevant claims against current code. Propose
patches.

### `from-learning`

Process `learn/inbox/`. See
[`promotion-rules.md`](../../references/promotion-rules.md). Promote
durable items into canonical files; archive one-off items into
`learn/rollups/`; reject the rest.

### `rescan`

For every knowledge file, diff `repo_paths` between
`verified_against_commit` and HEAD. Flag stale; optionally regenerate.
In this mode, also re-evaluate every topic against
`knowledge.topic_max_lines` and every sub-index against
`knowledge.subindex_max_lines`; propose splits where the cap is
exceeded, and propose merges where a subtopic has become trivially
small.

## Outputs

- A unified diff against `.marshal/knowledge/`.
- Regenerated `INDEX.md` files for affected folders.
- A short summary (counts: created / updated / removed / flagged).

## Handoff

- **Caller:** stage skills as listed above (`marshal-implement`,
  `marshal-learn`) or the [`marshal-driver`](../../agents/marshal-driver.md)
  on schedule.
- **Pass back:** the diff (or applied summary in `auto` mode) plus the
  short counts summary.

## Subagent

V2 candidate for heavy modes (large `rescan`, large `from-learning`
batches): [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md).
