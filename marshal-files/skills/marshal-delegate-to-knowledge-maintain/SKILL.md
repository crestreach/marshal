---
name: marshal-delegate-to-knowledge-maintain
description: Maintain the MARSHAL knowledge layer. Delegate when the user asks to "update the knowledge tree from this diff / commit range", "promote learnings from learn/inbox/", "rescan the knowledge tree", "refresh stale knowledge files", "split oversize topics", "sweep the knowledge layer", "update knowledge after this implementation cycle", "after stage 7 promote inbox items into canonical files". Modes — `from-changes` (after an implementation cycle that changed code), `from-learning` (after stage 7 Learn), `rescan` (full sweep). The subagent (curator) updates topic files and indexes, splits oversize topics into sub-indexes recursively, respects autonomy mode, and returns a unified diff.
---

# marshal-delegate-to-knowledge-maintain

Delegate this to the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent in mode `from-changes`, `from-learning`, or `rescan`. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-knowledge-curator`
- **Mode:** one of `from-changes` | `from-learning` | `rescan`
- **Pass (request-specific only):**
  - The **intent** (what knowledge update is wanted), always.
  - `from-changes`: a list of changed paths or a git diff range.
  - `from-learning`: paths to the inbox items to promote.
  - `rescan`: nothing extra — operates on the whole tree vs HEAD.
  - The agent reads `.marshal/config.yml`, the knowledge contract / implementation, and the indexes itself — do not pass them.
- **Expect back:** a **summary** of what changed (counts: created / updated / removed / flagged) — not the full knowledge diff.
- **On result:** under `knowledge.autonomy: auto` (default) it is already applied — read the summary. Under `review`, approve the diff. For larger restructures, escalate to [`marshal-delegate-to-knowledge-rebuild`](../marshal-delegate-to-knowledge-rebuild/SKILL.md).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-maintain`](../../skills-fallback/marshal-knowledge-maintain/SKILL.md). Source of truth: [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md).
