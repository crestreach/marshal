# Tests

Bash tests for the MARSHAIL tooling, isolated to `test/`.

## Prerequisites

- [bats-core](https://github.com/bats-core/bats-core)
  - macOS: `brew install bats-core`

## Run

From the **repository root**:

```bash
./test/run-bats.sh
```

## What is covered

- **`scripts/install-marshail.sh`** (`test/bats/10_install.bats`,
  `test/bats/20_install_config.bats`, `test/bats/30_install_version.bats`):
  - Help / unknown-argument handling.
  - Tarball fetch of the MARSHAIL snapshot (mirrors how cyncia's own installer
    fetches files): the GitHub archive URL is used, `--repo` accepts both an
    `owner/name` slug and a full GitHub URL, the v-stripped tag top-level
    directory is handled, and the install succeeds with **no git** on PATH.
  - The `marshail-files/` subtree is copied into `.marshail/` (custom
    `--marshail-dir` honored); a missing `marshail-files/` is a hard error.
  - Idempotent re-install preserves user state: `marshail-override.md` is never
    clobbered and the agent-managed `knowledge/` and `work/` trees are left
    untouched.
  - cyncia is installed from the correct `install/install.sh` URL when missing,
    and skipped under `--no-cyncia`.
  - `config.yml` reconcile: created from the template on a fresh install,
    existing values preserved on re-install, newly introduced schema properties
    added (no-TTY default yes), and unknown properties kept by default (no-TTY
    default no).
  - `.marshail/VERSION` (mirrors cyncia's VERSION semantics): a non-main ref is
    written verbatim, a `main` install lists tag(s) pointing at `HEAD`, any
    GitHub API failure falls back to `main`, and the file is refreshed on
    re-run when the ref changes. The API calls are stubbed via the fake `curl`
    using `FAKE_COMMIT_JSON` / `FAKE_TAGS_JSON`.

The tests never touch the network: a fake `curl`/`wget` placed first on `PATH`
emits a tarball assembled from a synthetic `marshail-files/` fixture built in
`test/bats/test_helper.bash`. All writes go into per-test temp directories
under `$BATS_TEST_TMPDIR`.
