---
name: marshal-knowledge-rebuild
description: Post-feature rebuild of the MARSHAL knowledge layer. Incorporates new and deleted code and changed logic after a sizable feature lands. Heavier than marshal-knowledge-maintain mode rescan; may restructure domain folders.
---

# marshal-knowledge-rebuild

Knowledge skill — heavy operation.

## When to use

- After a sizable feature lands that introduced new modules, removed
  modules, or significantly changed logic.
- When `marshal-knowledge-maintain` mode `rescan` would only patch
  surface-level facts but the deeper structure of a domain has shifted.
- Periodically (e.g. quarterly) regardless of any specific feature.

## Difference vs. `marshal-knowledge-maintain`

| Concern | `maintain` | `rebuild` |
|---|---|---|
| Touches frontmatter only | sometimes | often |
| Adds/removes files | rarely | often |
| Restructures `domains/<x>/` | no | yes |
| Re-derives bounded contexts | no | yes |
| Cost | low–medium | high |

## Prerequisites

- `.marshal/knowledge/` exists.
- A merged feature branch / commit range to incorporate.

## Inputs (read at start)

- Current HEAD source tree.
- The previous knowledge tree as-is.
- [`../../references/knowledge-format.md`](../../references/knowledge-format.md)
- [`../../references/activation-protocol.md`](../../references/activation-protocol.md)
- [`../../references/promotion-rules.md`](../../references/promotion-rules.md)

## Workflow

1. Run [`marshal-knowledge-init`](../marshal-knowledge-init/SKILL.md)-style
   detection on current HEAD to reproduce the bounded-context map.
2. Diff against the existing `.marshal/knowledge/` structure:
   - new contexts → propose new `domains/<x>/` skeletons.
   - removed contexts → propose archival (move under `learn/rollups/`
     or mark `kind: explanation` if still useful).
   - renamed/merged contexts → propose moves with redirect notes.
3. For each surviving file, run logic equivalent to
   [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
   mode `rescan`.
4. Re-derive `repo/architecture.md` and `repo/bounded-contexts.md`
   from scratch and 3-way merge against the existing versions.
5. Present a single unified diff covering structure changes + content
   changes.
6. After approval: regenerate every `INDEX.md`.

## Outputs

- Restructured `.marshal/knowledge/` (proposed as a unified diff).
- A summary of structural changes (contexts added / removed / renamed).

## Handoff

- **Caller:** typically a human at a feature-complete moment, or
  [`marshal-driver`](../../agents/marshal-driver.md).
- **Pass back:** the diff and the structural-changes summary.

## Subagent

Strongly recommended v2 path:
[`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md)
in fresh context — rebuilds touch many files and benefit from isolated
reasoning.
