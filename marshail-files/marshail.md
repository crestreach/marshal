# MARSHAIL — Process Documentation

*Human-approved AI software engineering with a curated learning loop.*

**MARSHAIL** = **M**ethod for **A**I-assisted **R**equirements and **S**oftware Engineering, with **H**uman **A**pproval and **I**ncremental **L**earning.

This document defines MARSHAIL, a practical AI-assisted SDLC for features, bugfixes, refactors, and technical debt work.
It covers the full loop: framing a change, narrowing repo analysis, shaping an executable plan, implementing in reviewable slices, verifying, rolling out, and promoting durable learnings back into the system — all with explicit human approval gates between stages.

## Why this process exists

AI-assisted development can fail in a few predictable ways:
- broad repo search creates context pollution
- implementation starts before the change is framed correctly
- the plan and the code drift apart — as work proceeds the plan stops reflecting what was actually built, so it can no longer be trusted to guide the next step
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

Many complex SDLC processes already exist.
This document does not try to invent another one — it gathers common-sense practices I have been using, usually in parts, learned across multiple projects and from studying multiple frameworks.
Its purpose is to make this common-sense process easier to follow stage by stage, and to automate knowledge learning over time.

## Core principles

- One canonical flow: every phase produces explicit artifacts (durable context) that feed the next phase.
- Keep the plan as the single source of truth.
  `delivery-plan.md` is the canonical plan; an agent tool's built-in “plan mode” is only a scratchpad for shaping it, not a replacement for it.
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

## Learning model

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
- knowledge files

Promotion rule:
- promote only recurring or clearly reusable guidance

## What this process borrows from

This process adapts several established ideas into one practical operating model:

- **Shape Up**:
  - shaping before building
  - bounded scopes/slices
  - deliberate scope decisions — explicitly choosing what is in and out of scope for each slice

- **lightweight ADR / RFC practice**:
  - only write decision records for decisions that matter
  - keep them concise and close to the code

- **small-batch delivery — feedback-loop scope, merge boundaries, and PRs**:
  - keep the feedback loop short enough to stay in control and catch drift from the intended outcome early
  - keep merge boundaries meaningful
  - do not over-fragment review into tiny PRs

- **testing strategy biased toward confidence**:
  - use unit tests where logic density is high
  - use integration tests where confidence that components work together matters most
  - add E2E only where the risk justifies it

- **blameless learning/postmortem culture**:
  - capture what should change in the system/process
  - avoid storing blame or one-off details as long-term rules

- **modern agent workflow guidance**:
  - keep one canonical process
  - use an agent tool's built-in planning features to help shape the plan, but keep `delivery-plan.md` as the source of truth
  - parallelize only when decomposition is real and safe


---

# Concept model

---

## Canonical artifact chain

Every change should move through this chain:

**Specification → Change Brief → Analysis, Repo Recon → Architecture Notes (optional) → Delivery Plan → Implementation (code) + Implementation Report + Phase Logs + Phase Learnings → Verification Report → Rollout Note → Learning Rollup**

Each artifact becomes input to the next phase.

### Where the artifact chain lives

The whole per-change artifact chain lives in a **per-change working folder** under `.marshail/work/<change-id>/`:

- `<change-id>` is the ticket / issue number when the user gives one (e.g. `PROJ-1234`), otherwise a dated slug `YYYY-MM-DD-<brief-slug>`.
- Inside it: `specification.md`, `change-brief.md`, `repo-recon.md`, optional `architecture-notes.md`, `delivery-plan.md`, `implementation-report.md`, `verification-report.md`, `rollout-note.md`, `learning-rollup.md`, plus `logs/` (see below) and `learning/` (per-phase learning files).
- `.marshail/work/current` is a one-line pointer naming the active `<change-id>`.
  Agents and the driver read it at the start of a session so the active working folder never has to be guessed.
- `.marshail/work/` is transient and **gitignored** by default — the durable cross-change record is knowledge, not the artifact chain.

The working folder is created by whichever component starts the change — the [`marshail-driver`](agents/marshail-driver.md) in the driver-mediated model, or the first specialist agent / skill in the direct model — not the driver alone.

The `logs/` folder is what lets any session **resume** from disk.
It holds three kinds of file, kept separate so resuming stays cheap:

- `resume.md` — a single short "where are we" file (current stage, active phase / cycle, next action, open decisions).
  It is **rewritten and compacted, not appended**, on each update, and is the only log loaded by default on resume.
- `<agent>.log.md` — one append-only log per agent role (e.g. `planner.log.md`, `implementer.log.md`); detailed history, consulted only when a role's thread must be reconstructed.
- `stage-<n>-<name>.changelog.md` / `phase-<n>.changelog.md` — the changelog of record: one `stage-…` file per lifecycle stage (e.g. `stage-3-analysis`), plus one `phase-…` file per delivery-plan L1 phase during Implement (e.g. `phase-2`, optionally `phase-2-<slug>`).

Because an agent can run many times for one change (replanning, one implementation cycle per phase), each invocation works against a **run section** (`## Run <n> — <timestamp>`) in its `<agent>.log.md`.
The caller does **not** pass a run id: an agent **marks its run section finished** when its work is done, and the next invocation tells a **fresh run** (last section finished → open a new one) from a **resume** (last section unfinished → continue it), unless the prompt explicitly says otherwise.
Every agent refreshes `resume.md` and appends to its run log before handing back, so the next dispatch continues where the last left off.
The full contract lives in [`references/activation-protocol.md`](references/activation-protocol.md).

When a change is finalized, the working folder is **archived** to `.marshail/archive/<change-id>/` (retained for reference; deleted instead when `knowledge.autonomy: auto` and the user has not asked to keep it), and `.marshail/work/current` is cleared.
The [`marshail-driver`](agents/marshail-driver.md) performs this move on final handoff by default; the user can also trigger it on demand (or do it manually).


---

## Plan hierarchy

MARSHAIL defines up to 4 planning levels.
**Use only as many as the change needs.**
A trivial fix may be a single phase with one step (no L2/L3/L4 at all).
A larger change may go all the way to L4 in places.
The agent plans down to whatever depth genuinely helps the next implementation cycle — unless the user has explicitly pinned a target depth, in which case that pin is honored.

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
A reviewable internal packet inside a phase.
Normally discussed directly with the AI and user, not as its own PR. A work packet would usually consist of one or multiple commits.
However, a commit is **not** a planning level.

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

### Choosing the right depth

- **Always have at least L1** for the whole change so the overall shape is agreed (a single phase counts).
- **Stop deepening when going further wouldn't change behavior in the next implementation cycle.**
  Trivial work may legitimately stop at L1 + a one-line objective.
