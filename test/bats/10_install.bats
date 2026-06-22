#!/usr/bin/env bats
# Tests for scripts/install-marshail.sh — fetch + asset-install behavior.
#
# These never touch the network: a fake `curl`/`wget` placed first on PATH
# emits a tarball assembled from a synthetic marshail-files/ fixture, exactly
# the way cyncia's own installer tests work.

load 'test_helper'

setup() {
  TEST_HOME="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/marshail_install.XXXXXX")"
  TAR_SRC="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/marshail_install_tar.XXXXXX")"
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

@test "install: --help prints usage and exits 0" {
  cd "$TEST_HOME"
  run bash "$INSTALL_SH" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"install-marshail.sh"* ]]
  [[ "$output" == *"--marshail-dir"* ]]
  [[ "$output" == *"--no-cyncia"* ]]
  # Help reflects the tarball fetch (not a git clone).
  [[ "$output" == *"tarball snapshot"* ]]
}

@test "install: rejects unknown option" {
  cd "$TEST_HOME"
  run bash "$INSTALL_SH" --bogus
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown argument"* ]]
}

@test "install: fresh install copies the marshail-files subtree into .marshail" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz" "RUN1"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # Static files and asset folders landed.
  [ -f "$TEST_HOME/.marshail/ENTRYPOINT.md" ]
  [ -f "$TEST_HOME/.marshail/AGENTS.md" ]
  [ -f "$TEST_HOME/.marshail/LICENSE" ]
  [ -f "$TEST_HOME/.marshail/marshail.md" ]
  [ -f "$TEST_HOME/.marshail/agents/marshail-planner.md" ]
  [ -f "$TEST_HOME/.marshail/skills/marshail-sample/SKILL.md" ]
  [ -d "$TEST_HOME/.marshail/skills-fallback/marshail-sample" ]
  [ -f "$TEST_HOME/.marshail/rules/README.md" ]
  [ -f "$TEST_HOME/.marshail/extensions/README.md" ]
  [ -f "$TEST_HOME/.marshail/references/activation-protocol.md" ]

  # config.yml created and marshail-override.md seeded on a fresh install.
  [ -f "$TEST_HOME/.marshail/config.yml" ]
  [ -f "$TEST_HOME/.marshail/marshail-override.md" ]
  grep -q "RUN1" "$TEST_HOME/.marshail/marshail-override.md"
}

@test "install: marshail.md (subtree) and the repo-root LICENSE land inside .marshail" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz" "ROOTDOC"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # marshail.md ships with the marshail-files/ subtree; LICENSE is sourced from
  # the snapshot root. Both land *inside* .marshail/.
  [ -f "$TEST_HOME/.marshail/marshail.md" ]
  grep -q "ROOTDOC" "$TEST_HOME/.marshail/marshail.md"
  [ -f "$TEST_HOME/.marshail/LICENSE" ]
  grep -q "ROOTDOC" "$TEST_HOME/.marshail/LICENSE"

  # marshail.md is not dropped at the consumer repo root.
  [ ! -f "$TEST_HOME/marshail.md" ]
}

@test "install: requests the GitHub archive tarball, never git clone" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"
  export CURL_LOG="$TEST_HOME/curl.log"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # The fetch went through the archive endpoint of the default slug.
  grep -q "https://github.com/crestreach/marshail/archive/main.tar.gz" "$CURL_LOG"
}

@test "install: works even when git is unavailable (no git dependency)" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  # Shadow `git` with a command that always fails, proving the installer no
  # longer relies on git for either repo-root detection or fetching.
  cat > "$FAKE_BIN/git" <<'EOF'
#!/usr/bin/env bash
echo "git should not be called" >&2
exit 127
EOF
  chmod +x "$FAKE_BIN/git"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.marshail/ENTRYPOINT.md" ]
}

@test "install: respects a custom --repo slug in the archive URL" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"
  export CURL_LOG="$TEST_HOME/curl.log"

  run_install --repo myorg/myfork --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  grep -q "https://github.com/myorg/myfork/archive/main.tar.gz" "$CURL_LOG"
}

