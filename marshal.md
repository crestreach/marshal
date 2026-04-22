# MARSHAL — Process Documentation

**MARSHAL** = **M**ethod for **A**I-assisted **R**equirements Engineering, **S**oftware Implementation, with **H**uman **A**pproval and **A**daptive **L**earning.

This document defines MARSHAL, a practical AI-assisted SDLC for features, bugfixes, refactors, and technical debt work. It covers the full loop: framing a change, narrowing repo analysis, shaping an executable plan, implementing in reviewable slices, verifying, rolling out, and promoting durable learnings back into the system — all with explicit human approval gates between stages.

## Why this process exists

AI-assisted development can fail in a few predictable ways:
- broad repo search creates context pollution
- implementation starts before the change is framed correctly
- the plan drifts away from the code
- review feedback is handled ad hoc and never reflected back into the plan
- learnings are either lost or overfit to one case

This process avoids that by using:
- explicit intake
- focused (context-minimizing) code analysis
- structured planning
- controlled execution
- explicit verification
- release discipline
- curated learning

Many complex SDLC processes already exist. This document does not try to invent another one — it gathers common-sense practices I have been using, usually in parts, learned across multiple projects and from studying multiple frameworks. Its purpose is to make this common-sense process easier to follow stage by stage, and to automate knowledge learning over time.

## Core principles

- One canonical flow: every phase produces explicit artifacts (durable context) that feed the next phase.
- Keep the plan as the source of truth. Agent “plan mode” is only a helper, never the canonical plan.
- Default to small, reviewable slices; use larger PRs only at integration boundaries.
- Replanning is mandatory whenever assumptions change, but only at the affected level.
- Every phase emits:
  - a **change log**
  - a **learning file**
- Learning files contain only **generalizable lessons**:
  - changes to rules
  - flow improvements
  - skill updates
  - agent instruction updates
  - reusable testing/review patterns
  - recurring repo conventions
- Learning files must **not** be polluted with case-specific details

## 5. Learning model

Each phase produces a learning file.

The learning file is **not** a narrative diary.
It is a curated list of reusable, general lessons.

Allowed:
- “For this repo, tracing request flow should start at handlers, not controllers.”
- “For schema-affecting changes, rollout notes must always include rollback data handling.”
- “Use L4 implementation detail only when shared contracts are involved.”

Not allowed:
- case-specific bug details that do not generalize
- one-off code specifics
- transient observations with no reuse value

At the end of the change, phase learnings are merged into a `learning-rollup.md`.
That rollup is reviewed and optionally promoted into:
- `AGENTS.md`
- skill files
- rules docs
- test strategy docs
- team checklists
- reusable prompts
- memory/knowledge files

Promotion rule:
- promote only recurring or clearly reusable guidance

## What this process borrows from

This process adapts several established ideas into one practical operating model:

- **Shape Up**:
  - shaping before building
  - bounded scopes/slices
  - explicit tradeoffs around what belongs in a delivery slice

- **lightweight ADR / RFC practice**:
  - only write decision records for decisions that matter
  - keep them concise and close to the code

- **trunk-based and small-batch delivery**:
  - integrate frequently
  - keep merge boundaries meaningful
  - do not over-fragment review into tiny PRs

- **testing strategy biased toward confidence**:
  - use unit tests where logic density is high
  - use integration tests where behavior confidence matters most
  - add E2E only where the risk justifies it

- **blameless learning/postmortem culture**:
  - capture what should change in the system/process
  - avoid storing blame or one-off details as long-term rules

- **modern agent workflow guidance**:
  - keep one canonical process
  - use planning features as helpers, not as the source of truth
  - parallelize only when decomposition is real and safe


---

# Concept model

---

## Canonical artifact chain

Every change should move through this chain:

**Change Brief → Analysis, Repo Recon → Architecture Notes (optional) → Delivery Plan → Implementation + Phase Logs + Phase Learnings → Verification Report → Rollout Note → Learning Rollup**