- **Go to L3 / L4** when the work is risky, cross-cutting, public- interface, migration, concurrency, or security-sensitive — or when the user asks for it.
- **Per-area depth is fine.**
  One phase may live at L2 while another goes to L4.
- **The user pins.**
  If the user specifies a target depth ("plan only to L2", "go to L4 for the auth work"), follow it.
  Otherwise the agent picks pragmatically and surfaces the choice for approval.
- Not every level has to be filled in up front — see "Staged planning" in stage 5.



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

## Parallelism

Parallel work is optional and should be marked only when useful.
For parallelizable items, append optional thread markers:
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


## Implementation round and implementation cycles

Two cycle scales exist inside the lifecycle — the big one groups three high-level stages that can repeat for parts of the plan, the small one drives the Implement stage itself.

### Implementation round (big)

Stages 6a Implement, 6b Verify, and 6c Review / PR / merge are still three separate high-level stages, but they run together as one **implementation round**.
A round can run:
- **once** for the whole change — one Implement, one Verify, one PR at the end
- **per phase / slice** — each phase is implemented, verified, and merged before the next begins
- occasionally **per work packet or small group of packets**, when a coherent, testable delta warrants its own integration boundary

Rule: **every PR must be preceded by a Verify stage for its content**.
Verification is never skipped before merge.

```mermaid
flowchart LR
    I[Implement] --> V[Verify]
    V --> P[Review / PR / merge]
    P -. next round .-> I
```

### Implementation cycle (small)

Inside the Implement stage, work itself runs in smaller **implementation cycles** — pick a target (phase / packet / step), execute it, close the cycle.
A round contains one or more cycles (see "Implementation cycles" in stage 6).


## Specification change

A specification change may happen at any time.
When it does:
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

### Overview

```mermaid
flowchart LR
    S["1. Specification<br/>(optional)"] --> A["2. Intake<br/>(optional)"]
    A --> B["3. Analysis<br/>(optional)"]
    B --> C["4. Architecture<br/>(optional)"]
    C --> D["5. Plan<br/>(mandatory)"]
    subgraph R5["6. Implementation round"]
        direction LR
        I[Implement] --> V[Verify]
        V --> P[Review / PR / merge]
    end
    D --> R5
    R5 -. next round .-> R5
    R5 --> Ro["7. Rollout<br/>(optional)"]
    Ro --> L["8. Learn<br/>(optional)"]
```

Stages **6a Implement**, **6b Verify**, and **6c Review / PR / merge** together form one **implementation round** (see the Concept model).
The dotted self-loop shows that the round may repeat — once for the whole change, or per phase/slice.

### Stage optionality

MARSHAIL is meant to scale with the size of the change.
Only **stage 5 Plan** is mandatory — `delivery-plan.md` is the canonical source of truth for the change and must always exist.
Every other stage is optional and may be skipped when it would not add value.
Practical guidance:

- **Trivial changes** (typo, one-line config, obvious patch): produce a minimal one-section plan, implement, and stop.
  Skip Specification, Intake, Analysis, Architecture, Verify-as-separate-stage, Rollout, and Learn.
- **Small but non-trivial changes** (a focused bugfix or a small feature): a short plan plus an Implement+Verify round is usually enough.
  Specification / Intake / Analysis can be folded into the plan's framing section if separate artifacts are not justified.
- **Larger or risky changes**: keep the full pipeline.
  Architecture is recommended whenever the shape of the solution is not obvious.
- **Always required regardless of size**: any PR must still be preceded by Verify for its content (see stage 6b).

If a stage is skipped, do not invent its artifact.
The downstream skill that would have consumed it must be able to proceed without it (its `Inputs` section says which artifacts are optional).
The chosen scope (which stages are run, which are skipped) should be agreed with the user up front and recorded as the first lines of `delivery-plan.md`.



## 1. Specification / clarify (optional)

### Goal
Turn the user's raw prompt into an explicit, agreed specification before any framing or repo work begins.

### When to skip
For trivial changes, or when the user's prompt is already unambiguous and self-contained.
The clarifications can also be folded into stage 2 Intake when both stages would be light.

### What happens here
- The user provides a prompt (feature idea, bug, refactor, tech-debt note).
- The agent works **with** the user to clarify the request.
- The agent **does not assume**.
  Where the prompt is ambiguous, incomplete, or contradictory, the agent lists the open points and asks targeted questions before proceeding.
- The agent flags problems, risks, or disagreements explicitly and discusses them with the user rather than silently working around them.
- An optional **acceptance checklist** is produced when it is useful for the change at hand.
- Specification is approved by the user before moving on.

### Exit criteria
- the request is captured in the user's words plus any agreed clarifications
- ambiguities are explicitly listed and either resolved or accepted as open
- agent objections / risks are recorded with the user's response
- specification is approved by the user

### Artifacts produced
- `specification.md` Include:
    - the original user prompt (verbatim)
    - clarified intent (the agreed restatement)
    - explicit assumptions, marked as such
    - open questions still unresolved (if any)
    - agent concerns / disagreements raised, and how they were resolved
    - optional acceptance checklist (the conditions the user expects to see satisfied)
- `logs/stage-1-specification.changelog.md` Record:
    - questions asked and answers received
    - clarifications added
    - assumptions promoted to agreed facts
    - agent concerns raised and outcomes
- `learning/stage-1-specification.learning.md` Record only reusable learnings, e.g.:
    - “Always ask about target environment before clarifying scope”
    - “For bug reports, require expected vs actual upfront”

### Skill / agent
- Subagent: [`marshail-specifier`](agents/marshail-specifier.md)
- Delegate skill: [`marshail-delegate-to-specify`](skills/marshail-delegate-to-specify/SKILL.md)
- Fallback skill: [`marshail-specify`](skills-fallback/marshail-specify/SKILL.md)

---

## 2. Intake / framing (optional)

### Goal
Turn the approved specification into a crisp, testable framing for engineering before repo analysis begins.

### When to skip
For trivial changes; or when the specification already contains scope, acceptance criteria, and constraints in enough detail to plan against directly.

### Inputs
- `specification.md` from stage 1 (if produced)

### What happens here
For a feature:
- define the problem being solved and the outcome the change should deliver for the user
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
- `change-brief.md`: For a feature:
    - problem and target user outcome
    - scope / non-goals
    - acceptance criteria
    - constraints
    - rollout expectations For a bugfix:
    - repro steps
    - expected vs actual
    - impact / severity
    - evidence
    - suspected area if known
