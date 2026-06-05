---
name: marshal-delegate-to-knowledge-rebuild
description: Post-feature rebuild of the MARSHAL knowledge layer. Delegate when the user asks to "rebuild the knowledge tree", "restructure domains/ after this feature", "re-derive bounded contexts", "incorporate this feature branch into knowledge", "do a quarterly knowledge rebuild", "promote big structural changes into the knowledge layer". Use when a sizable feature lands that introduced new modules, removed modules, or significantly changed logic — heavier than maintain mode `rescan`. The subagent (curator in mode `rebuild`) re-runs init-style detection on HEAD and reconciles structure + content with the existing tree per the autonomy mode — applying changes and returning a short summary in `auto`, or a summary diff for approval in `review`.
---

# marshal-delegate-to-knowledge-rebuild

Delegate this to the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent in mode `rebuild`. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-knowledge-curator`
- **Mode:** `rebuild`
- **Pass (request-specific only):** the **intent** (what to rebuild / incorporate) and the merged feature branch or commit range to incorporate. The agent reads the current HEAD, the previous knowledge tree, `.marshal/config.yml`, and the knowledge contract / implementation itself — do not pass them.
- **Expect back:** a **summary** of structure changes (contexts added / removed / renamed) and content changes — not the full knowledge diff.
- **On result:** under `knowledge.autonomy: auto` (default) it is already applied — read the summary. Under `review`, approve the diff.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-rebuild`](../../skills-fallback/marshal-knowledge-rebuild/SKILL.md). Source of truth: [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md).
