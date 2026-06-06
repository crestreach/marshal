---
name: marshal-delegate-to-help
description: MARSHAL on-demand help. Delegate when the user asks "how does MARSHAL work?", "what does the X stage do?", "which skill / agent should I use next?", "what stage am I in?", "explain the knowledge layer", "how do I write a delivery plan?", "what goes in repo-recon.md?", "how does the config sync fit in?", "what's the difference between marshal-init and marshal-load?", "what's the marshal acronym?", "MARSHAL?", or any procedural / conceptual question about the MARSHAL process, the knowledge layer, the available skills / agents, or how MARSHAL applies to the current change. Also delegate when the caller is unsure which skill / agent to use, or when another skill / agent encounters a MARSHAL-meta question that would pollute its context. The subagent reads marshal.md and the repo's .marshal/ tree, returns a concise answer, and (when asked) hands off — read-only.
---

# marshal-delegate-to-help

Delegate this to the [`marshal-helper`](../../agents/marshal-helper.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-helper`
- **Pass:** the user's question (free text); optional working folder path for situational questions like "what stage am I in?".
  Read-only access to the repo and `.marshal/`.
- **Expect back:** a single concise answer block (default ≤ ~30 lines), ending with a one-line "next step" pointer.
  No files written.
- **On result:** if the answer includes a handoff to a stage agent (driver or specific stage), invoke the matching `marshal-delegate-to-*` next.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-help`](../../skills-fallback/marshal-help/SKILL.md).
Source of truth: [`marshal-helper.md`](../../agents/marshal-helper.md).
