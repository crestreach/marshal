#!/usr/bin/env bats
# Tests for scripts/install-marshal.sh — config.yml reconcile behavior:
#   * creates config.yml from the shipped template on a fresh install,
#   * leaves an existing file's values alone on re-install,
#   * adds schema properties newly introduced in this version (no-TTY -> yes),
#   * keeps properties no longer in the schema by default (no-TTY -> no).
#
# Mirrors cyncia's 81_install_conf.bats for its cyncia.conf reconcile.

load 'test_helper'

setup() {
  TEST_HOME="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/marshal_conf.XXXXXX")"
  TAR_SRC="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/marshal_conf_tar.XXXXXX")"
  test_helper::install_fake_fetchers
  test_helper::make_marshal_tarball "marshal-main" "$TEST_HOME/snap.tgz"
  export FAKE_TARBALL="$TEST_HOME/snap.tgz"
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

@test "config: fresh install creates config.yml from the template" {
  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  [ -f "$TEST_HOME/.marshal/config.yml" ]
  grep -Eq '^[[:space:]]*autonomy:[[:space:]]*auto' "$TEST_HOME/.marshal/config.yml"
  grep -Eq '^[[:space:]]*skill_flavor:[[:space:]]*delegate' "$TEST_HOME/.marshal/config.yml"
  [[ "$output" == *"creating"* ]]
  [[ "$output" == *"config.yml"* ]]
}

@test "config: re-install preserves an edited value" {
  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # User flips skill_flavor delegate -> fallback (portable in-place edit).
  awk '/^[[:space:]]*skill_flavor:/ { sub(/delegate/, "fallback") } { print }' \
    "$TEST_HOME/.marshal/config.yml" > "$TEST_HOME/.marshal/config.yml.tmp"
  mv "$TEST_HOME/.marshal/config.yml.tmp" "$TEST_HOME/.marshal/config.yml"
  cp "$TEST_HOME/.marshal/config.yml" "$TEST_HOME/conf.before"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  diff -u "$TEST_HOME/conf.before" "$TEST_HOME/.marshal/config.yml"
  grep -Eq '^[[:space:]]*skill_flavor:[[:space:]]*fallback' "$TEST_HOME/.marshal/config.yml"
  [[ "$output" == *"keeping existing"* ]]
}

@test "config: adds a schema property missing from an existing file (no-TTY -> yes)" {
  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # Simulate an older config that predates topic_max_lines.
  grep -v 'topic_max_lines' "$TEST_HOME/.marshal/config.yml" > "$TEST_HOME/.marshal/config.yml.tmp"
  mv "$TEST_HOME/.marshal/config.yml.tmp" "$TEST_HOME/.marshal/config.yml"
  ! grep -q 'topic_max_lines' "$TEST_HOME/.marshal/config.yml"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  grep -Eq '^[[:space:]]*topic_max_lines:[[:space:]]*400' "$TEST_HOME/.marshal/config.yml"
  [[ "$output" == *"new config property"* ]]
  [[ "$output" == *"topic_max_lines"* ]]
  [[ "$output" == *"-> yes"* ]]
}

@test "config: keeps a property no longer in the schema by default (no-TTY -> no)" {
  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]

  # Append a property MARSHAL no longer knows about, under the sync section.
  printf '  legacy_option: keepme\n' >> "$TEST_HOME/.marshal/config.yml"

  run_install --no-cyncia --no-sync
  [ "$status" -eq 0 ]
  [[ "$output" == *"no longer used"* ]]
  [[ "$output" == *"legacy_option"* ]]
  # Default for removal is NO, so it must still be present.
  grep -q 'legacy_option' "$TEST_HOME/.marshal/config.yml"
}
