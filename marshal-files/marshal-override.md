# MARSHAL override (optional)

This is an optional, **user-authored** override file that lets a repo
specify or modify how MARSHAL behaves on top of the canonical
[`marshal.md`](../marshal.md) spec. It is the project's escape hatch
for MARSHAL itself — analogous to what `extensions/` is for skills /
agents / rules.

> **If this file is empty (the default after `marshal-init`), MARSHAL
> behaves exactly as specified in [`marshal.md`](../marshal.md).**

## When to use it

Use this file to record repo-specific MARSHAL adjustments such as:

- **Stage policy.** "Stage 1 (Specification) is mandatory in this repo,
  not optional." / "Stage 6 (Rollout) is always skipped — this is a
  library and there is no rollout."
- **Artifact policy.** "`repo-recon.md` must include a section on
  database migrations." / "`delivery-plan.md` must list every touched
  domain in `.marshal/knowledge/domains/`."
- **Tone or style overrides.** "Always use British English in
  artifacts." / "Verification reports use the matrix format from
  `.marshal/extensions/skills/mx-<x>/SKILL.md`."
- **Subagent / skill preferences.** "Always run `marshal-researcher`
  before `marshal-architect` in this repo." / "Skip
  `marshal-knowledge-rebuild` even if INDEX.md drift is detected."
- **Autonomy / approval tweaks** that do not belong in `config.yml`
  because they are conditional or descriptive rather than a flat
  setting.

For repo-specific **rules** that apply to the work itself (code style,
commit conventions, etc.) prefer
[`extensions/rules/`](extensions/) — they are picked up by every AI
assistant via the cyncia sync. Use this file only for guidance about
**MARSHAL** (the process and its stage / agent / skill behavior).

## How agents pick it up

Every MARSHAL-aware agent that loads `marshal.md` for guidance also
loads this file when present, immediately after `marshal.md`. Anything
written here **takes precedence** over the canonical spec on the
points it addresses. The conflict-resolution rule is:

1. `marshal-override.md` (this file) — repo-specific intent.
2. [`marshal.md`](../marshal.md) — canonical MARSHAL spec.
3. [`extensions/rules/`](extensions/) — rules that apply to the
   work, not to MARSHAL.

Override entries should reference the section of `marshal.md` they
replace or extend, so the divergence is reviewable.

## Format

Free-form Markdown. Suggested skeleton (delete sections you don't
need):

```markdown
# MARSHAL overrides for <repo>

## Stage policy
- <stage>: <override + rationale + link to marshal.md section>

## Artifact policy
- <artifact>: <override + rationale>

## Subagent / skill preferences
- <agent or skill>: <override + rationale>

## Other
- <free-form override>
```

Keep entries short, opinionated, and dated where helpful. When an
override is no longer needed, delete it — do not leave stale guidance
in place.

## Lifecycle

- Created (empty) by [`marshal-init`](skills/marshal-init/SKILL.md).
- Hand-edited by humans, or proposed by
  [`marshal-learner`](agents/marshal-learner.md) at stage 7 with human
  approval per entry.
- Read on every fresh session by any MARSHAL-aware agent / skill that
  also reads `marshal.md`.
- **Not synced** by cyncia — it is read directly from `.marshal/`.

## Authoring this file in this product repo

Inside this product repo (the one that defines MARSHAL itself), the
file lives at [`marshal-files/marshal-override.md`](./marshal-override.md).
In a consumer repo it lives at `.marshal/marshal-override.md`. The
file is identical in structure either way.

<!-- Add your overrides below this line. Empty file = no overrides. -->