- `logs/stage-2-intake.changelog.md` Record:
    - clarifications added
    - scope changes
    - acceptance criteria changes
- `learning/stage-2-intake.learning.md` Record only reusable learnings, e.g.:
    - “Require explicit repro template for bugfix intake”
    - “Always capture rollout expectation for externally visible changes”


---

## 3. Research / analysis (optional)

### Goal
Understand the requirement and narrow the repo search surface before planning.

### When to skip
For changes whose surface is already known (e.g. a single file or component the user named).
Knowledge from `.marshail/knowledge/` may also make a separate recon redundant for well-mapped areas.


### What happens here
- identify the likely subsystem / domain
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
- `repo-recon.md` Include:
    - likely subsystem / domain
    - likely files / classes / services / tables / APIs
    - invariants and contracts
    - existing tests and test seams
    - unknowns / risks
    - excluded areas to avoid context pollution
- `logs/stage-3-analysis.changelog.md` Record:
    - files inspected
    - architecture notes added
    - assumptions confirmed / rejected
    - narrowed search surface
- `learning/stage-3-analysis.learning.md` Record only generalized learnings, e.g.:
    - “In this repo, handlers are better entry points than controllers for tracing flow”
    - “Always inspect feature-flag definitions before planning cross-module changes”

---

## 4. Architecture / design (optional)

### Goal
Agree on a general implementation concept before planning.

### When to use
Optional.
Advised for larger or less-obvious topics.
Skip when the shape of the solution is already clear.

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
- `architecture-notes.md` Free-text notes describing:
    - the chosen implementation concept
    - design decisions made and their rationale
    - abstraction level(s) covered
- `logs/stage-4-architecture.changelog.md` Record:
    - concepts proposed / rejected / accepted
    - design changes
- `learning/stage-4-architecture.learning.md` Record only reusable learnings.

---

## 5. Plan / shape (mandatory)

### Goal
Convert the brief + recon (or, for lightweight runs, the prompt itself) into an executable, reviewable plan.

### Why mandatory
`delivery-plan.md` is the canonical source of truth for the change.
Every change — even a one-line fix — has a plan, even if that plan is a single phase with a single step.
Implementation never proceeds without it.

### What happens here
- agree on initial planning depth — both the **target depth** (do we plan to L1, L2, L3, or L4? possibly different per area) and the **timing mode** (full vs. staged vs. mixed; see below)
- define phases/slices
- define work packets only where the agreed depth includes L2
- define execution steps only where the agreed depth includes L3
- add L4 implementation detail only where it pays off (or where the user asked for it)
- mark review boundaries
- mark PR boundaries
- mark rollout boundaries
- mark safe parallelism using `<~Tn>` if helpful

### Exit criteria
- plan is approved to the agreed depth (which may stop above L4 — or even above L2/L3 — for simple work)
- review boundaries are explicit
- PR boundaries are explicit
- parallelizable items are marked where useful
- depth-per-area, if non-uniform, is recorded so the implementer knows where to expect detail and where to use judgment


### Required artifacts
- `delivery-plan.md` Suggested structure:

    # Delivery Plan

    Planning mode: full | staged | mixed
    Target depth: L1 / L2 / L3 / L4 (per area, e.g. "L2 default; L4 in P1")

    ## P1. Phase / Slice title `[TODO]` `<~T1>`
    Goal: Dependencies: Review boundary: PR boundary: Rollout boundary:

    ### W1. Work Packet title `[TODO]`
    Objective: Acceptance criteria: Touched components: Risks / unknowns: Test intent:

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

- `logs/stage-5-plan.changelog.md` Record:
    - plan additions/removals
    - packet splits/merges
    - dependency changes
    - review boundary changes
    - PR boundary changes

- `learning/stage-5-plan.learning.md` Record only reusable learnings, e.g.:
    - “For medium changes, define PR boundary at phase level, not packet level”
    - “Use L4 implementation steps only for shared interfaces and migrations”
    - “Use staged planning when later phases depend on decisions made in earlier ones”
    - “For this area, detailed plans below L2 tend to churn — plan L3/L4 just in time”


### Staged planning

Planning has two independent dials:

1. **Target depth** — how far down (L1 / L2 / L3 / L4) the plan goes.
   May vary per area.
   Default: agent picks the shallowest depth that still makes the next implementation cycle unambiguous; user may pin a different depth.
2. **Timing mode** — when the planned levels are filled in.

Timing modes:
- **Full plan up front** — everything at the chosen target depth is planned before implementation starts.
  Good default for small or well-understood changes.
- **Staged / rolling plan** — higher levels are planned up front; lower levels are filled in just in time, phase by phase (or packet by packet).
  Good for larger or less-certain work where deeper details would likely churn.
- **Mixed** — rough plan for the whole story plus a detailed plan for the first phase(s).
  The rest is deepened as earlier phases finish.

Rules:
- The initial plan must always cover L1 for the whole change, so the overall shape is agreed.
- Each phase/packet must be planned to the depth needed for its implementation cycle(s) **before** that cycle starts.
  No item is implemented without its own plan complete to the required depth.
- Deepening is a normal, expected update — not a replan.
  Log it to the phase changelog, but do not treat it as a scope change.
- If deepening reveals that higher-level assumptions were wrong, fall back to the Replanning rule.
- The chosen target depth (per area, if non-uniform) and timing mode are captured once in `delivery-plan.md`; subsequent deepening passes are logged to the relevant phase changelog.

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

## 6. Implementation round: Implement, Verify, Review / PR

Three high-level stages — **Implement**, **Verify**, and **Review / PR / integration / merge** — run together as one **implementation round**.
They remain distinct stages, but are bundled here because they always flow together and may repeat for parts of the plan (once for the whole change, or per phase / slice).

Rule: **every PR must be preceded by a Verify stage for its content**.
Verification is never skipped before merge.

```mermaid
flowchart LR
    I[6a. Implement] --> V[6b. Verify]
    V --> P[6c. Review / PR / merge]
    P -. next round .-> I
```

Inside the Implement stage, work runs in smaller **implementation cycles** (see below).
PR grouping defaults are in the Review / PR subsection.

---

### 6a. Implement

#### Goal
Execute the approved plan.

#### Implementation cycles
The Implement stage runs in small **implementation cycles**.
The human chooses the granularity of each cycle: a phase/slice, a work packet, or a step/substep.

A cycle roughly follows these steps: pick the target, confirm the plan is still accurate **and detailed enough for this target — deepen it if staged planning left this item at a higher level**, execute, review, close the cycle (update statuses, changelog, tests).
Use this as a guide, not a rigid checklist.

