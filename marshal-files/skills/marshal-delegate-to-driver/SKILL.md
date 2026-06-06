---
name: marshal-delegate-to-driver
description: Run a whole MARSHAL change end-to-end. Delegate when the user asks to "run MARSHAL on this", "do a full MARSHAL change for X", "orchestrate this change end-to-end", "drive this through MARSHAL stages", "manage stage transitions for me", "resume this MARSHAL change", "pick up where the change left off", "I want one orchestrator instead of juggling stages", or any high-level "do the whole thing under MARSHAL" intent. Also delegate when starting a new change in a MARSHAL repo (with `.marshal/` initialized) and the user wants per-stage approval gates managed automatically. The subagent agrees scope, detects current stage from on-disk artifacts, dispatches per-stage agents, and surfaces approval gates.
---

# marshal-delegate-to-driver

Delegate this to the [`marshal-driver`](../../agents/marshal-driver.md) subagent.
Do **not** inline the orchestration — the driver owns it.

## Call contract

- **Subagent:** `marshal-driver`
- **Pass:** the user's prompt describing the change; the repo with `.marshal/` initialized; `.marshal/config.yml`.
- **Expect back:** the full canonical artifact chain in the working folder (`change-brief.md` → `repo-recon.md` → optional `architecture-notes.md` → `delivery-plan.md` → code + phase logs + phase learnings → `verification-report.md` → `rollout-note.md` → `learning-rollup.md`); per-stage approval prompts; a stage-summary report.
- **On result:** review the stage summary; pursue any flagged follow-ups.

For one-off stage runs, prefer the per-stage `marshal-delegate-to-*` skills directly instead of the driver.

## Fallback (no-subagent environments)

The driver's value is subagent orchestration with isolated context per stage.
In environments without subagent support, chain the per-stage fallback skills under [`marshal-files/skills-fallback/`](../../skills-fallback/) manually instead — same workflows, same artifact chain.
There is no separate driver fallback skill.
