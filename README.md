# MARSHAL

**MARSHAL** = **M**ethod for **A**I-assisted **R**equirements Engineering, **S**oftware Implementation, with **H**uman **A**pproval and **A**daptive **L**earning.

<p align="center">
  <img src="assets/marshal-icon.png" alt="MARSHAL icon" width="160" />
</p>

A practical operating model for AI-assisted software delivery, with explicit human approval gates and curated learnings that feed back into the process.

See [`marshal.md`](./marshal.md) for the full specification.

## What MARSHAL is

MARSHAL is an AI-assisted SDLC that moves a change through explicit,
optional-by-default **stages**, each producing durable artifacts that feed
the next:

**Specification → Intake → Analysis → Architecture → Plan → Implementation round (Implement → Verify → PR) → Rollout → Learn.**

Only the **Plan** stage is mandatory — `delivery-plan.md` is the canonical
source of truth for every change. All other stages are skipped or run
depending on the size and risk of the change (skip more for a typo, run the
full pipeline for a risky feature). The chosen scope is recorded at the top
of the plan.

It exists to avoid the predictable failure modes of AI-assisted work:
broad-search context pollution, coding before the change is framed, plans
that drift from the code, ad-hoc review feedback, and learnings that are
either lost or overfit to one case. MARSHAL counters these with focused
code analysis, structured planning, controlled execution, explicit
verification, release discipline, and curated learning.

Guiding principles:

- **One canonical flow** — every stage emits explicit artifacts (durable
  context) consumed by the next.
- **The plan is the source of truth** — agent "plan mode" is only a helper.
- **Small, reviewable slices** by default; larger PRs only at integration
  boundaries.
- **Human approval gates** at the points that matter.
- **Curated learning** — each phase emits a learning file of *generalizable*
  lessons only; durable ones are promoted into rules, skills, agents, and
  the knowledge layer, while case-specific noise is dropped.
- **Agent-managed knowledge** — a durable, agent-maintained memory of repo
  facts, rationale, decisions, and a map that narrows code searches.

A driver agent can run the whole process for you, or you can invoke
individual stage agents directly — see [`marshal.md`](./marshal.md).

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

There are two supported ways to install MARSHAL.

**1. The `marshal-init` skill (recommended).** Invoke
[`marshal-init`](./marshal-files/skills/marshal-init/SKILL.md) from any AI
assistant that has access to MARSHAL's skills. It scaffolds `.marshal/`,
installs [cyncia](https://github.com/crestreach/cyncia) via cyncia's own
installer (committed into the repo, **not** a git submodule), provisions an
`.agent-config/` source tree, runs
[`marshal-promote-assets`](./marshal-files/skills/marshal-promote-assets/SKILL.md)
to wire MARSHAL durable assets into it, and (with your approval) runs the
sync once to fan everything out into per-tool layouts.

**2. The install script.** For a non-interactive, re-runnable setup, use
[`scripts/install-marshal.sh`](./scripts/install-marshal.sh):

```bash
# In your target repo
curl -fsSL https://raw.githubusercontent.com/crestreach/marshal/main/scripts/install-marshal.sh | bash
# or, after cloning MARSHAL somewhere:
/path/to/marshal/scripts/install-marshal.sh --ref main
```

It fetches the MARSHAL `marshal-files/` subtree into `.marshal/` (idempotent —
re-run to update), installs cyncia if it is missing, and runs the cyncia sync
when an `.agent-config/` source tree is present. Run `--help` for options
(`--ref`, `--marshal-dir`, `--agent-config`, `--no-cyncia`, `--no-sync`).
Wiring the durable assets into `.agent-config/` is the
`marshal-promote-assets` step; run it (or `marshal-init`) once so the sync has
MARSHAL skills to fan out.

The agent-managed knowledge tree (`.marshal/knowledge/`) and the per-change
work tree (`.marshal/work/`) are never overwritten by an update; your
`.marshal/marshal-override.md` is also left untouched.

## Status

Early draft. The spec is being shaped; expect frequent changes.

## License

MARSHAL is dual-licensed:

- Documentation and the method itself → **CC BY-SA 4.0**
- Code, scripts, and tooling → **BSD 2-Clause + Commons Clause** (source-available)

You may use MARSHAL commercially — internally, on client work, in products you build on top of it, and you may freely redistribute modified versions for free. You may **not** sell MARSHAL itself (or a repackaged version of it) as a product. See [`LICENSE`](./LICENSE) for details.