Within a cycle the human can:
- ask the AI to implement plan items
- ask the AI for a custom programming task outside the current plan item
- write code themselves and discuss with the AI
- ask for a review at any time

If the plan has to be adapted at any point during implementation, do it explicitly in `delivery-plan.md` before continuing.
Very small changes or extensions don't need a plan update.

```mermaid
flowchart LR
    T[Pick target<br/>phase / packet / step] --> A{Plan accurate<br/>and detailed<br/>enough?}
    A -- yes --> X[Execute<br/>code, tests, QA]
    A -- no --> U[Adapt or<br/>deepen plan]
    U --> X
    X --> C[Close cycle<br/>update statuses,<br/>tests, changelog]
    C -. next cycle .-> T
```

Implementation cycles are nested inside the **implementation round** (Implement → Verify → Review / PR).
See the Concept model.

#### Testing strategy
Testing is part of each cycle, not a separate end step.
For each cycle:
- cover new or changed code primarily with **unit tests**, adding **integration tests** for general cases and cross-component behavior, following the conventions defined for the repo
- when applicable, run real-life tests — the AI should run the code, the application, and full-stack / UI flows whenever possible
- the human should manually test partial results when it makes sense (e.g. UX, or environments the AI cannot reach)

The final, formal checks — requirements validation, code testing guidance, and Dev-QA — happen in the Verify subsection below.

#### Rules
- implement against the current approved plan only
- update status markers live
- keep diffs small enough to reason about
- a work packet is an execution unit, not a PR unit
- a commit is not a planning unit

#### Review model

Default:
- user reviews **within the plan** and in direct discussion with the AI at work-packet/task level
- PR review is used for a **larger integration boundary**:
  - whole phase or the full approved slice or multiple phases / slices
  - in special cases, a work packet or multiple packets

Therefore:
- **work packets are usually reviewed conversationally**
- **internal review often happens below PR level**
- **PRs are usually phase-level / slice-level or scope multiple phases / slices or the whole implementation**

PRs should normally be assigned to another human developer for review, but can alternatively / additionally be reviewed by a reviewing AI agent.

#### If changes are requested during review

Do not edit silently.

Update the plan in `delivery-plan.md` using one of these patterns:

##### Small correction inside same packet
- add a new step/substep under the current work packet
- mark it `[ADDED yyyy-mm-dd]` or `[FIXUP yyyy-mm-dd]`

##### Correction that changes scope/approach
- mark affected packet `[CHANGED yyyy-mm-dd]`
- update remaining steps below it
- update dependencies if needed

##### Correction that deserves isolation
- create a new sibling work packet:
  - `W1a. Review fixups [ADDED yyyy-mm-dd]`

Always log:
- why the correction was needed
- what changed in plan structure
- whether already-completed work remains valid

#### Exit criteria for a work packet
- acceptance criteria met
- plan status updated
- tests updated
- changelog updated

#### Artifacts produced
- `implementation-report.md` Capture, as they surface during implementation, the decisions and operational notes that later stages need: decisions taken, needed migrations, introduced toggles / flags, limitations, and anything Verify / Rollout / Review will rely on that only became clear while building. One per change (appended across cycles), not per phase.
- `logs/phase-<n>.changelog.md` For each implementation phase, record:
    - steps completed
    - code areas changed
    - tests added/updated
    - review feedback received
    - fixups applied
    - commits/branches/PR references if used

- `learning/phase-<n>.learning.md` Record only reusable learnings, e.g.:
  - “For this repo, integration tests should be added before refactor on shared services”
  - “Review quality improved when packet descriptions included touched contracts explicitly”
  - “Parallel work on adjacent modules still conflicted because config wiring was shared”

- `delivery-plan.md` Update statuses in the delivery plan

---

### 6b. Verify

#### Goal
Run an explicit verification gate, separate from coding.
Re-run the Implement stage in case of failed verification.

#### When to scale down
For trivial changes, Verify can collapse into a short paragraph in the phase changelog rather than a separate `verification-report.md`.
The Verify rule still holds: nothing merges without an explicit verification step recorded somewhere.

#### Requirements validation
The AI agent goes through every requirement in `change-brief.md` and verifies:
- each requirement is implemented
- all corner cases are covered
- possible error cases are handled

The outcome is part of the acceptance criteria check.

#### Code testing guidance
Guidance for automated code tests:
- for bugfixes: reproduce first, then add a regression test where possible
- prefer unit tests as the primary coverage
- use integration tests for general cases and cross-component behavior
- add E2E only for critical user journeys or release risk

#### Dev-QA
Beyond automated code tests, explicit QA is part of verification.
Basic / happy case testing and some corner case testing should always happen:
- the AI agent should perform QA whenever possible (by running the code or the application)
- the human developer should always also perform QA manually before sending a PR for review
- the human should always do manual testing of the end solution

The outcome is part of the acceptance criteria check.

#### Exit criteria
- verification passed
- any required replan/fixup is added back into the plan, and the Implement stage is run again

#### Required artifacts
- `verification-report.md` For each completed round / PR boundary:
    - acceptance criteria check, including requirements validation (by AI) and dev-QA (happy-case and corner-case testing, by AI and by human)
    - static analysis / lint / typecheck
    - unit tests
    - integration tests
    - migration checks
    - observability/logging checks
    - security/privacy checks if relevant
    - open issues / residual risks

- append results to `logs/phase-<n>.changelog.md` Append:
    - verification result
    - defects found
    - rework triggered
    - final status

- append reusable lessons to `learning/phase-<n>.learning.md` Record only reusable learnings, e.g.:
    - “Bugfix flow should require regression test before final verification when reproducible”
    - “Shared fixtures created false positives; add rule to isolate integration fixtures”

---

### 6c. Review / PR / integration / merge

#### Goal
Review the change and open PRs only at meaningful integration boundaries.

#### When to skip
For work that is not committed to a shared branch (local experiments, scratch work) or for trunk-direct workflows where the merge boundary is implicit.
The Verify rule still applies before any code is shared with others.

#### Recommended default
- one PR per whole implementation (all phases/slices)
- one PR per phase/slice
- in special cases, one PR per group of completed work packets that forms a coherent, testable delta

#### Avoid
- one PR per tiny packet
- one PR per commit

#### PR should include
- linked phase(s) / packet(s)
- change summary
- test summary
- rollout note
- known limitations
- follow-up packets if any

#### Targeting an integration branch
A PR may target the final branch (e.g. `main` or a release branch) directly, or an **integration branch** that collects several phases / slices before they reach the final branch.

