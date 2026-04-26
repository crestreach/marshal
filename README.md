# MARSHAL

**MARSHAL** = **M**ethod for **A**I-assisted **R**equirements Engineering, **S**oftware Implementation, with **H**uman **A**pproval and **A**daptive **L**earning.

<p align="center">
  <img src="assets/marshal-icon.png" alt="MARSHAL icon" width="160" />
</p>

A practical operating model for AI-assisted software delivery, with explicit human approval gates and curated learnings that feed back into the process.

See [`marshal.md`](./marshal.md) for the full specification.

## Repository

- [`marshal.md`](./marshal.md) — the process specification (source of truth)
- [`AGENTS.md`](./AGENTS.md) — guidance for AI agents working in this repo (generated; authored under [`agent-config/AGENTS.md`](./agent-config/AGENTS.md))
- [`marshal-files/`](./marshal-files) — MARSHAL durable assets for *this* product repo (entrypoint, config, knowledge, skills, agents, rules). Equivalent to `.marshal/` in a consumer repo.
- [`agent-config/`](./agent-config) — generic source tree consumed by [`ai-dev-agent-config-sync`](./ai-dev-agent-config-sync) (vendored as a submodule). Edit here, then re-run sync to regenerate per-tool layouts (`.cursor/`, `.claude/`, `.github/`, `.junie/`, `.vscode/`, root `AGENTS.md`, `CLAUDE.md`, `.mcp.json`).
- [`examples/`](./examples) — worked examples of MARSHAL installed in a repo.
- `assets/` — branding (untracked).

Tooling (skills, prompt templates, artifact templates, examples) will be added as the process stabilizes.

## Status

Early draft. The spec is being shaped; expect frequent changes.

## License

MARSHAL is dual-licensed:

- Documentation and the method itself → **CC BY-SA 4.0**
- Code, scripts, and tooling → **BSD 2-Clause + Commons Clause** (source-available)

You may use MARSHAL commercially — internally, on client work, in products you build on top of it, and you may freely redistribute modified versions for free. You may **not** sell MARSHAL itself (or a repackaged version of it) as a product. See [`LICENSE`](./LICENSE) for details.
