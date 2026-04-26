---
name: marshal-knowledge-curator
description: Fresh-context knowledge maintenance subagent. Wraps the heavy paths of marshal-knowledge-init, marshal-knowledge-maintain, marshal-knowledge-rebuild, and marshal-knowledge-branch-merge. Always returns a single proposed diff to the caller for approval.
---

# marshal-knowledge-curator

**Draft — v2 subagent.** Not yet implemented; structure only.

## Purpose

Heavy knowledge operations — initial bootstrap, full rescan, post-feature
rebuild, branch-merge reconciliation, large `from-learning` batches —
benefit from running in an isolated context. The curator wraps those
skills and returns a single unified diff for the caller to approve.

## When to invoke

- First-time setup of `.marshal/knowledge/` in a new repo.
- After a sizable feature lands (rebuild).
- During a merge whose two branches both touched the knowledge tree.
- On schedule, for a full rescan.
- For batch promotion of accumulated `learn/inbox/` items.

## Inputs

- Mode: `init` | `rebuild` | `branch-merge` | `rescan` | `from-learning`.
- Mode-specific inputs:
  - `init`: empty or near-empty `.marshal/knowledge/`.
  - `rebuild`: a feature branch / commit range to incorporate.
  - `branch-merge`: the two commits / branches whose knowledge trees
    diverged.
  - `rescan`: nothing (operates on whole tree vs HEAD).
  - `from-learning`: contents of `.marshal/knowledge/learn/inbox/`.

## Outputs

- A unified diff against `.marshal/knowledge/`, plus regenerated
  `INDEX.md` files.
- A short summary: counts (created / updated / removed / flagged), top
  rationale, open questions.
- Never auto-applied unless `.marshal/config.yml` sets
  `knowledge.autonomy: auto`.

## Workflow

1. Read entry point + relevant indexes.
2. Dispatch the matching skill:
   - [marshal-knowledge-init](../skills/marshal-knowledge-init/SKILL.md)
   - [marshal-knowledge-maintain](../skills/marshal-knowledge-maintain/SKILL.md)
     (modes `from-changes`, `from-learning`, `rescan`)
   - [marshal-knowledge-branch-merge](../skills/marshal-knowledge-branch-merge/SKILL.md)
   - [marshal-knowledge-rebuild](../skills/marshal-knowledge-rebuild/SKILL.md)
3. For each touched file: refresh `summary`, `repo_paths`, `updated`,
   `verified_against_commit`. Apply the field-level merge rules from
   [knowledge-format](../references/knowledge-format.md) and
   [promotion-rules](../references/promotion-rules.md).
4. Regenerate every affected `INDEX.md` from frontmatter.
5. Build the unified diff and the summary.

## Delegation / handoff contract

- Output is **a diff plus a summary**, not applied changes (default).
- Heavy reads (full tree walks) happen here, so the parent context stays
  light.

## Out of scope

- Authoring net-new repo knowledge from scratch on a topic the curator
  cannot derive — call `marshal-researcher` first.
- Process artifacts (`change-brief.md`, `delivery-plan.md`, etc.).
