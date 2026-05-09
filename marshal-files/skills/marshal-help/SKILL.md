---
name: marshal-help
description: Answer questions about MARSHAL — the process, the knowledge layer, the available skills and subagents, and how to apply them to the current change in this repo. Use when the caller asks "how does MARSHAL work?", "what stage am I in?", "which skill should I use next?", "how do I write the plan?", or any other procedural / conceptual question about MARSHAL. Read-only by default; can hand off to marshal-driver to actually run a stage.
---

# marshal-help

Help skill — runs on demand, any time, in any session.

## Purpose

Be the on-demand expert on MARSHAL for the caller. Read the canonical
spec and the repo's MARSHAL files, then answer questions about:

- the MARSHAL process (stages, artifacts, gates, replanning rules);
- the knowledge layer (structure, frontmatter, autonomy, splits);
- which skill or subagent to invoke next given the caller's situation;
- how a specific MARSHAL concept maps onto **this** repo's state
  (current stage, existing artifacts, autonomy mode, what is in the
  knowledge tree);
- generated-asset / config-sync questions (`.marshal/` ↔ `.agent-config/`,
  the `marshal-promote-assets` skill, the `mx_` prefix).

If the caller asks to *do* a stage rather than just learn about it,
relay them to [`marshal-driver`](../../agents/marshal-driver.md) (or to
the specific stage skill).

## When to apply

Trigger phrases:

- "how does MARSHAL work?"
- "what does the X stage do?"
- "which skill should I use next?"
- "what stage am I in?"
- "explain the knowledge layer"
- "how do I write a delivery plan?" / "what goes in `repo-recon.md`?"
- "how does the config sync fit in?"
- "what's the difference between `marshal-init` and `marshal-load`?"
- general "MARSHAL?" / "help" in a MARSHAL-enabled repo.

Do **not** apply when:

- the caller wants to actually progress a change → use
  [`marshal-driver`](../../agents/marshal-driver.md) or the specific
  stage skill.
- the caller wants knowledge-tree edits → use
  [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md).

## Prerequisites

- A repo with `.marshal/` initialized. If not initialized, the answer
  should explain MARSHAL conceptually and recommend
  [`marshal-init`](../marshal-init/SKILL.md).

## Inputs (read at start)

Read enough to answer accurately, no more:

1. [`marshal.md`](../../../marshal.md) — full process spec (canonical).
2. [`.marshal/ENTRYPOINT.md`](../../ENTRYPOINT.md) — compact entry point.
3. [`.marshal/AGENTS.md`](../../AGENTS.md) — the merged-in snippet.
4. [`.marshal/config.yml`](../../config.yml) — contract,
   implementation, autonomy mode, and knowledge size caps.
5. [`.marshal/knowledge/INDEX.md`](../../knowledge/INDEX.md) — root
   knowledge index (only the index, not topic files, unless the
   question is about a specific topic).
6. [`.marshal/design/knowledge-design.md`](../../design/knowledge-design.md).
7. [`.marshal/references/`](../../references/) — representation, activation, and promotion rules.
8. The relevant `SKILL.md` or agent file in `.marshal/skills/` /
   `.marshal/agents/` when the question is specifically about that
   skill / subagent.
9. The current change's working folder (artifact chain) — only when the
   question is "what stage am I in?" or "what should I do next?".

Read lazily: the trivial questions only need (1) and (2). Don't load
the whole tree.

## Workflow

1. **Classify the question** into one of:
   - *conceptual* — about MARSHAL itself (process, knowledge, sync);
   - *situational* — about the current change in this repo;
   - *tooling* — about a specific skill, subagent, or file format;
   - *handoff* — caller wants to actually run a stage now.
2. **Read just enough.** Always start with `marshal.md` +
   `ENTRYPOINT.md` if not already in context. Add files from the
   inputs list only as the question demands.
3. **For situational questions**, also run the same artifact-chain
   detection [`marshal-load`](../marshal-load/SKILL.md) uses (look for
   `specification.md` → `change-brief.md` → … → `learning-rollup.md`)
   to know which stage is current and which were skipped per the plan's
   `Scope:` line.
4. **Answer concisely.** Default to a short paragraph or a bullet
   list. Quote the spec sparingly; link to the section in `marshal.md`
   or to the specific `SKILL.md` rather than restating it.
5. **Surface the next action.** End every answer with a one-line
   "next step" pointer — either the skill to run, the file to read,
   or the question to clarify.
6. **Handoff (when asked).** If the caller wants to *do* a stage, hand
   off to [`marshal-driver`](../../agents/marshal-driver.md) (whole-run
   orchestration) or directly to the relevant stage skill. Pass along
   the orientation block from step 3 so the next skill does not need
   to re-detect.

## Outputs

- A single answer block returned to the caller. No files written.
- Optional: a short handoff message (skill name + orientation block)
  when the caller asks to progress a stage.

## Style

- Match the caller's level: don't dump the spec on someone asking a
  one-line question.
- Use links to `marshal.md` sections and to specific `SKILL.md` files
  rather than copy-pasting their content.
- Never invent process rules — if the spec is silent, say so and
  suggest discussing the gap with the user (per the "no assumptions"
  guideline in [`AGENTS.md`](../../AGENTS.md)).
- Avoid bloating the caller's context: if the answer needs more than
  ~40 lines, prefer a tight summary plus links over a dump.

## Exit criteria

- Caller's question is answered, or the caller has been handed off to
  the right skill / subagent for what they actually want to do.

## Handoff

- **Next skill (typical):**
  - [`marshal-load`](../marshal-load/SKILL.md) — when the caller is
    starting a fresh session.
  - [`marshal-driver`](../../agents/marshal-driver.md) — when the
    caller wants to run a whole change end-to-end.
  - The specific stage skill (`marshal-specify`, `marshal-plan`,
    `marshal-implement`, …) — when the caller wants to do exactly
    one stage.
  - [`marshal-knowledge-research`](../marshal-knowledge-research/SKILL.md)
    — when the question is "what does the repo do for X?" rather
    than "what does MARSHAL do for X?".
- **Pass:** the orientation block (current stage, autonomy mode,
  recommended next skill) when handing off.

## Subagent

[`marshal-helper`](../../agents/marshal-helper.md) wraps this skill
with fresh context so a help conversation does not pollute the
caller's working context.
