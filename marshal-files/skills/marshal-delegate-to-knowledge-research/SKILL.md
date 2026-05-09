---
name: marshal-delegate-to-knowledge-research
description: Focused research on a topic, codebase area, or library, returning a condensed source-linked markdown delta. Delegate when the user asks to "research X", "study how Y is wired up", "summarize the auth pipeline", "what does the Job table represent?", "deep-dive on this module", "answer this narrow question without polluting the main context", "find a fresh summary I can drop into the knowledge tree", "give me a delta I can promote later". Also delegate during stage 3 (Analysis) when repo-recon needs depth, during stage 5a (Implement) when an unknown surfaces, and any time another agent / skill suggests "research first" rather than guessing. Read-only — does not write to the knowledge tree.
---

# marshal-delegate-to-knowledge-research

Delegate this to the [`marshal-researcher`](../../agents/marshal-researcher.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-researcher`
- **Pass:** a narrowly-scoped topic / question; optional list of likely-relevant paths or a knowledge-file id to refresh; read-only access to the repo and `.marshal/knowledge/`; `.marshal/config.yml` for contract / implementation refs.
- **Expect back:** a single condensed, source-linked markdown delta (target ≤ ~150 lines body) following the active knowledge implementation; an "open questions" trailer.
- **On result:** consume the delta inline. For promotion to canonical knowledge, drop it into `.marshal/knowledge/learn/inbox/` and invoke [`marshal-delegate-to-knowledge-maintain`](../marshal-delegate-to-knowledge-maintain/SKILL.md) (`from-learning`).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-research`](../../skills-fallback/marshal-knowledge-research/SKILL.md). Source of truth: [`marshal-researcher.md`](../../agents/marshal-researcher.md).
