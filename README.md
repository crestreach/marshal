# MARSHAL

**MARSHAL** = **M**ethod for **A**I-assisted **R**equirements Engineering, **S**oftware Implementation, with **H**uman **A**pproval and **A**daptive **L**earning.

<p align="center">
  <img src="assets/marshal-logo-shield-chip-sync-v1.png" alt="MARSHAL icon" width="160" />
</p>

MARSHAL is a practical operating model for AI-assisted software delivery.
A change moves through explicit, optional-by-default **stages**, each producing durable artifacts that feed the next, with **human approval gates** at the points that matter and **curated learning** that feeds back into the process.

The full specification is [`marshal.md`](./marshal.md); this README is the short tour.

## Why it exists

AI can write code quickly, but unguided AI-assisted work fails in predictable ways: it pollutes its own context with broad searches, starts coding before the change is framed, lets the plan and the code drift apart until the plan no longer reflects what was built, gives ad-hoc review feedback, and either loses its lessons or overfits them to a single case.

MARSHAL counters each of these with a single canonical flow: focused code analysis, structured planning, controlled execution, explicit verification, release discipline, and curated learning — all recorded as artifacts a human can inspect and approve.

## Principles

- **One canonical flow.**
  Every stage emits explicit artifacts (durable context) that the next stage consumes.
- **The plan is the source of truth.**
  An agent's built-in "plan mode" is only a helper; `delivery-plan.md` is authoritative.
- **Scale with the change.**
  Skip stages for a typo; run the whole pipeline for a risky feature.
  Only **Plan** is mandatory.
- **Small, reviewable slices** by default; larger PRs only at integration boundaries.
- **Human approval gates** where they matter — never bypassed, even in autonomous modes.
- **Curated learning.**
  Each phase emits *generalizable* lessons only; durable ones are promoted into rules, skills, agents, and knowledge, and case-specific noise is dropped.
- **Agent-managed knowledge.**
  A durable, agent-maintained memory of repo facts, rationale, and decisions that also narrows future code searches.

## The process

```
Specification → Intake → Analysis → Architecture → Plan
  → Implementation round (Implement → Verify → Review/PR) → Rollout → Learn
```

| Stage | Purpose | Artifact | Required? |
|---|---|---|---|
| 1. Specification | Clarify what is being asked | `specification.md` | optional |
| 2. Intake | Frame the change and its acceptance criteria | `change-brief.md` | optional |
| 3. Analysis | Targeted recon of the affected code | `repo-recon.md` | optional |
| 4. Architecture | Shape the solution when it is not obvious | `architecture-notes.md` | optional |
| 5. Plan | The canonical plan for the change | `delivery-plan.md` | **mandatory** |
| 6. Implementation round | Implement → Verify → Review/PR, once or per phase | code, `verification-report.md`, PR | per change |
| 7. Rollout | Release / migration notes | `rollout-note.md` | optional |
| 8. Learn | Promote generalizable lessons | `learning-rollup.md`, knowledge updates | optional |

Only **Plan** is mandatory; every other stage is skipped when it would not add value.
The chosen scope is agreed up front and recorded at the top of `delivery-plan.md`.
A PR may target the final branch directly or an **integration branch**; in the latter case a final round (Implement → Verify → Review/PR) promotes the integration branch to the release / main branch and reviews the change as a whole.
The whole per-change **artifact chain** lives in a working folder under `.marshal/work/<change-id>/` (transient, gitignored, archived on finalize); see [`marshal.md`](./marshal.md) for its structure and the resume contract.

## Knowledge

MARSHAL pairs the process with an agent-managed **knowledge layer** under `.marshal/knowledge/`.
Where the artifact chain captures *this* change, knowledge captures durable facts about the repo — architecture, logic, conventions, and decisions — that survive across changes.
It is loaded through progressive disclosure (an always-loaded root index → per-folder indexes → topic files), kept in sync after each implementation cycle, and used to narrow code searches instead of re-deriving the same facts every time.
The representation is exchangeable: the general contract lives in [`knowledge-contract.md`](./marshal-files/references/knowledge-contract.md) and the default implementation, **MARSHAL Markdown Spine**, in [`knowledge-markdown-spine.md`](./marshal-files/references/knowledge-markdown-spine.md).

## Agents and skills

