# Knowledge Contract

This is the tool-agnostic MARSHAIL contract for agent-managed knowledge.
Knowledge is MARSHAIL's mid- and long-term memory: durable repo facts, rationale, decisions, conventions, and reusable learnings that survive across changes.
It is also a body of **notes about the code** and a **map that helps narrow down code searches** — pointers from concepts and areas to where the relevant code lives, so agents can find the right files without re-exploring the whole repo each time.

The contract defines what any knowledge representation must provide.
The active implementation is configured separately by `knowledge.representation_ref` in `.marshail/config.yml`.

## Goals

- Give agents a **reliable map of where to look next** without loading half the repo into context.
- Capture **enough analyzed depth** that an agent can understand an area's behavior, contracts, and risky parts *without* re-scanning the code — the knowledge is the cached result of a code scan that already happened, not a table of contents.
- Derive knowledge **primarily from the code itself** (read from entrypoints inward), not only from pre-existing prose docs; pre-existing docs are corroborating input, never the sole source.
- Separate **stable repo knowledge** (logic, architecture, conventions, invariants) from **process learnings** (the per-phase outputs of MARSHAIL).
- Make knowledge **diffable and reviewable** (text in git).
- Allow knowledge to **evolve with the code** without git hooks or background daemons, via explicit dated stamps and an explicit maintenance step.
- Keep the system **tool-agnostic** by keeping the knowledge body behind this exchangeable representation reference.

## Two trees

MARSHAIL separates the config-sync sources from the knowledge tree:

| Tree | Owner | Content | Fanned out to tool layouts? |
|---|---|---|---|
| `<user-config-source>/` (e.g. `.agent-config/`) | user / project | project-specific `agents/`, `skills/`, `rules/`, `mcp-servers/`, `AGENTS.md` | yes, via [cyncia](https://github.com/crestreach/cyncia) |
| `.marshail/` (config-sync source) | MARSHAIL baseline | `marshail-*`-prefixed `agents/`, `skills/`, `rules/`, plus `AGENTS.md` | yes, via the same sync tool |
| `.marshail/knowledge/` | agents (under human approval) | repo knowledge: code notes, logic, architecture, decisions, learnings | no |

The first two are **config-sync sources**: the cyncia sync fans them out into tool-native layouts (`.cursor/`, `.claude/`, `.github/`, …).
The knowledge tree is excluded from that sync — it stays under `.marshail/knowledge/` and is read in place.
Agents reach it as `.marshail/ENTRYPOINT.md` instructs: an always-loaded root slice first, then progressively deeper folder indexes and topic files as a task needs them.

## Required capabilities

A MARSHAIL knowledge representation must define:

- where canonical knowledge is stored;
- how agents discover available knowledge from a cheap root entry point;
- how topic files or records expose a stable identity, summary, scope, and freshness metadata;
- how agents select the smallest useful knowledge slice for a task;
- how knowledge is produced at an **appropriate, locally-decided analysis depth** — derived from a code scan that follows the system's entrypoints and call paths into its complex and high-value areas, and split into as many levels of hierarchy as each area needs (no fixed number of levels);
- how updates are proposed, reviewed, and applied under `.marshail/config.yml` autonomy settings;
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

All write paths honor `knowledge.autonomy` in `.marshail/config.yml`:

- `review`: produce a diff or equivalent reviewable change set and wait for human approval.
- `auto`: apply the update directly and report what changed.

Knowledge updates must be traceable to one of these sources:

- initial repo scan (`marshail-knowledge-init`);
- changed repo paths after an implementation cycle (`marshail-knowledge-maintain from-changes`);
- reusable phase learnings (`marshail-knowledge-maintain from-learning`);
- scheduled or requested freshness checks (`marshail-knowledge-maintain rescan`);
- branch reconciliation (`marshail-knowledge-branch-merge`);
- larger structural rebuild (`marshail-knowledge-rebuild`).

## Replacing the implementation

To replace the knowledge implementation, add a new implementation reference under `.marshail/references/` (or another path reachable from `.marshail/`) and set `knowledge.representation_ref` to that file.
The implementation reference must satisfy this contract and describe its storage, metadata, discovery, staleness, update, promotion, split, merge, and rebuild rules.

Knowledge skills should change only when the workflow changes.
Pure storage, metadata, indexing, or retrieval changes belong in the implementation reference.