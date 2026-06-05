---
name: marshal-delegate-to-knowledge-research
description: Focused research on a topic, codebase area, or library, returning a condensed source-linked research note. Delegate when the user asks to "research X", "study how Y is wired up", "summarize the auth pipeline", "what does the Job table represent?", "deep-dive on this module", "answer this narrow question without polluting the main context", "find a fresh summary I can drop into the knowledge tree", "give me a research note I can promote later". Also delegate during the Analysis stage when repo-recon needs depth, during the Implement stage when an unknown surfaces, and any time another agent / skill suggests "research first" rather than guessing. Read-only — does not write to the knowledge tree.
---

# marshal-delegate-to-knowledge-research

Delegate this to the [`marshal-researcher`](../../agents/marshal-researcher.md) subagent. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-researcher`
- **Pass (request-specific only):** the **intent** — a narrowly-scoped topic / question — plus optional likely-relevant paths or a knowledge-file id to refresh, and whether the result is intended for promotion to knowledge. The agent reads `.marshal/config.yml`, the knowledge contract / implementation, and the repo / knowledge tree itself — do not pass them.
- **Expect back:** a single condensed, source-linked markdown **research note** (target ≤ ~150 lines body); an "open questions" trailer. When the request says it is for knowledge, the note follows the active knowledge implementation so it can be promoted as-is.
- **On result:** consume the note inline. For promotion to canonical knowledge, drop it into `.marshal/knowledge/learn/inbox/` and invoke [`marshal-delegate-to-knowledge-maintain`](../marshal-delegate-to-knowledge-maintain/SKILL.md) (`from-learning`).

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-research`](../../skills-fallback/marshal-knowledge-research/SKILL.md). Source of truth: [`marshal-researcher.md`](../../agents/marshal-researcher.md).
