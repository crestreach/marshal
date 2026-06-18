# Knowledge Contract

This is the tool-agnostic MARSHAL contract for agent-managed knowledge.
Knowledge is MARSHAL's mid- and long-term memory: durable repo facts, rationale, decisions, conventions, and reusable learnings that survive across changes.
It is also a body of **notes about the code** and a **map that helps narrow down code searches** — pointers from concepts and areas to where the relevant code lives, so agents can find the right files without re-exploring the whole repo each time.

The contract defines what any knowledge representation must provide.
The active implementation is configured separately by `knowledge.representation_ref` in `.marshal/config.yml`.

## Goals

- Give agents a **reliable map of where to look next** without loading half the repo into context.
- Separate **stable repo knowledge** (logic, architecture, conventions, invariants) from **process learnings** (the per-phase outputs of MARSHAL).
- Make knowledge **diffable and reviewable** (text in git).
- Allow knowledge to **evolve with the code** without git hooks or background daemons, via explicit dated stamps and an explicit maintenance step.
- Keep the system **tool-agnostic** by keeping the knowledge body behind this exchangeable representation reference.

## Two trees

MARSHAL separates the config-sync sources from the knowledge tree:

| Tree | Owner | Content | Fanned out to tool layouts? |
|---|---|---|---|
| `<user-config-source>/` (e.g. `.agent-config/`) | user / project | project-specific `agents/`, `skills/`, `rules/`, `mcp-servers/`, `AGENTS.md` | yes, via [cyncia](https://github.com/crestreach/cyncia) |
| `.marshal/` (config-sync source) | MARSHAL baseline | `marshal-*`-prefixed `agents/`, `skills/`, `rules/`, plus `AGENTS.md` | yes, via the same sync tool |
| `.marshal/knowledge/` | agents (under human approval) | repo knowledge: code notes, logic, architecture, decisions, learnings | no |

The first two are **config-sync sources**: the cyncia sync fans them out into tool-native layouts (`.cursor/`, `.claude/`, `.github/`, …).
The knowledge tree is excluded from that sync — it stays under `.marshal/knowledge/` and is read in place.
Agents reach it as `.marshal/ENTRYPOINT.md` instructs: an always-loaded root slice first, then progressively deeper folder indexes and topic files as a task needs them.

## Required capabilities

A MARSHAL knowledge representation must define:

- where canonical knowledge is stored;
- how agents discover available knowledge from a cheap root entry point;
- how topic files or records expose a stable identity, summary, scope, and freshness metadata;
- how agents select the smallest useful knowledge slice for a task;
- how updates are proposed, reviewed, and applied under `.marshal/config.yml` autonomy settings;
- how stale knowledge is detected against changed repo paths;
- how knowledge is split, merged, archived, or rebuilt as the repo changes;
- how deltas from research and phase learnings are promoted into canonical knowledge.

## Required metadata semantics

The representation may use files, records, generated indexes, or a retrieval sidecar, but it must expose these semantics to agents:

- stable `id` or equivalent key;
- `summary` for cheap discovery;
- scope information, usually repo paths or domain ownership;
- importance or loading priority;
- confidence or verification quality;
- freshness marker, usually date plus verified commit or equivalent source revision;
- links or parent/child relationships when knowledge is split.

The exact field names belong to the active implementation reference.

## Required update protocol

All write paths honor `knowledge.autonomy` in `.marshal/config.yml`:

- `review`: produce a diff or equivalent reviewable change set and wait for human approval.
- `auto`: apply the update directly and report what changed.

Knowledge updates must be traceable to one of these sources:

- initial repo scan (`marshal-knowledge-init`);
- changed repo paths after an implementation cycle (`marshal-knowledge-maintain from-changes`);
- reusable phase learnings (`marshal-knowledge-maintain from-learning`);
- scheduled or requested freshness checks (`marshal-knowledge-maintain rescan`);
- branch reconciliation (`marshal-knowledge-branch-merge`);
- larger structural rebuild (`marshal-knowledge-rebuild`).

## Replacing the implementation

To replace the knowledge implementation, add a new implementation reference under `.marshal/references/` (or another path reachable from `.marshal/`) and set `knowledge.representation_ref` to that file.
The implementation reference must satisfy this contract and describe its storage, metadata, discovery, staleness, update, promotion, split, merge, and rebuild rules.

Knowledge skills should change only when the workflow changes.
Pure storage, metadata, indexing, or retrieval changes belong in the implementation reference.