---
applyTo: "**"
---


# General rules

- **Keep everything in sync.**
  Whenever you change any part of the project — an agent, a skill, a
  rule, the configuration, the canonical spec, a reference, or an
  example — update every other place that depends on it in the same
  change.
  That includes connected agents and skills, `marshal.md`,
  `ENTRYPOINT.md`, the references, the examples under `examples/`, and
  any knowledge stubs.
  Documentation, agents, skills, and examples must not drift out of
  step with each other.
- **Prefer names over numbers** when referring to MARSHAL stages in
  agents, skills, and docs, so renumbering a stage does not force edits
  across many files.
  The canonical numbered ordering lives in `marshal.md`.
- **Share only what is needed across agent boundaries.**
  A delegated agent works independently and must not pollute the
  caller's context with its internals — it returns only the result the
  caller needs (a summary, an artifact path), not its full working
  detail.
