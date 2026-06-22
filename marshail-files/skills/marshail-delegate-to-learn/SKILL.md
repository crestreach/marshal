---
name: marshail-delegate-to-learn
description: MARSHAIL Learn / improve stage. Delegate when the user asks to "merge the phase learnings", "produce learning-rollup.md", "promote learnings into AGENTS.md / README / rules / skills / subagents / prompts / checklists", "draft a new rule from the learnings", "draft a new skill / subagent from the learnings", "promote durable items into the knowledge layer", "close the loop on this change", "what should we keep from this change?". Also delegate after the Rollout stage (or the PR stage if rollout was skipped) for any change with phase learning files worth promoting. The subagent merges and dedupes learnings, groups them into buckets, proposes per-bucket diffs (human-approved), and routes the knowledge bucket via marshail-knowledge-curator mode from-learning.
---

# marshail-delegate-to-learn

Delegate this to the [`marshail-learner`](../../agents/marshail-learner.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-learner`
- **Pass:** all `learning/phase-*.learning.md` files for the change; pointers to update targets (`AGENTS.md`, `README.md`, `.marshail/rules/`, `.marshail/skills/`, `.marshail/agents/`, `.marshail/knowledge/`).
- **Expect back:** `learning-rollup.md`; per-bucket proposed diffs (human-approved before applying); files dropped into `.marshail/knowledge/learn/inbox/` for the knowledge bucket.
- **On result:** for the knowledge bucket, hand off to [`marshail-delegate-to-knowledge-maintain`](../marshail-delegate-to-knowledge-maintain/SKILL.md) (`from-learning`) with paths to the inbox files just added.
  For new skills / subagents / rules drafted under `.marshail/`, run the agent-config sync afterwards.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-learn`](../../skills-fallback/marshail-learn/SKILL.md).
Source of truth: [`marshail-learner.md`](../../agents/marshail-learner.md).
