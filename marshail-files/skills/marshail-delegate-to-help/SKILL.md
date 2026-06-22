---
name: marshail-delegate-to-help
description: MARSHAIL on-demand help. Delegate when the user asks "how does MARSHAIL work?", "what does the X stage do?", "which skill / agent should I use next?", "what stage am I in?", "explain the knowledge layer", "how do I write a delivery plan?", "what goes in repo-recon.md?", "how does the config sync fit in?", "what's the difference between marshail-init and marshail-load?", "what's the marshail acronym?", "MARSHAIL?", or any procedural / conceptual question about the MARSHAIL process, the knowledge layer, the available skills / agents, or how MARSHAIL applies to the current change. Also delegate when the caller is unsure which skill / agent to use, or when another skill / agent encounters a MARSHAIL-meta question that would pollute its context. The subagent reads marshail.md and the repo's .marshail/ tree, returns a concise answer, and (when asked) hands off — read-only.
---

# marshail-delegate-to-help

Delegate this to the [`marshail-helper`](../../agents/marshail-helper.md) subagent.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshail-helper`
- **Pass:** the user's question (free text); optional working folder path for situational questions like "what stage am I in?".
  Read-only access to the repo and `.marshail/`.
- **Expect back:** a single concise answer block (default ≤ ~30 lines), ending with a one-line "next step" pointer.
  No files written.
- **On result:** if the answer includes a handoff to a stage agent (driver or specific stage), invoke the matching `marshail-delegate-to-*` next.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshail-help`](../../skills-fallback/marshail-help/SKILL.md).
Source of truth: [`marshail-helper.md`](../../agents/marshail-helper.md).
