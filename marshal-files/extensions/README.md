# `.marshal/extensions/`

Repo-specific MARSHAL assets — rules, skills, and subagents — that were
**generated** (typically by `marshal-learner` at stage 7) or
hand-authored on top of MARSHAL's built-ins.

```text
extensions/
  rules/
    mx-<name>.md
  skills/
    mx-<name>/
      SKILL.md
  agents/
    mx-<name>.md
```

## Naming

Every file / folder under `extensions/` is prefixed with `mx-`
("marshal extension") **at creation time**. The prefix:

- distinguishes repo-specific extensions from built-in MARSHAL lifecycle
  assets (which live in `.marshal/{skills,skills-fallback,agents,rules}/`
  and use the `marshal-` prefix), and
- distinguishes them from non-MARSHAL items in the shared
  `.agent-config/` source tree once they are promoted.

## How they get into tool layouts

`marshal-promote-assets` walks **both** the built-in trees and this
`extensions/` tree, copying everything into `.agent-config/` with names
kept as-is — built-ins stay `marshal-*`, extensions here stay `mx-*`
(no reprefixing either way). Then `agent-conf-sync` fans
`.agent-config/` out to tool-native layouts.

## Why split from the built-ins

- **Upgrade safety.** Pulling a new MARSHAL release rewrites
  `.marshal/{skills,skills-fallback,agents,rules}/`. Extensions live
  outside that path, so they survive upgrades unchanged.
- **Auditability.** A single `git log marshal-files/extensions/` (or
  `.marshal/extensions/` in a consumer repo) shows exactly what
  guidance has been added on top of stock MARSHAL.

## Authoring

The usual author is `marshal-learner` (stage 7). It drafts new
extensions from accumulated phase learnings and asks for human
approval per item. You may also hand-author files here; just keep the
`mx-` prefix and the cyncia-compatible frontmatter format.
