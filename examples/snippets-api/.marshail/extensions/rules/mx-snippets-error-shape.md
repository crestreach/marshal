---
description: How errors must be modelled and returned in snippets-api.
applies-to: "src/**/*.ts"
always-apply: false
---

# Snippets error shape

Repo-specific rule promoted by `marshail-learner` during the Learn stage, after the pattern recurred across two changes.
It is `mx-`-prefixed because it is a repo extension, not a built-in MARSHAIL rule.

- The service layer returns `Result<T, SnippetError>`-style discriminated unions for **expected** errors; it does not throw for them.
- Only **unexpected** errors throw; the top-level Express error handler maps them to `500` with a generic body.
- Every HTTP error body is `{ error: { code: string, message: string } }` — never a bare string and never the raw exception.
- New endpoints must add an explicit `code` for each expected failure and cover it with a test.