Each artifact becomes input to the next phase.


---

## Plan hierarchy

Use exactly 4 planning depth levels.

### L1 — Phase / Slice
A coherent slice of work that is reviewable as a larger chunk and may map to one PR. One PR might also span multiple phases / slices.

Contains:
- goal
- scope / non-goals
- dependencies
- rollout boundary
- review boundary
- optional parallel tag(s): `<~T1>`, `<~T2>`

### L2 — Work Packet
A reviewable internal packet inside a phase. Normally discussed directly with the AI and user, not as its own PR. A work packet would usually consist of one or multiple commits. However, a commit is **not** a planning level.

Contains:
- objective
- acceptance criteria
- touched components
- risks / unknowns
- test intent
- status

### L3 — Steps / Substeps
Execution-oriented decomposition of a work packet.

Contains:
- ordered steps
- optional parallel tags
- dependencies between steps
- done criteria

### L4 — Implementation Steps
Optional rough technical design detail.

Use only when useful:
- class/module/service changes
- method/function/API changes
- schema/migration details
- event/queue/topic changes
- config/flag wiring
- rough interfaces and contracts

Do **not** force L4 everywhere. Use it for risky, cross-cutting, public-interface, migration, concurrency, or security-sensitive work. It should be specified in the planning promt whether this level should be included.



## Plan status markers

Use simple inline markers:

- `[TODO]`
- `[IN PROGRESS]`
- `[DONE]`
- `[BLOCKED]`
- `[DROPPED]`
- `[ADDED yyyy-mm-dd]`
- `[CHANGED yyyy-mm-dd]`
- `[FIXUP yyyy-mm-dd]`
- `[REVERT yyyy-mm-dd]`

## 4. Parallelism

Parallel work is optional and should be marked only when useful. For parallelizable items, append optional thread markers:
- `<~T1>`
- `<~T2>`
- `<~T3>`

Rules:
- same-level items with the same thread tag may run in parallel if dependencies allow
- if parallel work touches the same files/contracts, mark it as `shared-surface`
- do not force parallelism where coordination cost is higher than the gain
- parallel tags are optional, not mandatory
- parallelism should happen mainly at:
  - phase level
  - work packet level
  - occasionally step level


## Specification change

A specification change may happen at any time. When it does:
- amend `change-brief.md` with the new or changed requirement
- re-run Analysis, narrowed to the affected surface, and update `repo-recon.md`
- update `delivery-plan.md`:
  - keep already-finalized work as `[DONE]` where it remains valid
  - add new phases/packets/steps for new requirements, marked `[ADDED yyyy-mm-dd]`
  - add explicit items for work that must be undone, marked `[REVERT yyyy-mm-dd]`
  - mark anything no longer needed `[DROPPED yyyy-mm-dd]`


## Lifecycle - stages

### Terminology

Individual lifecycle steps will be referred to as **stages**, as opposed to phases/slices, work packets, steps, substeps, implementation steps (which are elements of the implementation plan)


## 0. Intake / framing

### Goal
Create a crisp, testable understanding of the change before repo analysis begins.

### What happens here
For a feature:
- define the user/problem outcome
- define scope and non-goals
- define acceptance criteria
- define technical/operational constraints
- define rollout expectations

For a bugfix:
- capture repro steps
- define expected vs actual
- define impact/blast radius
- collect evidence
- capture suspected areas if known

### Exit criteria
- goal is explicit
- scope/non-goals are explicit
- acceptance criteria are explicit
- constraints and rollout expectations are explicit

### Artifacts produced
- `change-brief.md`:
    For a feature:
    - problem / user outcome
    - scope / non-goals
    - acceptance criteria
    - constraints
    - rollout expectations
    For a bugfix:
    - repro steps
    - expected vs actual
    - impact / severity
    - evidence
    - suspected area if known
