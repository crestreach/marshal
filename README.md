# MARSHAIL

*Human-approved AI software engineering with a curated learning loop.*

**MARSHAIL** = **M**ethod for **A**I-assisted **R**equirements and **S**oftware Engineering, with **H**uman **A**pproval and **I**ncremental **L**earning.

<p align="center">
  <img src="assets/marshail-logo-shield-chip-sync-v1.png" alt="MARSHAIL icon" width="160" />
</p>

MARSHAIL is a practical operating model for AI-assisted software delivery.
A change moves through explicit, optional-by-default **stages**, each producing durable artifacts that feed the next, with **human approval gates** at the points that matter and **curated learning** that feeds back into the process.

The full specification is [`marshail.md`](./marshail-files/marshail.md); this README is the short tour.

## Why it exists

AI can write code quickly, but unguided AI-assisted work fails in predictable ways: it pollutes its own context with broad searches, starts coding before the change is framed, lets the plan and the code drift apart until the plan no longer reflects what was built, gives ad-hoc review feedback, and either loses its lessons or overfits them to a single case.

MARSHAIL counters each of these with a single canonical flow: focused code analysis, structured planning, controlled execution, explicit verification, release discipline, and curated learning — all recorded as artifacts a human can inspect and approve.

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
| 6. Implementation round | Implement → Verify → Review/PR, once or per phase | code, `implementation-report.md`, `verification-report.md`, PR | per change |
| 7. Rollout | Release / migration notes | `rollout-note.md` | optional |
| 8. Learn | Promote generalizable lessons | `learning-rollup.md`, knowledge updates | optional |

Only **Plan** is mandatory; every other stage is skipped when it would not add value.
The chosen scope is agreed up front and recorded at the top of `delivery-plan.md`.
A PR may target the final branch directly or an **integration branch**; in the latter case a final round (Implement → Verify → Review/PR) promotes the integration branch to the release / main branch and reviews the change as a whole.
The whole per-change **artifact chain** lives in a working folder under `.marshail/work/<change-id>/` (transient, gitignored, archived on finalize); see [`marshail.md`](./marshail-files/marshail.md) for its structure and the resume contract.

## Knowledge

MARSHAIL pairs the process with an agent-managed **knowledge layer** under `.marshail/knowledge/`.
Where the artifact chain captures *this* change, knowledge captures durable facts about the repo — architecture, logic, conventions, and decisions — that survive across changes.
It is **derived from the code itself** — scanned from the entrypoints inward and analyzed as deep as each area needs (a trivial module stays one short topic; complex areas expand into deeper, multi-level nodes), so agents don't re-scan the same code each time.
It is loaded through progressive disclosure (an always-loaded root index → per-folder indexes → topic files), kept in sync after each implementation cycle, and used to narrow code searches instead of re-deriving the same facts every time.
The representation is exchangeable: the general contract lives in [`knowledge-contract.md`](./marshail-files/references/knowledge-contract.md) and the default implementation, **MARSHAIL Markdown Spine**, in [`knowledge-markdown-spine.md`](./marshail-files/references/knowledge-markdown-spine.md).

## Agents and skills

Each stage is owned by a `marshail-*` **subagent** (the single source of truth for that role) with matching **skills** that match user intent and dispatch the work — a `marshail-delegate-to-*` wrapper for tools with subagent support, and a full inline `marshail-*` fallback for tools without it.

- **Stage agents:** `marshail-specifier`, `marshail-framer`, `marshail-code-archaeologist`, `marshail-architect`, `marshail-planner`, `marshail-implementer`, `marshail-verifier`, `marshail-reviewer`, `marshail-releaser`, `marshail-learner`.
- **Knowledge:** `marshail-knowledge-curator` (maintenance in all modes) and `marshail-researcher` (read-only, source-linked deep dives).
- **Orchestration / help:** `marshail-driver` (runs the process end to end) and `marshail-helper` (procedural and conceptual questions).

Every agent declares a startup **load tier** and follows the shared [`activation-protocol.md`](./marshail-files/references/activation-protocol.md), and every agent hands its result back to the orchestrator (`marshail-driver`) — or to the user, when invoked directly.

### Communication models

