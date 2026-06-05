---
name: marshal-verify
description: MARSHAL Verify stage — REQUIRED before any PR. Fallback skill for environments without subagent support. Triggers on "verify the change", "run the verification gate", "produce verification-report.md", "is this ready for PR?", "do Dev-QA", "audit tests / static / lint / typecheck / migrations / observability / security for this PR boundary". Runs verification inline in the current session.
---

# marshal-verify (fallback — no-subagent environments)

This skill performs the work that the [`marshal-verifier`](../../agents/marshal-verifier.md) subagent does, but inline in the current session, for tools that don't support custom subagents.

**Source of truth:** [`marshal-verifier.md`](../../agents/marshal-verifier.md). Read it and follow its **Inputs / Workflow / Outputs / Exit criteria / Handoff** sections exactly. Do not duplicate that content here.

> If subagents *are* available, prefer [`marshal-delegate-to-verify`](../../skills/marshal-delegate-to-verify/SKILL.md) so the work runs in fresh context.
