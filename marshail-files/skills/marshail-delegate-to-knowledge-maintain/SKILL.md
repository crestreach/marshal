---
name: marshail-delegate-to-knowledge-maintain
description: Maintain the MARSHAIL knowledge layer. Delegate when the user asks to "update the knowledge tree from this diff / commit range", "promote learnings from learn/inbox/", "rescan the knowledge tree", "refresh stale knowledge files", "split oversize topics", "sweep the knowledge layer", "update knowledge after this implementation cycle", "after the Learn stage promote inbox items into canonical files". Modes — `from-changes` (after an implementation cycle that changed code), `from-learning` (after the Learn stage), `rescan` (full sweep). The subagent (curator) updates topic files and indexes, splits oversize topics into sub-indexes recursively, respects autonomy mode, and returns a short summary of what changed (a full diff only in `review` mode).
---

# marshail-delegate-to-knowledge-maintain

Delegate this to the [`marshail-knowledge-curator`](../../agents/marshail-knowledge-curator.md) subagent in mode `from-changes`, `from-learning`, or `rescan`.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-knowledge-curator`
- **Mode:** one of `from-changes` | `from-learning` | `rescan`
- **Pass (request-specific only):**
  - The **intent** (what knowledge update is wanted), always.
  - `from-changes`: a list of changed paths or a git diff range.
  - `from-learning`: paths to the inbox items to promote.
  - `rescan`: nothing extra — operates on the whole tree vs HEAD.
  - The agent reads `.marshail/config.yml`, the knowledge contract / implementation, and the indexes itself — do not pass them.
- **Expect back:** a **summary** of what changed (counts: created / updated / removed / flagged) — not the full knowledge diff.
- **On result:** under `knowledge.autonomy: auto` (default) it is already applied — read the summary.
  Under `review`, approve the diff.
  For larger restructures, escalate to [`marshail-delegate-to-knowledge-rebuild`](../marshail-delegate-to-knowledge-rebuild/SKILL.md).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-knowledge-maintain`](../../skills-fallback/marshail-knowledge-maintain/SKILL.md).
Source of truth: [`marshail-knowledge-curator.md`](../../agents/marshail-knowledge-curator.md).
