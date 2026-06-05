# Promotion Rules — reference

Shared by knowledge skills that ingest `learn/inbox/` (mainly
`marshal-knowledge-maintain` mode `from-learning`, invoked at end of
MARSHAL stage 7 (Learn)).

Mirrors the rules in [marshal.md §7](../../marshal.md).

## Promote

- Recurring or clearly reusable guidance.
- Rule-shaped statements ("for this repo, X").
- Convention shifts ("from now on, Y").
- Stable facts about logic / architecture / decisions discovered during
  the change.

## Do not promote

- Case-specific bug details that do not generalize.
- One-off code specifics tied to a single commit.
- Transient observations with no reuse value.
- Narrative diary entries.

## Where things land

| Inbox content | Target |
|---|---|
| Rule / convention | synced rule (via config-sync) — out of knowledge scope |
| Skill / playbook | synced skill (via config-sync) — out of knowledge scope |
| Stable fact about a domain | `domains/<x>/{logic,contracts,...}.md` |
| Repo-wide architectural shift | `repo/architecture.md` |
| Decision with rationale | `decisions/adr-NNNN-<slug>.md` |
| Cross-cutting reusable lesson | `learn/rollups/<topic>.md` |
| Anything else | drop |

## Process

1. Read all files under `learn/inbox/`.
2. Cluster by topic; deduplicate.
3. For each cluster, decide promote / drop / out-of-scope (e.g. should be a
   rule, not knowledge).
4. For promotables, propose diffs against the target files.
5. After approval: apply diffs, archive the inbox files (or delete in
   `auto` mode), regenerate affected `INDEX.md`.