When an integration branch is used, the change finishes with **one more implementation round** — Implement → Verify → Review / PR — that promotes the integration branch to its final target:
- **Implement** — apply any final code improvements, then merge or rebase the integration branch onto the target branch and resolve any merge conflicts.
- **Verify** — run verification across the **whole** integrated scope, not just the latest slice.
- **Review / PR** — a final PR that reviews the change as a whole before it merges into the final branch.

This final round follows the same Verify-before-merge rule as every other round.

#### If PR review requests changes
- changes must be reflected back into `delivery-plan.md`
- mark affected items `[FIXUP]` / `[CHANGED]` / `[ADDED]`
- append rationale to the phase changelog

---

## 7. Release / rollout (optional)

### When to skip
For changes with no operational impact — internal refactors, doc-only changes, or work behind a flag that does not yet ship.
Skip whenever there is nothing to migrate, toggle, document for users, or roll back.

### Exit criteria
- relevant migrations are documented
- list of basic manual test scenarios to be run is generated
- release notes are logged

### Artifacts produced
- `rollout-note.md` Include:
    - introduced toggles, properties
    - log categories added/removed
    - porting instructions if necessary (for patches)
    - necessary migrations
    - rollback path
    - user-visible docs changes if needed or any other information that needs to be documented

- `logs/stage-7-rollout.changelog.md` Record
    - additions/changes to the rollout note

- `learning/stage-7-rollout.learning.md` Record only reusable learnings, e.g.:
    - “Cross-service changes require rollout notes even for internal features”
    - “Always document rollback for schema-affecting changes”


---

## 8. Learn / improve the system (optional)

### Goal
Promote generalized learnings into durable system guidance.
Each bucket is applied per its autonomy setting (see Buckets); under `review` the user approves the diff before it is merged.

### When to skip
When no phase produced a learning file worth promoting (small or routine changes).
Skipping Learn does **not** delete the per-phase learning files; they remain available for a later rollup.

### Inputs
- all `learning/phase-*.learning.md` files
- `architecture-notes.md` if the Architecture stage ran — its durable design decisions and rationale are reviewed here and promotable ones go into the knowledge layer (decisions / ADRs) via the curator's `from-learning` mode

### Promotion targets
- `AGENTS.md`
- skill / subagent extensions
- rule extensions / conventions docs
- reusable prompts
- checklists
- test templates
- architecture guidance
- knowledge files

### Promotion rules
- keep only recurring, reusable guidance
- reject one-off case details
- prefer rule changes only when the signal is strong
- every promoted learning should be phrased as a reusable instruction or heuristic

### Output
- `learning-rollup.md` Merge and deduplicate, filter only high-value general learnings.

#### Buckets
- **AGENTS updates** — a snippet to merge into the host repo's `AGENTS.md`.
- **README updates.**
- **rule / skill / subagent extensions** — new or revised `mx-`-prefixed assets under `.marshail/extensions/{rules,skills,agents}/`.
  Coding-standard, test-strategy, repo-navigation, and review/plan conventions land here as rules or skills.
- **knowledge updates** — durable repo facts (logic, architecture, decisions / ADRs) dropped into `.marshail/knowledge/learn/inbox/` and promoted into canonical knowledge by [`marshail-knowledge-curator`](agents/marshail-knowledge-curator.md) mode `from-learning`.
- **reusable prompts / checklists / test templates / architecture guidance** — filed under the matching bucket above, or under knowledge when that fits better.

The non-knowledge buckets are applied per `extensions.autonomy` (default `review`); the knowledge bucket is applied per `knowledge.autonomy`.
See [`marshail-learner`](agents/marshail-learner.md) for the bucketing workflow.

---

## Skills and subagents

MARSHAIL ships a set of `marshail-*` **subagents** under [`.marshail/agents/`](agents/) — they own the workflow logic — and a matching set of `marshail-*` **skills** under [`.marshail/skills/`](skills/) and [`.marshail/skills-fallback/`](skills-fallback/) that match user intent and dispatch the work.
The agent file is the single source of truth for each stage / role; skills are thin wrappers and do not duplicate the workflow content.

Two flavors of stage skill ship for every stage:

- `marshail-delegate-to-<x>` (under `.marshail/skills/`) — for environments **with** subagent support.
  High-recall trigger phrases; delegates to the matching subagent in fresh context.
- `marshail-<x>` (under `.marshail/skills-fallback/`) — for environments **without** subagent support.
  Same name as the full-bodied skills they replace.
  Instructs the assistant to follow the agent's source-of-truth file inline in the current session.

Each delegated agent works **independently** and keeps its internals out of the caller's context — it returns only what the caller needs (a summary or an artifact path), not its full working detail.
This avoids context pollution and keeps long runs cheap.

Stage skills:

| Stage | Subagent | Delegate skill | Fallback skill | Artifact | Optional? |
|---|---|---|---|---|---|
| 1. Specification | [`marshail-specifier`](agents/marshail-specifier.md) | [`marshail-delegate-to-specify`](skills/marshail-delegate-to-specify/SKILL.md) | [`marshail-specify`](skills-fallback/marshail-specify/SKILL.md) | `specification.md` | optional |
| 2. Intake | [`marshail-framer`](agents/marshail-framer.md) | [`marshail-delegate-to-intake`](skills/marshail-delegate-to-intake/SKILL.md) | [`marshail-intake`](skills-fallback/marshail-intake/SKILL.md) | `change-brief.md` | optional |
| 3. Analysis | [`marshail-code-archaeologist`](agents/marshail-code-archaeologist.md) | [`marshail-delegate-to-analysis`](skills/marshail-delegate-to-analysis/SKILL.md) | [`marshail-analysis`](skills-fallback/marshail-analysis/SKILL.md) | `repo-recon.md` | optional |
| 4. Architecture | [`marshail-architect`](agents/marshail-architect.md) | [`marshail-delegate-to-architecture`](skills/marshail-delegate-to-architecture/SKILL.md) | [`marshail-architecture`](skills-fallback/marshail-architecture/SKILL.md) | `architecture-notes.md` | optional |
| 5. Plan | [`marshail-planner`](agents/marshail-planner.md) | [`marshail-delegate-to-plan`](skills/marshail-delegate-to-plan/SKILL.md) | [`marshail-plan`](skills-fallback/marshail-plan/SKILL.md) | `delivery-plan.md` | **mandatory** |
| 6a. Implement | [`marshail-implementer`](agents/marshail-implementer.md) | [`marshail-delegate-to-implement`](skills/marshail-delegate-to-implement/SKILL.md) | [`marshail-implement`](skills-fallback/marshail-implement/SKILL.md) | code + phase logs | mandatory when there is code to write |
| 6b. Verify | [`marshail-verifier`](agents/marshail-verifier.md) | [`marshail-delegate-to-verify`](skills/marshail-delegate-to-verify/SKILL.md) | [`marshail-verify`](skills-fallback/marshail-verify/SKILL.md) | `verification-report.md` | mandatory before any PR; may be folded into the changelog for trivial changes |
| 6c. Review / PR | [`marshail-reviewer`](agents/marshail-reviewer.md) | [`marshail-delegate-to-pr`](skills/marshail-delegate-to-pr/SKILL.md) | [`marshail-pr`](skills-fallback/marshail-pr/SKILL.md) | PR description | optional (skip for non-shared work) |
| 7. Rollout | [`marshail-releaser`](agents/marshail-releaser.md) | [`marshail-delegate-to-rollout`](skills/marshail-delegate-to-rollout/SKILL.md) | [`marshail-rollout`](skills-fallback/marshail-rollout/SKILL.md) | `rollout-note.md` | optional |
| 8. Learn | [`marshail-learner`](agents/marshail-learner.md) | [`marshail-delegate-to-learn`](skills/marshail-delegate-to-learn/SKILL.md) | [`marshail-learn`](skills-fallback/marshail-learn/SKILL.md) | `learning-rollup.md` | optional |

