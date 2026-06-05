---
name: marshal-delegate-to-learn
description: MARSHAL Learn / improve stage. Delegate when the user asks to "merge the phase learnings", "produce learning-rollup.md", "promote learnings into AGENTS.md / README / rules / skills / subagents / prompts / checklists", "draft a new rule from the learnings", "draft a new skill / subagent from the learnings", "promote durable items into the knowledge layer", "close the loop on this change", "what should we keep from this change?". Also delegate after the Rollout stage (or the PR stage if rollout was skipped) for any change with phase learning files worth promoting. The subagent merges and dedupes learnings, groups them into buckets, proposes per-bucket diffs (human-approved), and routes the knowledge bucket via marshal-knowledge-curator mode from-learning.
---

# marshal-delegate-to-learn

Delegate this to the [`marshal-learner`](../../agents/marshal-learner.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-learner`
- **Pass:** all `learning/phase-*.learning.md` files for the change; pointers to update targets (`AGENTS.md`, `README.md`, `.marshal/rules/`, `.marshal/skills/`, `.marshal/agents/`, `.marshal/knowledge/`).
- **Expect back:** `learning-rollup.md`; per-bucket proposed diffs (human-approved before applying); files dropped into `.marshal/knowledge/learn/inbox/` for the knowledge bucket.
- **On result:** for the knowledge bucket, hand off to [`marshal-delegate-to-knowledge-maintain`](../marshal-delegate-to-knowledge-maintain/SKILL.md) (`from-learning`) with paths to the inbox files just added. For new skills / subagents / rules drafted under `.marshal/`, run the agent-config sync afterwards.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-learn`](../../skills-fallback/marshal-learn/SKILL.md). Source of truth: [`marshal-learner.md`](../../agents/marshal-learner.md).
