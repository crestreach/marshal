# `.marshail/extensions/`

Repo-specific MARSHAIL assets — rules, skills, and subagents — that were **generated** (typically by `marshail-learner` at the Learn stage) or hand-authored on top of MARSHAIL's built-ins.

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

Every file / folder under `extensions/` is prefixed with `mx-` ("marshail extension") **at creation time**.
The prefix:

- distinguishes repo-specific extensions from built-in MARSHAIL lifecycle assets (which live in `.marshail/{skills,skills-fallback,agents,rules}/` and use the `marshail-` prefix), and
- distinguishes them from non-MARSHAIL items in the shared `.agent-config/` source tree once they are promoted.

## How they get into tool layouts

`marshail-promote-assets` walks **both** the built-in trees and this `extensions/` tree, copying everything into `.agent-config/` with names kept as-is — built-ins stay `marshail-*`, extensions here stay `mx-*` (no reprefixing either way).
Then `agent-conf-sync` fans `.agent-config/` out to tool-native layouts.

## Why split from the built-ins

- **Upgrade safety.**
  Pulling a new MARSHAIL release rewrites `.marshail/{skills,skills-fallback,agents,rules}/`.
  Extensions live outside that path, so they survive upgrades unchanged.
- **Auditability.**
  A single `git log marshail-files/extensions/` (or `.marshail/extensions/` in a consumer repo) shows exactly what guidance has been added on top of stock MARSHAIL.

## Authoring

The usual author is `marshail-learner` (Learn stage).
It drafts new extensions from accumulated phase learnings, applying them per `extensions.autonomy` in `.marshail/config.yml` (default `review`: a diff for approval per item; `auto`: applied with a summary).
You may also hand-author files here; just keep the `mx-` prefix and the cyncia-compatible frontmatter format.