There are two supported ways to drive MARSHAIL, and they can be mixed:

1. **Direct** — call a specialist agent (or its `marshail-delegate-to-*` skill) for a single stage.
   Best when you know the process and want one focused step.
2. **Driver-mediated** — talk only to `marshail-driver` as a single point of contact; it coordinates the specialists and keeps you oriented.
   The level of involvement ranges from hands-off (return only for key decisions and approval gates) to collaborative (shape choices together, phase by phase), inferred from your prompt and the autonomy setting and adjustable at any stage boundary.

## Installing MARSHAIL in your repo

From the root of your target repo, run the install script:

```bash
curl -fsSL https://raw.githubusercontent.com/crestreach/marshail/main/scripts/install-marshail.sh | bash
```

It fetches the MARSHAIL `marshail-files/` subtree — which now includes the canonical `marshail.md` — into `.marshail/`, plus the repo-root `LICENSE` installed inside `.marshail/`, installs [cyncia](https://github.com/crestreach/cyncia) if it is missing (committed into the repo, **not** a git submodule), and runs the cyncia sync when an `.agent-config/` source tree is present.
It is **idempotent** — re-run it to update:

- `config.yml` is generated with defaults on a fresh install; on an update, newly introduced properties are added while your existing values are left alone (obsolete ones are kept unless you choose to drop them).
- The agent-managed knowledge tree (`.marshail/knowledge/`), the per-change work tree (`.marshail/work/`), and your `.marshail/marshail-override.md` are never overwritten.
- The installed ref is recorded in `.marshail/VERSION` (for `main`, any tag(s) pointing at `HEAD`), the same way cyncia records its own `.cyncia/VERSION`.

Run with `--help` for options (`--ref`, `--marshail-dir`, `--agent-config`, `--no-cyncia`, `--no-sync`).
Responsibilities split cleanly: the **script owns installation** — downloading and updating `.marshail/` (including `marshail.md`) and the repo-root `LICENSE`, reconciling `config.yml`, recording `VERSION`, and installing cyncia (re-run it any time to update). The **[`marshail-init`](./marshail-files/skills/marshail-init/SKILL.md) skill owns repo integration** — merging the MARSHAIL entry-point into your `AGENTS.md`, wiring the durable assets into `.agent-config/` via `marshail-promote-assets`, updating `.gitignore`, and offering the initial knowledge bootstrap. Run the script first, then `marshail-init` once.

## Repository layout

- [`marshail.md`](./marshail-files/marshail.md) — the process specification (source of truth).
- [`marshail-files/`](./marshail-files) — MARSHAIL durable assets for *this* product repo (the process spec `marshail.md`, entry-point snippet, `config.yml`, `marshail-override.md`, knowledge, skills, agents, rules, references).
  A consumer repo sees these as `.marshail/`; the installer also drops the repo-root `LICENSE` into the installed `.marshail/` tree, so the install carries its own MIT license.
- [`marshail-files/marshail-override.md`](./marshail-files/marshail-override.md) — optional, repo-specific overrides on top of `marshail.md` (empty by default).
- [`scripts/install-marshail.sh`](./scripts/install-marshail.sh) — the installer.
- [`examples/`](./examples) — worked examples of MARSHAIL installed in a repo (see [`examples/snippets-api/`](./examples/snippets-api/) for a filled-in knowledge tree, an ADR, and repo-specific extensions).
- [`.agent-config/`](./.agent-config) — generic source tree consumed by the [cyncia](https://github.com/crestreach/cyncia) sync under [`.cyncia/`](./.cyncia).
  Edit here, then re-run the sync to regenerate the per-tool layout directories (plus root `AGENTS.md`, `CLAUDE.md`, `.mcp.json`); the exact set of tools is cyncia's to configure — see [`.cyncia/cyncia.conf`](./.cyncia/cyncia.conf), not MARSHAIL.
- [`AGENTS.md`](./AGENTS.md) — guidance for AI agents working in this repo (generated; authored under [`.agent-config/AGENTS.md`](./.agent-config/AGENTS.md)).

## License

MARSHAIL is licensed under the **MIT License**.
See [`LICENSE`](./LICENSE).