Each stage is owned by a `marshal-*` **subagent** (the single source of truth for that role) with matching **skills** that match user intent and dispatch the work — a `marshal-delegate-to-*` wrapper for tools with subagent support, and a full inline `marshal-*` fallback for tools without it.

- **Stage agents:** `marshal-specifier`, `marshal-framer`, `marshal-code-archaeologist`, `marshal-architect`, `marshal-planner`, `marshal-implementer`, `marshal-verifier`, `marshal-reviewer`, `marshal-releaser`, `marshal-learner`.
- **Knowledge:** `marshal-knowledge-curator` (maintenance in all modes) and `marshal-researcher` (read-only, source-linked deep dives).
- **Orchestration / help:** `marshal-driver` (runs the process end to end) and `marshal-helper` (procedural and conceptual questions).

Every agent declares a startup **load tier** and follows the shared [`activation-protocol.md`](./marshal-files/references/activation-protocol.md), and every agent hands its result back to the orchestrator (`marshal-driver`) — or to the user, when invoked directly.

### Communication models

There are two supported ways to drive MARSHAL, and they can be mixed:

1. **Direct** — call a specialist agent (or its `marshal-delegate-to-*` skill) for a single stage.
   Best when you know the process and want one focused step.
2. **Driver-mediated** — talk only to `marshal-driver` as a single point of contact; it coordinates the specialists and keeps you oriented.
   The level of involvement ranges from hands-off (return only for key decisions and approval gates) to collaborative (shape choices together, phase by phase), inferred from your prompt and the autonomy setting and adjustable at any stage boundary.

## Installing MARSHAL in your repo

From the root of your target repo, run the install script:

```bash
curl -fsSL https://raw.githubusercontent.com/crestreach/marshal/main/scripts/install-marshal.sh | bash
```

It fetches the MARSHAL `marshal-files/` subtree into `.marshal/`, installs [cyncia](https://github.com/crestreach/cyncia) if it is missing (committed into the repo, **not** a git submodule), and runs the cyncia sync when an `.agent-config/` source tree is present.
It is **idempotent** — re-run it to update:

- `config.yml` is generated with defaults on a fresh install; on an update, newly introduced properties are added while your existing values are left alone (obsolete ones are kept unless you choose to drop them).
- The agent-managed knowledge tree (`.marshal/knowledge/`), the per-change work tree (`.marshal/work/`), and your `.marshal/marshal-override.md` are never overwritten.

Run with `--help` for options (`--ref`, `--marshal-dir`, `--agent-config`, `--no-cyncia`, `--no-sync`).
The script installs the assets and runs the cyncia sync; wiring MARSHAL's durable assets into `.agent-config/` so the sync can fan them out to tool layouts is the separate `marshal-promote-assets` step, run once from an AI assistant (or as part of the `marshal-init` skill).

## Repository layout

- [`marshal.md`](./marshal.md) — the process specification (source of truth).
- [`marshal-files/`](./marshal-files) — MARSHAL durable assets for *this* product repo (entrypoint, `LICENSE`, `config.yml`, knowledge, skills, agents, rules, references).
  A consumer repo sees these as `.marshal/`, so the installed tree carries its own MIT license.
- [`marshal-files/marshal-override.md`](./marshal-files/marshal-override.md) — optional, repo-specific overrides on top of `marshal.md` (empty by default).
- [`scripts/install-marshal.sh`](./scripts/install-marshal.sh) — the installer.
- [`examples/`](./examples) — worked examples of MARSHAL installed in a repo (see [`examples/snippets-api/`](./examples/snippets-api/) for a filled-in knowledge tree, an ADR, and repo-specific extensions).
- [`.agent-config/`](./.agent-config) — generic source tree consumed by the [cyncia](https://github.com/crestreach/cyncia) sync under [`.cyncia/`](./.cyncia).
  Edit here, then re-run the sync to regenerate the per-tool layouts (`.cursor/`, `.claude/`, `.github/`, `.junie/`, `.vscode/`, root `AGENTS.md`, `CLAUDE.md`, `.mcp.json`).
- [`AGENTS.md`](./AGENTS.md) — guidance for AI agents working in this repo (generated; authored under [`.agent-config/AGENTS.md`](./.agent-config/AGENTS.md)).

## License

MARSHAL is licensed under the **MIT License**.
See [`LICENSE`](./LICENSE).
