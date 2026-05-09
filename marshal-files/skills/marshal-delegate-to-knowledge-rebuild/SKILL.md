---
name: marshal-delegate-to-knowledge-rebuild
description: Post-feature rebuild of the MARSHAL knowledge layer. Delegate when the user asks to "rebuild the knowledge tree", "restructure domains/ after this feature", "re-derive bounded contexts", "incorporate this feature branch into knowledge", "do a quarterly knowledge rebuild", "promote big structural changes into the knowledge layer". Use when a sizable feature lands that introduced new modules, removed modules, or significantly changed logic — heavier than maintain mode `rescan`. The subagent (curator in mode `rebuild`) re-runs init-style detection on HEAD, diffs against the existing tree, proposes structure + content changes as a single unified diff for approval.
---

# marshal-delegate-to-knowledge-rebuild

Delegate this to the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent in mode `rebuild`. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-knowledge-curator`
- **Mode:** `rebuild`
- **Pass:** current HEAD source tree; previous knowledge tree as-is; the merged feature branch / commit range to incorporate; `.marshal/config.yml` (contract refs, size caps, autonomy).
- **Expect back:** unified diff covering structure changes (new / removed / renamed `domains/<x>/`, redirect notes) and content changes; structural-changes summary (contexts added / removed / renamed); regenerated `INDEX.md` files.
- **On result:** apply after human approval (or auto under `knowledge.autonomy: auto`).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-rebuild`](../../skills-fallback/marshal-knowledge-rebuild/SKILL.md). Source of truth: [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md).