Setup / main-session skills (no subagent counterpart — these are intentionally main-session intent):
- [`marshail-init`](skills/marshail-init/SKILL.md) — first-time MARSHAIL setup in a repo: scaffolds `.marshail/`, optionally installs [cyncia](https://github.com/crestreach/cyncia) (via the cyncia installer), provisions an `.agent-config/` source tree, runs [`marshail-promote-assets`](skills/marshail-promote-assets/SKILL.md) to wire MARSHAIL durable assets into it, and (optionally) runs the sync to fan everything out into tool-native layouts.
- [`marshail-load`](skills/marshail-load/SKILL.md) — session bootstrap.
- [`marshail-promote-assets`](skills/marshail-promote-assets/SKILL.md) — copy MARSHAIL durable assets from `.marshail/{skills,skills-fallback,agents,rules}/` (built-ins; keep their `marshail-` prefix) **and** from `.marshail/extensions/{skills,agents,rules}/` (repo-specific extensions; keep their `mx-` prefix) into the repo's config-sync source tree (default `.agent-config/`), so the next `agent-conf-sync` run fans them out to all tool layouts.
  Names are copied as-is — no reprefixing.

Help / orchestration:
- [`marshail-helper`](agents/marshail-helper.md) — on-demand MARSHAIL coach: answers procedural and conceptual questions, orients the caller in the current change, and hands off to the right stage agent or to [`marshail-driver`](agents/marshail-driver.md).
  Wrappers: [`marshail-delegate-to-help`](skills/marshail-delegate-to-help/SKILL.md) (delegate) / [`marshail-help`](skills-fallback/marshail-help/SKILL.md) (fallback).
- [`marshail-driver`](agents/marshail-driver.md) — full end-to-end process orchestrator across stages.
  Wrapper: [`marshail-delegate-to-driver`](skills/marshail-delegate-to-driver/SKILL.md).
  No fallback (its value is subagent orchestration with isolated per-stage context).

Knowledge agent and skills (see Knowledge):
- [`marshail-knowledge-curator`](agents/marshail-knowledge-curator.md) — owns all knowledge maintenance modes (`init`, `from-changes`, `from-learning`, `rescan`, `rebuild`, `branch-merge`).
  Wrappers, by mode:
  - `init` → [`marshail-delegate-to-knowledge-init`](skills/marshail-delegate-to-knowledge-init/SKILL.md) / [`marshail-knowledge-init`](skills-fallback/marshail-knowledge-init/SKILL.md)
  - `from-changes` / `from-learning` / `rescan` → [`marshail-delegate-to-knowledge-maintain`](skills/marshail-delegate-to-knowledge-maintain/SKILL.md) / [`marshail-knowledge-maintain`](skills-fallback/marshail-knowledge-maintain/SKILL.md)
  - `rebuild` → [`marshail-delegate-to-knowledge-rebuild`](skills/marshail-delegate-to-knowledge-rebuild/SKILL.md) / [`marshail-knowledge-rebuild`](skills-fallback/marshail-knowledge-rebuild/SKILL.md)
  - `branch-merge` → [`marshail-delegate-to-knowledge-branch-merge`](skills/marshail-delegate-to-knowledge-branch-merge/SKILL.md) / [`marshail-knowledge-branch-merge`](skills-fallback/marshail-knowledge-branch-merge/SKILL.md)
- [`marshail-researcher`](agents/marshail-researcher.md) — read-only research returning a condensed source-linked delta.
  Wrappers: [`marshail-delegate-to-knowledge-research`](skills/marshail-delegate-to-knowledge-research/SKILL.md) / [`marshail-knowledge-research`](skills-fallback/marshail-knowledge-research/SKILL.md).

Every agent file states its own prerequisites, inputs, outputs, and handoff (next agent + artifacts to pass) so it is safe to run in an isolated context.
Each agent also declares a **load tier** (minimal / standard / full) and follows the shared [`references/activation-protocol.md`](references/activation-protocol.md), which defines what every agent reads on activation and the resume contract.
The knowledge write discipline and mid-process knowledge-capture rules every agent follows are defined above (§ Knowledge) and in [`ENTRYPOINT.md`](ENTRYPOINT.md).
Every agent hands its result back to the orchestrator ([`marshail-driver`](agents/marshail-driver.md)) — or to the user, when the agent was invoked directly; the driver (or the user) decides what runs next.

---

## Communication models

There are two supported ways to drive MARSHAIL; the choice is the user's and the two can be mixed across a change:

1. **Direct.**
   The user calls a specialist agent (or its `marshail-delegate-to-*` skill) directly for a single stage.
   The specialist answers the user directly and still writes its artifact into the working folder, so the driver can pick the change up later.
   Best when the user knows the process and wants one focused step.
2. **Driver-mediated (single point of contact).**
   The user talks only to [`marshail-driver`](agents/marshail-driver.md), which coordinates the specialists, keeps the user oriented, and relays questions and answers.
   Best when the user wants one point of contact and does not want to track the process.

**How much the user is involved.**
In the driver-mediated model the level of interaction is not fixed: it ranges from *hands-off* (the driver runs end-to-end and returns only for important decisions or approval gates) to *collaborative* (driver and user shape the specification, plan, and key choices together, phase by phase).
The driver infers the level from the prompt and the autonomy setting in [`config.yml`](config.yml), asks once when genuinely ambiguous, and the level may differ per phase and be changed at any stage boundary.

**Tradeoff.**
Agent dispatch is turn-based — there is no portable held-open live subagent session — so the driver mediates by *re-dispatching* the relevant agent with the accumulated context each turn.
State is carried on disk through the artifact chain and the working folder's resume notes, not in an in-memory conversation.
This is robust (any session can resume from `.marshail/work/<change-id>/`) but can be lossy at the margins: nuance from a long back-and-forth that was never written down is not automatically available to the next dispatch.
To keep mediation faithful, agents **log everything important** (decisions, open questions, rejected options) into their artifact and resume notes.
When a tight live back-and-forth with one specialist is needed, prefer the direct model for that stretch and let the driver resume afterwards.

---

## Knowledge

MARSHAIL is paired with an agent-managed knowledge layer kept under [`.marshail/knowledge/`](knowledge/).
Knowledge complements the per-change artifact chain: the artifact chain captures *this* change, while knowledge captures durable facts about the repo (architecture, logic, conventions, decisions) that survive across changes.

Key points:

- **Two trees.**
  The `.marshail/` config-sync source ships `marshail-*` agents / skills / rules and is fanned out to tool layouts.
  The `.marshail/knowledge/` tree is **excluded from that fan-out** — it is read in place, starting from [`.marshail/ENTRYPOINT.md`](ENTRYPOINT.md).
- **Exchangeable representation.**
  [`.marshail/config.yml`](config.yml) names the general `knowledge.contract_ref` and the active `knowledge.representation_ref`.
  The contract lives at [`references/knowledge-contract.md`](references/knowledge-contract.md).
  The default implementation is **MARSHAIL Markdown Spine**, defined in [`references/knowledge-markdown-spine.md`](references/knowledge-markdown-spine.md).
  Agents follow the configured implementation instead of hard-coding a layout.
- **Hierarchical and progressively disclosed.**
  Knowledge is a recursive tree: an always-loaded root index, then deeper indexes and topic files pulled in only as a task needs them, with no fixed depth.
  How knowledge is grouped at each level (the split dimension) is chosen for what helps agents most and may be revised over time.
  The exact layout, metadata, size caps, and split / merge mechanics are defined by the active implementation — see [`references/knowledge-markdown-spine.md`](references/knowledge-markdown-spine.md).
- **Staleness without hooks.**
  Each file records when, and against which commit, it was last verified; the maintenance step compares that against HEAD on demand (no git hooks).
  The active implementation defines the exact markers.
- **Approval.**
  [`.marshail/config.yml`](config.yml) controls autonomy (`auto` default; `review` opt-in).
  Under `auto`, knowledge writes are applied without per-change approval and a summary of what changed is returned; under `review` every write produces a full diff for human approval first.
- **Where it plugs into the lifecycle.**
  Stage 3 (Analysis) consults knowledge first to narrow the search surface and may invoke `marshail-researcher`.
  After each implementation cycle, `marshail-knowledge-curator` mode `from-changes` keeps knowledge in sync.
  Stage 8 (Learn) feeds promotable items into knowledge via mode `from-learning`.
  Larger reconciliation is handled by modes `branch-merge` and `rebuild`.

Full contract and design rationale: [`references/knowledge-contract.md`](references/knowledge-contract.md); the default implementation: [`references/knowledge-markdown-spine.md`](references/knowledge-markdown-spine.md).
A worked example tree lives under [`examples/snippets-api/`](../examples/snippets-api/).

### Knowledge write discipline

Every agent that writes knowledge follows the same rule:

- Honor [`.marshail/config.yml`](config.yml) `knowledge.autonomy`:
  - `auto` (default): write without per-change approval and return a summary of what changed.
  - `review`: produce a diff and wait for the human's approval before applying; group related edits into one diff.
- Never silently rewrite knowledge mid-task — either apply under `auto`, propose a diff under `review`, or drop a note into `knowledge/learn/inbox/` for later promotion.
- Follow the active knowledge implementation for which metadata to refresh and how to regenerate indexes after a write.

### Mid-process knowledge capture

Some agents (e.g. [`marshail-code-archaeologist`](agents/marshail-code-archaeologist.md), [`marshail-researcher`](agents/marshail-researcher.md), and occasionally any stage agent) discover durable, reusable knowledge while doing their work.
Two [`.marshail/config.yml`](config.yml) settings govern what they do with it, and **every** agent that wants to augment knowledge follows the same rule:

- `knowledge.capture_during_process`:
  - **true** (default): write a knowledge-shaped note into `knowledge/learn/inbox/` (the archaeologist also attaches its stale-knowledge pointer list) so later stages can reuse it instead of rediscovering it.
  - **false**: do **not** touch the knowledge inbox mid-process; record the finding in the current stage's learning file (`learning/stage-<n>-<name>.learning.md`, or `learning/phase-<n>.learning.md` during implementation) instead, to be promoted only in the Learn stage.
- `knowledge.curator_invocation` (only relevant when a note was written to the inbox):
  - **agent**: the agent calls [`marshail-knowledge-curator`](agents/marshail-knowledge-curator.md) itself right after writing the note.
  - **driver** (default): the agent does **not** call the curator; it reports back to its caller (the driver, or the user when invoked directly) that it populated the inbox, and the caller runs the curator.

Agents never edit canonical knowledge directly — promotion always goes through the curator.

---

## Generated assets and config sync

MARSHAIL produces two kinds of content:

1. **Per-change artifacts** — specification, brief, recon, plan, logs, learnings, etc. They live in the per-change working folder `.marshail/work/<change-id>/` (transient, gitignored; archived to `.marshail/archive/<change-id>/` on finalize).
   See [Where the artifact chain lives](#where-the-artifact-chain-lives).
2. **Durable assets** — skills, subagents, rules, and guidelines that codify reusable behavior.
   They live under [`.marshail/`](./) and are versioned with the repo.

> **Naming note.** In a consumer repo, the durable-assets directory is `.marshail/`. In this product repo (the MARSHAIL source) the same tree lives under [`marshail-files/`](./) so it is not confused with a real installed `.marshail/` instance. Documentation refers to it as `.marshail/` because that is what consumers see; the link targets in this document point at `marshail-files/` for in-repo navigation.

### Where durable assets live

| Folder | What it holds |
|---|---|
| [`.marshail/skills/`](skills/) | One folder per skill (Agent Skills format), each containing a `SKILL.md`. Built-in MARSHAIL skills (`marshail-*`). |
| [`.marshail/skills-fallback/`](skills-fallback/) | Inline (no-subagent) variants of the lifecycle skills, same names as the originals. Built-in MARSHAIL. |
| [`.marshail/agents/`](agents/) | One file per subagent definition. Built-in MARSHAIL subagents (`marshail-*`). |
| [`.marshail/rules/`](rules/) | One file per rule. Generic rule frontmatter (`description`, `applies-to`, `always-apply`). Built-in MARSHAIL rules. |
| [`.marshail/extensions/{skills,agents,rules}/`](extensions/) | **Repo-specific extensions** — rules / skills / subagents drafted by [`marshail-learner`](agents/marshail-learner.md) (or hand-authored) on top of the built-ins. Every basename is `mx-`-prefixed at creation. Survives MARSHAIL upgrades. |
| [`.marshail/knowledge/`](knowledge/) | Repo knowledge — **not synced**, read in-place via `.marshail/ENTRYPOINT.md`. |
| [`.marshail/AGENTS.md`](AGENTS.md) | Snippet meant to be **manually merged** into the host repo's root `AGENTS.md` so that AI assistants see the MARSHAIL entry point. |
| [`.marshail/marshail-override.md`](marshail-override.md) | **Optional** repo-specific override file. Free-form Markdown that specifies or modifies how MARSHAIL behaves on top of `marshail.md` (stage policy, artifact policy, agent/skill preferences). Read by every MARSHAIL-aware agent immediately after `marshail.md`; entries here take precedence on the points they address. Empty by default. **Not synced.** |
| [`.marshail/agent-tools.yml`](agent-tools.yml) | **Optional** per-agent tool (MCP) grants. Maps a built-in (`marshail-<name>`) or extension (`mx-<name>`) agent to extra tools that `marshail-promote-assets` merges (union) into that agent's declared tools at promotion. Survives MARSHAIL updates (installers add new keys, never overwrite existing ones). Empty by default. |

### How they get generated

MARSHAIL agents may create or update any of these assets in two situations:

- **From learnings.**
  During the Learn stage, recurring lessons in `learning-rollup.md` can be promoted into a new or updated skill, subagent, rule, or guideline.
  Newly drafted executable assets land under [`.marshail/extensions/{skills,agents,rules}/`](extensions/) with the `mx-` prefix at creation; the built-in `.marshail/{skills,skills-fallback,agents,rules}/` folders are owned by MARSHAIL itself and are not edited from learnings.
- **On request.**
  The user can ask the agent at any time to produce a skill / subagent / rule / guideline for a recurring task.
  The agent drafts it under [`.marshail/extensions/`](extensions/) (with the `mx-` prefix).

Both paths are governed by `extensions.autonomy` in [`.marshail/config.yml`](config.yml): under `review` (default) the agent surfaces a diff for approval before applying; under `auto` it applies the change and returns a summary.
This is the gate for extension / guidance assets (rules, skills, subagents, `AGENTS.md` / `README` updates) — distinct from `knowledge.autonomy`, which governs knowledge writes.

Generated rules use the generic frontmatter understood by the sync tool (see below): `description`, `applies-to` (comma-separated globs), `always-apply` (boolean).

### Syncing into native AI-assistant layouts

The `.marshail/skills/`, `.marshail/agents/`, and `.marshail/rules/` folders follow the layout consumed by [cyncia](https://github.com/crestreach/cyncia).
Running that tool's `sync-all` script over a source tree containing those folders produces tool-native files for each AI assistant cyncia is configured to target. That target set is **cyncia's to define, not MARSHAIL's** — MARSHAIL deliberately does not enumerate it here so it never goes stale when cyncia adds or drops a tool; see `.cyncia/cyncia.conf` (`default-tools`) for the active list.

Two layouts are supported:

- **Direct.**
  Point `sync-all -i` at `.marshail/` itself.
  Simplest setup; only works when MARSHAIL's durable assets are the only ones the repo wants synced.
- **Separate `.agent-config/` source tree.**
  The repo keeps its own `.agent-config/` (or similarly named) source folder at the root, alongside `.marshail/`.
  MARSHAIL's durable assets are *promoted* into it via the [`marshail-promote-assets`](skills/marshail-promote-assets/SKILL.md) skill, which walks **two** source trees inside `.marshail/`:
  - **built-ins** — `.marshail/{skills,skills-fallback,agents,rules}/` (`marshail-` prefix).
    Promoted into `<config-sync>/{skills,agents,rules}/` **as-is**, keeping the `marshail-` prefix.
  - **extensions** — `.marshail/extensions/{skills,agents,rules}/` (`mx-`-prefixed at creation).
    Copied into `<config-sync>/{skills,agents,rules}/` **as-is**, keeping the `mx-` prefix.

  The sync runs over the config-sync source tree (default `.agent-config/`, overridable via `sync.agent_config_dir`).

Naming convention:

- Built-in MARSHAIL assets (lifecycle skills, MARSHAIL subagents) use the `marshail-` prefix and keep it everywhere — in `.marshail/` and after promotion.
- Repo-specific extensions under `.marshail/extensions/` use the `mx-` prefix at creation and keep it everywhere.
- Promotion never renames or reprefixes; names are copied through unchanged.

Guidelines flow:

- The sync tool requires an `AGENTS.md` in its source root.
  With the **direct** layout, that role is played by [`.marshail/AGENTS.md`](AGENTS.md).
  With the **separate** layout, the repo's `.agent-config/AGENTS.md` is authoritative and `.marshail/AGENTS.md` becomes a snippet to be **manually merged** into it so the MARSHAIL entry point fans out alongside the rest.
- Rules under `.marshail/rules/` (or `.agent-config/rules/`) translate into each target assistant's native rule format, as documented by the sync tool.

This split keeps the canonical source of truth in `.marshail/` and lets every IDE/assistant pick it up in its own native format.

---

## Recommended skills / contexts

This was the original sketch of skills; it has been superseded by the concrete `marshail-*` skill set listed in [Skills and subagents](#skills-and-subagents) above.
The mapping is:

| Original sketch | Current |
|---|---|
| Change Framer | `marshail-specify` + `marshail-intake` |
| Repo Recon | `marshail-analysis` |
| Planner / Shaper | `marshail-plan` |
| Executor | `marshail-implement` |
| Verifier / Reviewer | `marshail-verify` + `marshail-reviewer` (subagent) |
| Learning Curator | `marshail-learn` + `marshail-knowledge-maintain` |

---