- `logs/phase-0.changelog.md`
    Record:
    - clarifications added
    - scope changes
    - acceptance criteria changes
- `learning/phase-0.learning.md`
    Record only reusable learnings, e.g.:
    - “Require explicit repro template for bugfix intake”
    - “Always capture rollout expectation for externally visible changes”


---

## 1. Research / analysis

### Goal
Understand the requirement and narrow the repo search surface before planning.


### What happens here
- identify likely bounded context / subsystem
- identify likely files / classes / services / tables / APIs
- capture invariants and contracts
- locate existing tests and test seams
- identify unknowns / risks
- explicitly exclude irrelevant areas to avoid context pollution

### Exit criteria
- likely change surface is identified
- key invariants/contracts are captured
- unknowns are explicit
- planning can proceed without broad repo search

### Artifacts produced
- `repo-recon.md`
    Include:
    - likely bounded context / subsystem
    - likely files / classes / services / tables / APIs
    - invariants and contracts
    - existing tests and test seams
    - unknowns / risks
    - excluded areas to avoid context pollution
- `logs/phase-1.changelog.md`
    Record:
    - files inspected
    - architecture notes added
    - assumptions confirmed / rejected
    - narrowed search surface
- `learning/phase-1.learning.md`
    Record only generalized learnings, e.g.:
    - “In this repo, handlers are better entry points than controllers for tracing flow”
    - “Always inspect feature-flag definitions before planning cross-module changes”

---

## 1.5. Architecture / design

### Goal
Agree on a general implementation concept before planning.

### When to use
Optional. Advised for larger or less-obvious topics. Skip when the shape of the solution is already clear.

### What happens here
- the human proposes a design / architecture, or asks the AI to propose one
- the concept can be defined at any abstraction level, or at multiple levels (e.g. high-level components, module layout, APIs / schemas), depending on the case
- design decisions are discussed and captured as they are made

Inputs:
- `change-brief.md`
- `repo-recon.md`
- general knowledge of the repository

### Exit criteria
- the chosen implementation concept is documented
- key design decisions are captured

### Artifacts produced
- `architecture-notes.md`
    Free-text notes describing:
    - the chosen implementation concept
    - design decisions made and their rationale
    - abstraction level(s) covered
- `logs/phase-architecture.changelog.md`
    Record:
    - concepts proposed / rejected / accepted
    - design changes
- `learning/phase-architecture.learning.md`
    Record only reusable learnings.

---

## 2. Plan / shape

### Goal
Convert the brief + recon into an executable, reviewable plan.

### What happens here
- define phases/slices
- define work packets
- define execution steps
- add L4 implementation detail only where needed
- mark review boundaries
- mark PR boundaries
- mark rollout boundaries
- mark safe parallelism using `<~Tn>` if helpful

### Exit criteria
- plan is approved
- review boundaries are explicit
- PR boundaries are explicit
- parallelizable items are marked where useful
- L4 details are added only where worth it or when explicitly requested


### Required artifacts
- `delivery-plan.md`
    Suggested structure:

    # Delivery Plan

    ## P1. Phase / Slice title `[TODO]` `<~T1>`
    Goal:
    Dependencies:
    Review boundary:
    PR boundary:
    Rollout boundary:

    ### W1. Work Packet title `[TODO]`
    Objective:
    Acceptance criteria:
    Touched components:
    Risks / unknowns:
    Test intent:

    #### S1. Step `[TODO]`
    - substep
    - substep

    ##### I1. Implementation step (optional)
    - module/class changes
    - method/function changes
    - API/schema changes

    #### S2. Step `[TODO]`

    ### W2. Work Packet title `[TODO]` `<~T2>`

    ## P2. Phase / Slice title `[TODO]`

- `logs/phase-2.changelog.md`
    Record:
    - plan additions/removals
    - packet splits/merges
    - dependency changes
    - review boundary changes
    - PR boundary changes

