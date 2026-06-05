# Promotion Rules — reference

Shared by knowledge skills that ingest `learn/inbox/` (mainly
`marshal-knowledge-maintain` mode `from-learning`, invoked at end of
MARSHAL Learn stage).

Mirrors the rules in [marshal.md](../../marshal.md).

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
| Anything else that is still reusable | a general / miscellaneous topic in the active knowledge layer — **do not drop reusable knowledge** |
| Not reusable (see "Do not promote") | drop |

The exact target paths above reflect the default Markdown Spine layout;
the active knowledge implementation defines the real destinations (read
`knowledge.representation_ref`). The point is the routing intent, not the
literal folders.

## Process

1. Read all files under `learn/inbox/`.
2. Cluster by topic; deduplicate.
3. For each cluster, decide promote / drop / out-of-scope (e.g. should be a
   rule, not knowledge). Reusable items that fit no specific bucket go to
   the general / miscellaneous bucket rather than being dropped.
4. Apply the promotions per the autonomy mode: in `auto`, write the
   changes and return a short summary; in `review`, present a summary diff
   for approval first.
5. Archive the inbox files (or delete in `auto` mode) and regenerate
   affected `INDEX.md`.
