---
name: marshail-delegate-to-driver
description: Run a whole MARSHAIL change end-to-end. Delegate when the user asks to "run MARSHAIL on this", "do a full MARSHAIL change for X", "orchestrate this change end-to-end", "drive this through MARSHAIL stages", "manage stage transitions for me", "resume this MARSHAIL change", "pick up where the change left off", "I want one orchestrator instead of juggling stages", or any high-level "do the whole thing under MARSHAIL" intent. Also delegate when starting a new change in a MARSHAIL repo (with `.marshail/` initialized) and the user wants per-stage approval gates managed automatically. The subagent agrees scope, detects current stage from on-disk artifacts, dispatches per-stage agents, and surfaces approval gates.
---

# marshail-delegate-to-driver

Delegate this to the [`marshail-driver`](../../agents/marshail-driver.md) subagent.
Do **not** inline the orchestration — the driver owns it.

## Call contract

- **Subagent:** `marshail-driver`
- **Pass:** the user's prompt describing the change; the repo with `.marshail/` initialized; `.marshail/config.yml`.
- **Expect back:** the full canonical artifact chain in the working folder (`change-brief.md` → `repo-recon.md` → optional `architecture-notes.md` → `delivery-plan.md` → code + phase logs + phase learnings → `verification-report.md` → `rollout-note.md` → `learning-rollup.md`); per-stage approval prompts; a stage-summary report.
- **On result:** review the stage summary; pursue any flagged follow-ups.

For one-off stage runs, prefer the per-stage `marshail-delegate-to-*` skills directly instead of the driver.

## Fallback (no-subagent environments)

The driver's value is subagent orchestration with isolated context per stage.
In environments without subagent support, chain the per-stage fallback skills under [`marshail-files/skills-fallback/`](../../skills-fallback/) manually instead — same workflows, same artifact chain.
There is no separate driver fallback skill.
