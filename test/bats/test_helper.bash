# Bats helper — loaded by each .bats file in this directory.
# shellcheck shell=bash

# Repo root: test/bats -> test -> repository root
test_helper::repo_root() {
  echo "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
}

export REPO_ROOT
REPO_ROOT="$(test_helper::repo_root)"
export REPO_ROOT

INSTALL_SH="${REPO_ROOT}/scripts/install-marshal.sh"
export INSTALL_SH

# Install a fake `curl` (and `wget`) first on PATH so the installer never
# reaches the network. The fake dispatches by URL (assumed to be the last arg):
#   *.tar.gz archive URLs   -> cat back $FAKE_TARBALL
#   GitHub API /commits/<r> -> cat back $FAKE_COMMIT_JSON (or exit 22 if unset)
#   GitHub API /tags        -> cat back $FAKE_TAGS_JSON   (or exit 22 if unset)
#   the cyncia installer    -> emit a tiny no-op script (consumed by `| sh`)
#   anything else           -> exit 22
# Every requested URL is also appended to $CURL_LOG when that var is set, so a
# test can assert exactly which URLs the installer fetched.
test_helper::install_fake_fetchers() {
  FAKE_BIN="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/marshal_fake_bin.XXXXXX")"
  cat > "$FAKE_BIN/curl" <<'EOF'
#!/usr/bin/env bash
url=""
for arg in "$@"; do url="$arg"; done
[ -n "${CURL_LOG:-}" ] && printf '%s\n' "$url" >> "$CURL_LOG"
case "$url" in
  *.tar.gz)
    [ -n "${FAKE_TARBALL:-}" ] && [ -f "$FAKE_TARBALL" ] || { echo "fake curl: no FAKE_TARBALL" >&2; exit 22; }
    exec cat "$FAKE_TARBALL" ;;
  *api.github.com/repos/*/commits/*)
    if [ -n "${FAKE_COMMIT_JSON:-}" ] && [ -f "$FAKE_COMMIT_JSON" ]; then exec cat "$FAKE_COMMIT_JSON"; fi
    exit 22 ;;
  *api.github.com/repos/*/tags*)
    if [ -n "${FAKE_TAGS_JSON:-}" ] && [ -f "$FAKE_TAGS_JSON" ]; then exec cat "$FAKE_TAGS_JSON"; fi
    exit 22 ;;
  *cyncia*install.sh*)
    printf '%s\n' '#!/bin/sh' 'echo FAKE-CYNCIA-INSTALLER-RAN' ;;
  *)
    echo "fake curl: unhandled URL: $url" >&2
    exit 22 ;;
esac
EOF
  # wget mirrors curl's tarball behavior (-qO- streams the body to stdout).
  cat > "$FAKE_BIN/wget" <<'EOF'
#!/usr/bin/env bash
url=""
for arg in "$@"; do url="$arg"; done
[ -n "${CURL_LOG:-}" ] && printf '%s\n' "$url" >> "$CURL_LOG"
case "$url" in
  *.tar.gz)
    [ -n "${FAKE_TARBALL:-}" ] && [ -f "$FAKE_TARBALL" ] || { echo "fake wget: no FAKE_TARBALL" >&2; exit 22; }
    exec cat "$FAKE_TARBALL" ;;
  *) echo "fake wget: unhandled URL: $url" >&2; exit 22 ;;
esac
EOF
  chmod +x "$FAKE_BIN/curl" "$FAKE_BIN/wget"
  export PATH="$FAKE_BIN:$PATH"
  unset FAKE_COMMIT_JSON FAKE_TAGS_JSON
}

# Build a tarball whose single top-level directory is "$1" (mimicking the
# GitHub archive layout "<repo>-<ref>"), containing a synthetic but
# representative marshal-files/ subtree. The real config.yml is copied in so
# config reconcile tests run against the shipped schema.
# Args: <prefix> <out_tarball_path> [marker]
test_helper::make_marshal_tarball() {
  local prefix="$1" out="$2" marker="${3:-M1}"
  local stage mf
  stage="$(mktemp -d "${TAR_SRC}/stage.XXXXXX")"
  mf="$stage/$prefix/marshal-files"
  mkdir -p \
    "$mf/skills/marshal-sample" \
    "$mf/skills-fallback/marshal-sample" \
    "$mf/agents" \
    "$mf/rules" \
    "$mf/extensions" \
    "$mf/references"
  cp "${REPO_ROOT}/marshal-files/config.yml" "$mf/config.yml"
  printf '# MARSHAL override (%s)\n' "$marker"            > "$mf/marshal-override.md"
  printf '# MARSHAL Entry Point (%s)\n' "$marker"         > "$mf/ENTRYPOINT.md"
  printf '# AGENTS snippet (%s)\n' "$marker"              > "$mf/AGENTS.md"
  printf 'name: marshal-sample\n# (%s)\n' "$marker"       > "$mf/skills/marshal-sample/SKILL.md"
  printf 'name: marshal-sample\n# (%s)\n' "$marker"       > "$mf/skills-fallback/marshal-sample/SKILL.md"
  printf '# marshal-planner (%s)\n' "$marker"             > "$mf/agents/marshal-planner.md"
  printf '# rules readme (%s)\n' "$marker"                > "$mf/rules/README.md"
  printf '# extensions readme (%s)\n' "$marker"           > "$mf/extensions/README.md"
  printf '# activation protocol (%s)\n' "$marker"         > "$mf/references/activation-protocol.md"
  # marshal.md ships *inside* marshal-files/ (part of the subtree); LICENSE
  # lives at the snapshot *root* (outside marshal-files/). Mirrors the real
  # repo: the installer copies marshal.md with the subtree and sources LICENSE
  # from the root, landing both inside <marshal-dir>.
  printf '# MARSHAL — Process Documentation (%s)\n' "$marker" > "$mf/marshal.md"
  printf 'MIT License (%s)\n' "$marker"                       > "$stage/$prefix/LICENSE"
  ( cd "$stage" && tar -czf "$out" "$prefix" )
  rm -rf "$stage"
}
