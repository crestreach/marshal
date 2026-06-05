#!/usr/bin/env bash
#
# install-marshal.sh — fetch (or update) MARSHAL durable assets in a repo,
# ensure cyncia is installed, and optionally fan the assets out to per-tool
# layouts with the cyncia sync.
#
# This mirrors what the `marshal-init` skill does, as a standalone,
# re-runnable script for users who would rather run a command than drive an
# AI assistant. It is idempotent: re-running it updates `.marshal/` to the
# requested ref.
#
# Usage:
#   install-marshal.sh [options]
#
#   --ref <git-ref>        MARSHAL ref to install (branch/tag/sha). Default: main.
#   --repo <url>           MARSHAL source repo. Default:
#                          https://github.com/crestreach/marshal.git
#   --marshal-dir <path>   Where to place the durable assets in the target
#                          repo. Default: .marshal
#   --agent-config <path>  Config-sync source tree. Default: .agent-config
#   --no-cyncia            Do not install cyncia even if it is missing.
#   --no-sync              Do not run the cyncia sync at the end.
#   -h, --help             Show this help.
#
# What it does:
#   1. Clones the MARSHAL repo at <ref> into a temp dir and copies its
#      `marshal-files/` subtree into <marshal-dir> (creating or updating it).
#   2. Ensures cyncia is available (looks for <agent-config>/../.cyncia or a
#      `.cyncia/` at the repo root); installs it via cyncia's own installer
#      when missing (unless --no-cyncia). cyncia is committed into the repo,
#      not a git submodule.
#   3. When <agent-config> exists, runs `.cyncia/scripts/sync-all.sh` to fan
#      the source tree out to tool layouts (unless --no-sync).
#
# Note: wiring MARSHAL's durable assets into <agent-config> (the
# `marshal-promote-assets` step) is a MARSHAL skill, not part of this script.
# Run `marshal-promote-assets` (or `marshal-init`) once to populate
# <agent-config> before the sync can fan MARSHAL skills out to tools.

set -euo pipefail

MARSHAL_REPO="https://github.com/crestreach/marshal.git"
MARSHAL_REF="main"
MARSHAL_DIR=".marshal"
AGENT_CONFIG_DIR=".agent-config"
CYNCIA_INSTALLER="https://raw.githubusercontent.com/crestreach/cyncia/main/install.sh"
INSTALL_CYNCIA=true
RUN_SYNC=true

_die() { printf 'install-marshal: %s\n' "$*" >&2; exit 1; }
_info() { printf 'install-marshal: %s\n' "$*"; }
_usage() { sed -n '2,38p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --ref) MARSHAL_REF="${2:-}"; shift 2 ;;
    --repo) MARSHAL_REPO="${2:-}"; shift 2 ;;
    --marshal-dir) MARSHAL_DIR="${2:-}"; shift 2 ;;
    --agent-config) AGENT_CONFIG_DIR="${2:-}"; shift 2 ;;
    --no-cyncia) INSTALL_CYNCIA=false; shift ;;
    --no-sync) RUN_SYNC=false; shift ;;
    -h|--help) _usage; exit 0 ;;
    *) _die "unknown argument: $1 (try --help)" ;;
  esac
done

command -v git >/dev/null 2>&1 || _die "git is required but not found on PATH"

# Resolve the target repo root (prefer the git toplevel; fall back to cwd).
if REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  :
else
  REPO_ROOT="$(pwd)"
fi
cd "$REPO_ROOT"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# 1. Fetch the requested MARSHAL ref and copy its marshal-files/ subtree.
_info "fetching MARSHAL ($MARSHAL_REF) from $MARSHAL_REPO"
git clone --depth 1 --branch "$MARSHAL_REF" "$MARSHAL_REPO" "$TMP_DIR/marshal" 2>/dev/null \
  || git clone "$MARSHAL_REPO" "$TMP_DIR/marshal"
if [ "$MARSHAL_REF" != "main" ]; then
  git -C "$TMP_DIR/marshal" checkout --quiet "$MARSHAL_REF" \
    || _die "ref not found: $MARSHAL_REF"
fi

SRC="$TMP_DIR/marshal/marshal-files"
[ -d "$SRC" ] || _die "the MARSHAL repo has no marshal-files/ directory"

_info "installing durable assets into $MARSHAL_DIR"
mkdir -p "$MARSHAL_DIR"
# Copy the asset trees, preserving any local knowledge the user already has.
# Static spec/config files and asset folders are refreshed; the agent-managed
# knowledge tree and the per-change work tree are left untouched if present.
for item in AGENTS.md ENTRYPOINT.md config.yml marshal-override.md \
            skills skills-fallback agents rules extensions references design; do
  if [ -e "$SRC/$item" ]; then
    if [ "$item" = "marshal-override.md" ] && [ -e "$MARSHAL_DIR/$item" ]; then
      # Never clobber a user's override file on update.
      continue
    fi
    rm -rf "$MARSHAL_DIR/$item"
    cp -R "$SRC/$item" "$MARSHAL_DIR/$item"
  fi
done

# 2. Ensure cyncia is available.
if [ -x ".cyncia/scripts/sync-all.sh" ]; then
  _info "cyncia already installed at .cyncia"
elif [ "$INSTALL_CYNCIA" = true ]; then
  _info "installing cyncia via its installer"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$CYNCIA_INSTALLER" | sh
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$CYNCIA_INSTALLER" | sh
  else
    _die "neither curl nor wget found; install cyncia manually (see $CYNCIA_INSTALLER)"
  fi
else
  _info "cyncia not found and --no-cyncia set; skipping install"
fi

# 3. Optionally run the sync.
if [ "$RUN_SYNC" = true ] && [ -x ".cyncia/scripts/sync-all.sh" ]; then
  if [ -f "$AGENT_CONFIG_DIR/AGENTS.md" ]; then
    _info "running cyncia sync ($AGENT_CONFIG_DIR -> repo root)"
    .cyncia/scripts/sync-all.sh -i "$AGENT_CONFIG_DIR" -o .
  else
    _info "no $AGENT_CONFIG_DIR/AGENTS.md found; skipping sync."
    _info "run 'marshal-promote-assets' (or 'marshal-init') to populate $AGENT_CONFIG_DIR first."
  fi
fi

_info "done. MARSHAL assets are in $MARSHAL_DIR."
