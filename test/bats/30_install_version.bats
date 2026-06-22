#!/usr/bin/env bats
# Tests for scripts/install-marshail.sh — the <marshail-dir>/VERSION file.
#
# Semantics mirror cyncia's installer VERSION handling:
#   * a non-main ref (branch or tag) is written verbatim,
#   * for ref "main", best-effort GitHub API lookup lists tag(s) at HEAD,
#   * any API failure (unreachable / no matching tags) falls back to "main",
#   * the file is refreshed on re-run when the ref changes.

load 'test_helper'

setup() {
  TEST_HOME="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/marshail_version.XXXXXX")"
  TAR_SRC="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/marshail_version_tar.XXXXXX")"
  test_helper::install_fake_fetchers
}

teardown() {
  [[ -n "${TEST_HOME:-}" && -d "$TEST_HOME" ]] && rm -rf "$TEST_HOME"
  [[ -n "${TAR_SRC:-}"   && -d "$TAR_SRC"   ]] && rm -rf "$TAR_SRC"
  [[ -n "${FAKE_BIN:-}"  && -d "$FAKE_BIN"  ]] && rm -rf "$FAKE_BIN"
}

run_install() {
  cd "$TEST_HOME"
  run bash "$INSTALL_SH" "$@"
}

@test "version: writes literal ref for a non-main branch" {
  test_helper::make_marshail_tarball "marshail-feat" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  run_install --ref my-feature-branch --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.marshail/VERSION" ]
  run cat "$TEST_HOME/.marshail/VERSION"
  [ "$output" = "my-feature-branch" ]
}

@test "version: writes the tag name verbatim when --ref is a tag" {
  test_helper::make_marshail_tarball "marshail-1.2.3" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  run_install --ref v1.2.3 --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  run cat "$TEST_HOME/.marshail/VERSION"
  [ "$output" = "v1.2.3" ]
}

@test "version: falls back to 'main' when the GitHub API is unreachable" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"
  # FAKE_COMMIT_JSON / FAKE_TAGS_JSON unset -> fake curl returns nonzero.

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  run cat "$TEST_HOME/.marshail/VERSION"
  [ "$output" = "main" ]
}

@test "version: falls back to 'main' when no tag points at HEAD" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  cat > "$TEST_HOME/commit.json" <<'EOF'
{
  "sha": "deadbeefcafef00d1234567890abcdef00112233",
  "commit": { "tree": { "sha": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" } }
}
EOF
  cat > "$TEST_HOME/tags.json" <<'EOF'
[
  { "name": "v0.1.0", "commit": { "sha": "1111111111111111111111111111111111111111" } },
  { "name": "v0.2.0", "commit": { "sha": "2222222222222222222222222222222222222222" } }
]
EOF
  export FAKE_COMMIT_JSON="$TEST_HOME/commit.json"
  export FAKE_TAGS_JSON="$TEST_HOME/tags.json"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  run cat "$TEST_HOME/.marshail/VERSION"
  [ "$output" = "main" ]
}

@test "version: lists tag(s) pointing at main HEAD" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  cat > "$TEST_HOME/commit.json" <<'EOF'
{
  "sha": "deadbeefcafef00d1234567890abcdef00112233",
  "commit": { "tree": { "sha": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" } }
}
EOF
  cat > "$TEST_HOME/tags.json" <<'EOF'
[
  { "name": "v0.9.0", "commit": { "sha": "1111111111111111111111111111111111111111" } },
  { "name": "v1.0.0", "commit": { "sha": "deadbeefcafef00d1234567890abcdef00112233" } },
  { "name": "latest", "commit": { "sha": "deadbeefcafef00d1234567890abcdef00112233" } }
]
EOF
  export FAKE_COMMIT_JSON="$TEST_HOME/commit.json"
  export FAKE_TAGS_JSON="$TEST_HOME/tags.json"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.marshail/VERSION" ]
  grep -qx "v1.0.0" "$TEST_HOME/.marshail/VERSION"
  grep -qx "latest" "$TEST_HOME/.marshail/VERSION"
  ! grep -qx "v0.9.0" "$TEST_HOME/.marshail/VERSION"
  ! grep -qx "main"   "$TEST_HOME/.marshail/VERSION"
}

@test "version: is refreshed on re-run when the ref changes" {
  test_helper::make_marshail_tarball "marshail-main"  "$TEST_HOME/snap1.tgz"
  test_helper::make_marshail_tarball "marshail-1.0.0" "$TEST_HOME/snap2.tgz"

  export FAKE_TARBALL="$TEST_HOME/snap1.tgz"
  run_install --ref some-branch --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  run cat "$TEST_HOME/.marshail/VERSION"
  [ "$output" = "some-branch" ]

  export FAKE_TARBALL="$TEST_HOME/snap2.tgz"
  run_install --ref v1.0.0 --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  run cat "$TEST_HOME/.marshail/VERSION"
  [ "$output" = "v1.0.0" ]
}
