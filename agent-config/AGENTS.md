# AGENTS.md

Guidance for AI agents working in the MARSHAL repository.

This repo defines **MARSHAL** — a process for AI-assisted software delivery. The canonical spec lives in [`marshal.md`](./marshal.md); the project overview is in [`README.md`](./README.md).
Agents should read [`marshal.md`](./marshal.md) at the beginning of each session, unless it's clearly isolated work that the agents is doing or the agent's definition says it should work in an isolated, clear context.

## Scope

Most work here is editing the process spec and adding supporting tooling (skills, prompts, templates, examples). The process itself is still being shaped, so this file is intentionally minimal and will grow as conventions stabilize.

## General guidelines

- Do exactly and only what the user asks. Do not add anything that wasn't requested.
- If something seems worth extending or adding, ask first and discuss before changing the file.
- Favor simple, understandable descriptions. Extra cases are fine when they add flexibility, but don't turn them into heavy sub-processes.
- Do not make assumptions. If anything is vague, unclear, or you disagree with it, ask questions and raise concerns before proceeding.
- Large or risky changes: summarize the plan in a few bullets, then implement — reduces wrong-direction work

## Working rules

- Treat [`marshal.md`](./marshal.md) as the single source of truth for the method. Any method change lands there first, then propagates to `README.md` and this file.
- Keep the MARSHAL acronym intact.
- Don't duplicate process detail here or in `README.md` — link to `marshal.md` instead.
- Don't dupllicate individual specifications in `marshal.md` if they have their own files that are source of truth, link them instead
- Don't commit unless explicitly asked.
- Always keep README.md and marshal updated, but avoid updating while work is still in progress, update only when the topic is finished and approved
- Whenever we do a change in the process, or models, always update all related documents, Marshal skills, agents and scripts.
- Match existing style in the touched files (naming, imports, formatting) before introducing new patterns.
- Run the checks the task implies (tests, linter, typecheck, formatter) when the project has them; if a command fails, fix or report before declaring done.
- One retry path, then escalate: try a reasonable alternative once; if still blocked, summarize evidence (error output, file/line) and ask for a decision instead of thrashing.

## Git

- Do not commit or push unless the user explicitly asks you to (e.g. “commit”, “push”, “commit and push”). Staging is fine only if they asked for it; default is to leave git commit / git push to them unless instructed otherwise.
- Prefer small, focused commits with clear messages when you do commit.
- Do not rewrite published history (force-push, rebase onto public main) unless the user explicitly requests it.
- Never commit secrets (tokens, keys, .env with real values). If something looks sensitive, redact and tell the user instead of pasting it into chat or files.

## Tools and environment

- Use the workspace as source of truth (read files, run commands) instead of guessing paths or versions.
- Note OS/shell assumptions when relevant (e.g. macOS paths, zsh), especially for scripts or one-off commands.
