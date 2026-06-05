# MARSHAL

**MARSHAL** = **M**ethod for **A**I-assisted **R**equirements Engineering, **S**oftware Implementation, with **H**uman **A**pproval and **A**daptive **L**earning.

<p align="center">
  <img src="assets/marshal-icon.png" alt="MARSHAL icon" width="160" />
</p>

A practical operating model for AI-assisted software delivery, with explicit human approval gates and curated learnings that feed back into the process.

See [`marshal.md`](./marshal.md) for the full specification.

## Repository

- [`marshal.md`](./marshal.md) — the process specification (source of truth)
- [`marshal-files/marshal-override.md`](./marshal-files/marshal-override.md) — optional, repo-specific overrides on top of `marshal.md`. Empty by default. (In a consumer repo: `.marshal/marshal-override.md`.)
- [`marshal-files/references/knowledge-contract.md`](./marshal-files/references/knowledge-contract.md) — general knowledge representation contract
- [`marshal-files/references/knowledge-markdown-spine.md`](./marshal-files/references/knowledge-markdown-spine.md) — default knowledge implementation,
  **MARSHAL Markdown Spine**; replaceable via `knowledge.representation_ref` in
  [`marshal-files/config.yml`](./marshal-files/config.yml)
- [`AGENTS.md`](./AGENTS.md) — guidance for AI agents working in this repo (generated; authored under [`.agent-config/AGENTS.md`](./.agent-config/AGENTS.md))
- [`marshal-files/`](./marshal-files) — MARSHAL durable assets for *this* product repo (entrypoint, config, knowledge, skills, agents, rules). Equivalent to `.marshal/` in a consumer repo.
- [`.agent-config/`](./.agent-config) — generic source tree consumed by the [cyncia](https://github.com/crestreach/cyncia) sync engine under [`.cyncia`](./.cyncia) (installed via cyncia's own installer and committed into the repo, not a git submodule). Edit here, then re-run sync to regenerate per-tool layouts (`.cursor/`, `.claude/`, `.github/`, `.junie/`, `.vscode/`, root `AGENTS.md`, `CLAUDE.md`, `.mcp.json`).
- [`examples/`](./examples) — worked examples of MARSHAL installed in a repo.
- `assets/` — branding (untracked).

Tooling (skills, prompt templates, artifact templates, examples) will be added as the process stabilizes.

## Installing MARSHAL in your repo

The supported entry point is the [`marshal-init`](./marshal-files/skills/marshal-init/SKILL.md) skill — invoke it from any AI assistant that has access to MARSHAL's skills, and it will scaffold `.marshal/`, install [cyncia](https://github.com/crestreach/cyncia) (typically as a git submodule), provision an `.agent-config/` source tree, run [`marshal-promote-assets`](./marshal-files/skills/marshal-promote-assets/SKILL.md) to wire MARSHAL durable assets into it, and (with your approval) run the sync once to fan everything out into per-tool layouts.

If you want to vendor MARSHAL durable assets directly (no `marshal-init`), the recommended pattern is:

```bash
# In your target repo
git submodule add https://github.com/crestreach/marshal.git .marshal-source
ln -s .marshal-source/marshal-files .marshal
git add .marshal .gitmodules .marshal-source
git commit -m "Vendor MARSHAL durable assets"
```

`.marshal-source/` tracks the whole source repo; `.marshal/` is a symlink to its `marshal-files/` subtree, which is what MARSHAL skills and agents look for. Pull future updates with:

```bash
git submodule update --remote .marshal-source
```

A worked example using exactly this layout lives at [`crestreach/marshal-testbed`](https://github.com/crestreach/marshal-testbed) (private — request access if you need it).

## Status

Early draft. The spec is being shaped; expect frequent changes.

## License

MARSHAL is dual-licensed:

- Documentation and the method itself → **CC BY-SA 4.0**
- Code, scripts, and tooling → **BSD 2-Clause + Commons Clause** (source-available)

You may use MARSHAL commercially — internally, on client work, in products you build on top of it, and you may freely redistribute modified versions for free. You may **not** sell MARSHAL itself (or a repackaged version of it) as a product. See [`LICENSE`](./LICENSE) for details.
