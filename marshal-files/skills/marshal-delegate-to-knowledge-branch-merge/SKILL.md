---
name: marshal-delegate-to-knowledge-branch-merge
description: Reconcile MARSHAL knowledge files diverged on two branches. Delegate when the user asks to "merge knowledge files from two branches", "resolve a conflict in .marshal/knowledge/", "reconcile knowledge changes between feature branch and trunk", "3-way merge knowledge frontmatter and bodies", "handle overlapping repo_paths between branches", "two branches independently added domain notes — merge them". Use at merge time when both sides changed `.marshal/knowledge/`, when there's a git conflict in a knowledge file, or when both branches added content in overlapping areas without textual conflict. The subagent (curator in mode `branch-merge`) returns a unified diff plus a list of items needing human resolution.
---

# marshal-delegate-to-knowledge-branch-merge

Delegate this to the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent in mode `branch-merge`. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-knowledge-curator`
- **Mode:** `branch-merge`
- **Pass (request-specific only):** the intent (what the merge is for), two branch refs (or merge base + two heads), and an optional file focus list. The agent reads `.marshal/config.yml`, the knowledge contract / implementation, and the knowledge tree itself — do not pass them.
- **Expect back:** a **summary** of what was merged and, in `review` mode, the list of items needing explicit human resolution. Not the full knowledge diff.
- **On result:** under `knowledge.autonomy: auto` (default) the merge is already applied — read the summary. Under `review`, resolve the flagged items with the human and approve.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-branch-merge`](../../skills-fallback/marshal-knowledge-branch-merge/SKILL.md). Source of truth: [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md).