- `learning/phase-2.learning.md`
    Record only reusable learnings, e.g.:
    - “For medium changes, define PR boundary at phase level, not packet level”
    - “Use L4 implementation steps only for shared interfaces and migrations”


### Replanning rule

Replan when:
- scope changes
- root cause changes
- hidden dependency appears
- tests reveal missing work
- review requests structural change
- rollout or migration risk changes

Replanning scope:
- patch only the affected packet/phase unless the impact propagates

Replanning mechanics:
- update `delivery-plan.md`
- mark changed items
- append rationale to changelog
- add only generalized reusable insights to learning file


---

## 3. Implement

### Goal
Execute the approved plan.

### Cycles
Implementation runs in cycles. The human chooses the granularity of each cycle: a phase/slice, a work packet, or a step/substep.

A cycle roughly follows four steps: pick the target, confirm the plan is still accurate, execute, close the cycle (update statuses, changelog, tests). Use this as a guide, not a rigid checklist.

Within a cycle the human can:
- ask the AI to implement plan items
- ask the AI for a custom programming task outside the current plan item
- write code themselves and discuss with the AI
- ask for a review at any time

If the plan has to be adapted at any point during implementation, do it explicitly in `delivery-plan.md` before continuing. Very small changes or extensions don't need a plan update.

### Rules
- implement against the current approved plan only
- update status markers live
- keep diffs small enough to reason about
- a work packet is an execution unit, not a PR unit
- a commit is not a planning unit

### Review model

Default:
- user reviews **within the plan** and in direct discussion with the AI at work-packet level
- PR review is used for a **larger integration boundary**:
  - whole phase or the full approved slice or multiple phases / slices
  - in special cases, a work packet or multiple packets

Therefore:
- **work packets are usually reviewed conversationally**
- **internal review often happens below PR level**
- **PRs are usually phase-level / slice-level or scope multiple phases / slices or the whole implementation**

PRs should normally be assigned to another human developer for review, but can alternatively / additionally be reviewed by a reviewing AI agent.

### If changes are requested during review

Do not edit silently.

Update the plan in `delivery-plan.md` using one of these patterns:

#### Small correction inside same packet
- add a new step/substep under the current work packet
- mark it `[ADDED yyyy-mm-dd]` or `[FIXUP yyyy-mm-dd]`

#### Correction that changes scope/approach
- mark affected packet `[CHANGED yyyy-mm-dd]`
- update remaining steps below it
- update dependencies if needed

#### Correction that deserves isolation
- create a new sibling work packet:
  - `W1a. Review fixups [ADDED yyyy-mm-dd]`

Always log:
- why the correction was needed
- what changed in plan structure
- whether already-completed work remains valid

### Exit criteria for a work packet
- acceptance criteria met
- plan status updated
- tests updated
- changelog updated

### Artifacts produced
- `logs/phase-N.changelog.md`
    For each implementation phase, record:
    - steps completed
    - code areas changed
    - tests added/updated
    - review feedback received
    - fixups applied
    - commits/branches/PR references if used

- `learning/phase-N.learning.md`
  Record only reusable learnings, e.g.:
  - “For this repo, integration tests should be added before refactor on shared services”
  - “Review quality improved when packet descriptions included touched contracts explicitly”
  - “Parallel work on adjacent modules still conflicted because config wiring was shared”

- `delivery-plan.md`
    Update statuses in the delivery plan

---

## 4. Verify

### Goal
Run an explicit verification gate, separate from coding. Re-run the Implementation phase in case of failed verification.

//TODO:
### Testing guidance
- for bugfixes: reproduce first, then add a regression test where possible
- prefer integration tests for behavior confidence
- add unit tests for dense logic / edge cases
- add E2E only for critical user journeys or release risk

### Exit criteria
- verification passed
- any required replan/fixup is added back into the plan, and the Implementation phase is run again

