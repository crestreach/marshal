---
name: marshal-delegate-to-knowledge-init
description: First-time bootstrap of the MARSHAL knowledge layer. Delegate when the user asks to "bootstrap the knowledge layer", "initialize .marshal/knowledge/", "scan the repo and draft repo/ and domains/ knowledge files", "build initial INDEX.md files", "set up the knowledge tree from scratch", or when running marshal-init in a repo whose .marshal/knowledge/ is empty or near-empty. The subagent (curator in `init` mode) detects bounded contexts, drafts skeleton topic files, generates indexes, and returns a single proposed unified diff for human approval.
---

# marshal-delegate-to-knowledge-init

Delegate this to the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent in mode `init`. Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-knowledge-curator`
- **Mode:** `init`
- **Pass:** repo source tree (read-only); build / package manifests for hints; `.marshal/config.yml` (`knowledge.contract_ref`, `knowledge.representation_ref`); empty or near-empty `.marshal/knowledge/`.
- **Expect back:** unified diff covering `repo/{overview, architecture, bounded-contexts, entrypoints, build-test-run, conventions}.md`, `domains/<name>/{INDEX, purpose, logic, contracts, hotspots, tests}.md` skeletons, and `INDEX.md` files; summary of detected contexts and unresolved heuristics.
- **On result:** review and apply the diff (or auto-apply under `knowledge.autonomy: auto`). Resolve open follow-ups with the human.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-init`](../../skills-fallback/marshal-knowledge-init/SKILL.md). Source of truth: [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md).
