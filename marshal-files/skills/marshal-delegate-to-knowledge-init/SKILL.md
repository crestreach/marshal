---
name: marshal-delegate-to-knowledge-init
description: First-time bootstrap of the MARSHAL knowledge layer. Delegate when the user asks to "bootstrap the knowledge layer", "initialize .marshal/knowledge/", "scan the repo and draft repo/ and domains/ knowledge files", "build initial INDEX.md files", "set up the knowledge tree from scratch", or when running marshal-init in a repo whose .marshal/knowledge/ is empty or near-empty. The subagent (curator in `init` mode) detects subsystems / domains, drafts skeleton topic files, and generates indexes per the autonomy mode — writing them and returning a short summary in `auto`, or a summary diff for approval in `review`.
---

# marshal-delegate-to-knowledge-init

Delegate this to the [`marshal-knowledge-curator`](../../agents/marshal-knowledge-curator.md) subagent in mode `init`.
Do **not** inline the workflow — the agent owns it.

## Call contract

- **Subagent:** `marshal-knowledge-curator`
- **Mode:** `init`
- **Pass (request-specific only):** the intent ("bootstrap the knowledge layer for this repo") and any scoping hints.
  The agent reads the repo, build / package manifests, `.marshal/config.yml`, and the knowledge contract / implementation itself — do not pass them.
  The exact files produced are defined by the active knowledge implementation, not here.
- **Expect back:** a **summary** of detected subsystems / domains and unresolved heuristics.
  Not the full knowledge diff.
- **On result:** under `knowledge.autonomy: auto` (default) the tree is already written — read the summary and resolve any open follow-ups.
  Under `review`, work the diff with the human before it is applied.

## Fallback (no-subagent environments)

If subagents are not available, use [`marshal-knowledge-init`](../../skills-fallback/marshal-knowledge-init/SKILL.md).
Source of truth: [`marshal-knowledge-curator.md`](../../agents/marshal-knowledge-curator.md).