### Required artifacts
- `verification-report.md`
    For each completed phase / PR boundary:
    - acceptance criteria check
    - static analysis / lint / typecheck
    - unit tests
    - integration tests
    - migration checks
    - observability/logging checks
    - security/privacy checks if relevant
    - open issues / residual risks

//TODO maybe change everywhere to append?
- append results to `logs/phase-N.changelog.md`
    Append:
    - verification result
    - defects found
    - rework triggered
    - final status

- append reusable lessons to `learning/phase-N.learning.md`
    Record only reusable learnings, e.g.:
    - “Bugfix flow should require regression test before final verification when reproducible”
    - “Shared fixtures created false positives; add rule to isolate integration fixtures”

---

## 5. PR / integration / merge

### Goal
Use PRs only at meaningful integration boundaries.

### Recommended default
- one PR per whole implementation (all phases/slices)
- one PR per phase/slice
- in special cases, one PR per group of completed work packets that forms a coherent, testable delta

### Avoid
- one PR per tiny packet
- one PR per commit

### PR should include
- linked phase(s) / packet(s)
- change summary
- test summary
- rollout note
- known limitations
- follow-up packets if any

### If PR review requests changes
- changes must be reflected back into `delivery-plan.md`
- mark affected items `[FIXUP]` / `[CHANGED]` / `[ADDED]`
- append rationale to the phase changelog

---

## 6. Release / rollout

### Exit criteria
- relevant migrations are documented
- list of basic manual test scenarios to be run is generated
- release notes are logged

### Artifacts produced
- `rollout-note.md`
    Include:
    - introduced toggles, properties
    - log categories added/removed
    - porting instructions if necessary (for patches)
    - necessary migrations
    - rollback path
    - user-visible docs changes if needed or any other information that needs to be documented

- `logs/phase-rollout.changelog.md`
    Record 
    - additions/changes to the rollout note

- `learning/phase-release.learning.md`
    Record only reusable learnings, e.g.:
    - “Cross-service changes require rollout notes even for internal features”
    - “Always document rollback for schema-affecting changes”


---

## 7. Learn / improve the system

### Goal
Promote generalized learnings into durable system guidance. The user should approve the final update before merging the final update lists to individual buckets.

### Inputs
- all `learning/phase-*.learning.md` files

### Promotion targets
- `AGENTS.md`
- custom skill files
- rules / conventions docs
- reusable prompts
- checklists
- test templates
- architecture guidance
- memory/knowledge files

### Promotion rules
- keep only recurring, reusable guidance
- reject one-off case details
- prefer rule changes only when the signal is strong
- every promoted learning should be phrased as a reusable instruction or heuristic

### Output
- `learning-rollup.md`
  Merge and deduplicate, filter only high-value general learnings.

#### Buckets
- AGENTS updates
- README updates
- rules updates
  - coding standard updates
  - test strategy updates
  - repo navigation heuristics
- skill file updates, including review/plan convention updates

//TODO each lifecycle stage should be validated by the user, discussed if necessary, only then we can proceed to the next phase - that should be selected in the plan

---


---

## Recommended skills / contexts

### Skill 1 — Change Framer
Input:
- raw request

Output:
- `change-brief.md`

### Skill 2 — Repo Recon
Input:
- change brief

Output:
- `repo-recon.md`

### Skill 3 — Planner / Shaper
Input:
- brief + recon

Output:
- `delivery-plan.md`

### Skill 4 — Executor
Input:
- approved packet/phase

Output:
- code
- tests
- updated statuses
- changelog entries
- learning entries

### Skill 5 — Verifier / Reviewer
Input:
- diff + plan + optional tests

Output:
- `verification-report.md`
- fixup recommendations

### Skill 6 — Learning Curator
Input:
- all phase learning files

Output:
- `learning-rollup.md`
- updates to AGENTS / rules / skills / knowledge files (after approval)

---
