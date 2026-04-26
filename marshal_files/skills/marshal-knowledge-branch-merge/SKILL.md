---
name: marshal-knowledge-branch-merge
description: Reconcile MARSHAL knowledge files diverged on two branches (typically during a merge). Handles git-level conflicts in knowledge files and content-level reconciliation when both sides updated different files in overlapping areas.
---

# marshal-knowledge-branch-merge

Knowledge skill — invoked at merge time.

## When to use

- Merging a feature branch into the trunk (or vice versa) when both
  sides changed files under `.marshal/knowledge/`.
- Resolving a git conflict in a knowledge file.
- Reconciling content even when there is no textual conflict, but two
  branches independently added domain notes in overlapping areas.

## Prerequisites

- A working tree with both branches reachable (or merge base + two
  heads identifiable).

## Inputs (read at start)

- Two branch refs (or merge base + two heads).
- Optional: a list of files to focus on.
- [`../../references/knowledge-format.md`](../../references/knowledge-format.md)
- [`../../references/activation-protocol.md`](../../references/activation-protocol.md)

## Workflow

1. Compute the set of knowledge files touched on either side since the
   merge base.
2. Classify each:
   - **Identical** → keep.
   - **Disjoint frontmatter** → field-level merge:
     - `repo_paths`: set union.
     - `verified_against_commit`: newest wins.
     - `updated`: latest wins.
     - `summary`: 3-way merge candidate; flag if both sides changed.
     - `body`: 3-way merge if textually conflicting.
   - **Overlapping body** → propose a 3-way merge with annotated
     diffs.
   - **Both sides created the same `id`** → flag for human resolution.
3. Identify content-level overlaps (different files but same
   `repo_paths` region, or contradictory `summary` lines).
4. Propose a unified diff for the merged knowledge tree.
5. Regenerate every affected `INDEX.md`.

## Outputs

- A unified diff against `.marshal/knowledge/`.
- A list of items requiring explicit human resolution.

## Handoff

- **Caller:** the human running the merge, or
  [`marshal-driver`](../../agents/marshal-driver.md) if orchestrating.
- **Pass back:** the diff plus the human-resolution list.

## Subagent

V2 candidate:
[`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md).
