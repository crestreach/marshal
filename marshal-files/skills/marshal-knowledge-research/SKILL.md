---
name: marshal-knowledge-research
description: Research a topic, codebase, or part of a codebase and return a condensed, structured delta the caller can either consume directly or feed into marshal-knowledge-maintain for promotion. Does not write to the knowledge tree by default.
---

# marshal-knowledge-research

Knowledge skill — read-only by default.

## When to use

- The agent does not know which knowledge file answers a question.
- A topic file is missing or marked stale and the caller wants a fresh
  summary without committing to canonical knowledge yet.
- Pre-analysis support during MARSHAL stage 3 (Analysis) or
  mid-implementation when an unknown surfaces.

## Prerequisites

- `.marshal/knowledge/` exists. (May be sparse — that is exactly when
  this skill is most useful.)

## Inputs (read at start)

- A topic / question / scope (paths, modules, behaviors).
- Optional: which existing knowledge files (if any) to use as starting
  context.
- Read-only access to the repo.
- [`.marshal/config.yml`](../../config.yml) for `knowledge.contract_ref`
  and `knowledge.representation_ref`, then both configured references
  (defaults: [`../../references/knowledge-contract.md`](../../references/knowledge-contract.md),
  [`../../references/knowledge-markdown-spine.md`](../../references/knowledge-markdown-spine.md)).

## Workflow

1. Read entry point, knowledge contract, active implementation, and INDEX.
2. Identify the smallest set of code paths needed to answer the
   question.
3. Study those paths (semantic-aware tools preferred over raw reads).
4. Synthesize a condensed delta. Cite specific files and (where
   useful) line ranges.
5. Stamp `verified_against_commit` with the current short SHA.
6. **Return** the delta. Do not modify the knowledge tree.

## Outputs

- A single delta following the active knowledge implementation
  (default: Markdown Spine frontmatter from
  [knowledge-markdown-spine](../../references/knowledge-markdown-spine.md), kind
  `reference` or `explanation`), ≤ ~150 lines body.
- An "open questions" trailer for items the repo could not answer.

## Handoff

- **Caller (typical):**
  [`marshal-analysis`](../marshal-analysis/SKILL.md) or
  [`marshal-implement`](../marshal-implement/SKILL.md). The caller
  consumes the delta inline.
- **For promotion to canonical knowledge:** the caller drops the
  returned delta into `.marshal/knowledge/learn/inbox/` and invokes
  [`marshal-knowledge-maintain`](../marshal-knowledge-maintain/SKILL.md)
  mode `from-learning`.

## Subagent

Strongest fresh-context candidate:
[`marshal-researcher`](../../agents/marshal-researcher.md). Keeps repo
scanning out of the parent context entirely.