@test "install: accepts a full GitHub URL for --repo and normalizes it" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"
  export CURL_LOG="$TEST_HOME/curl.log"

  run_install --repo https://github.com/myorg/myfork.git --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  grep -q "https://github.com/myorg/myfork/archive/main.tar.gz" "$CURL_LOG"
}

@test "install: handles a tarball whose top-level dir has a v-stripped tag prefix" {
  # GitHub strips the leading 'v' from tag refs in the tarball top-level dir.
  test_helper::make_marshail_tarball "marshail-1.2.3" "$TEST_HOME/snap.tgz" "TAG"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  run_install --ref v1.2.3 --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.marshail/ENTRYPOINT.md" ]
  grep -q "TAG" "$TEST_HOME/.marshail/marshail-override.md"
}

@test "install: custom --marshail-dir places assets there" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  run_install --marshail-dir vendor/marshail --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/vendor/marshail/ENTRYPOINT.md" ]
  # marshail.md and LICENSE follow the install dir (inside it), not the repo root.
  [ -f "$TEST_HOME/vendor/marshail/marshail.md" ]
  [ -f "$TEST_HOME/vendor/marshail/LICENSE" ]
  [ ! -f "$TEST_HOME/vendor/marshail.md" ]
  [ ! -d "$TEST_HOME/.marshail" ]
}

@test "install: errors when the snapshot has no marshail-files/ directory" {
  # A tarball with the right shape but no marshail-files/ subtree.
  local stage="$TAR_SRC/bad"
  mkdir -p "$stage/marshail-main/somethingelse"
  echo "x" > "$stage/marshail-main/somethingelse/file.txt"
  ( cd "$stage" && tar -czf "$TEST_HOME/bad.tgz" marshail-main )
  export FAKE_TARBALL="$TEST_HOME/bad.tgz"

  run_install --no-cyncia --no-sync
  [ "$status" -ne 0 ]
  [[ "$output" == *"no marshail-files/ directory"* ]]
}

@test "install: re-run preserves user-edited marshail-override.md and knowledge/work trees" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz" "FRESH"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"

  # First install.
  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # User customizes the override and adds agent-managed knowledge + work trees.
  echo "MY CUSTOM OVERRIDE" > "$TEST_HOME/.marshail/marshail-override.md"
  mkdir -p "$TEST_HOME/.marshail/knowledge" "$TEST_HOME/.marshail/work"
  echo "kept-knowledge" > "$TEST_HOME/.marshail/knowledge/INDEX.md"
  echo "kept-work"      > "$TEST_HOME/.marshail/work/current"

  # Second install (update).
  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # Override is never clobbered; knowledge/work are left untouched.
  grep -q "MY CUSTOM OVERRIDE" "$TEST_HOME/.marshail/marshail-override.md"
  grep -q "kept-knowledge" "$TEST_HOME/.marshail/knowledge/INDEX.md"
  grep -q "kept-work" "$TEST_HOME/.marshail/work/current"
}

@test "install: --no-cyncia with no existing .cyncia skips cyncia install and sync" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"
  export CURL_LOG="$TEST_HOME/curl.log"

  run_install --no-cyncia
  [ "$status" -eq 0 ]
  [[ "$output" == *"--no-cyncia set"* ]]
  # No cyncia installer URL was ever fetched.
  ! grep -q "install.sh" "$CURL_LOG"
  [ ! -d "$TEST_HOME/.cursor" ]
}

@test "install: installs cyncia via the corrected install/install.sh URL when missing" {
  test_helper::make_marshail_tarball "marshail-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"
  export CURL_LOG="$TEST_HOME/curl.log"

  # cyncia is missing (no .cyncia/scripts/sync-all.sh) and install is enabled.
  # --no-sync avoids needing a real cyncia checkout afterwards.
  run_install --no-sync
  [ "$status" -eq 0 ]
  [[ "$output" == *"FAKE-CYNCIA-INSTALLER-RAN"* ]]
  # The fetched cyncia installer URL lives under install/ (the bug was the
  # missing install/ path segment, which returned 404).
  grep -q "raw.githubusercontent.com/crestreach/cyncia/main/install/install.sh" "$CURL_LOG"
  ! grep -qE "cyncia/main/install\.sh$" "$CURL_LOG"
}
