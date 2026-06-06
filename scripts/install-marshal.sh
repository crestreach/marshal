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
#      `config.yml` is generated from the shipped template on a fresh install;
#      on an update it is reconciled in place — newly introduced properties are
#      added (prompt defaults to yes), existing values are left alone, and
#      obsolete properties are kept unless you choose to drop them (prompt
#      defaults to no). `marshal-override.md` is seeded once and never
#      clobbered. This mirrors how cyncia reconciles its own cyncia.conf.
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
_usage() { sed -n '2,44p' "$0" | sed 's/^# \{0,1\}//'; }

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

# ---------------------------------------------------------------------------
# config.yml schema + nested-YAML reconcile (mirrors cyncia's cyncia.conf
# logic, adapted for MARSHAL's two-section nested config).
#
# Each schema entry is "section|key|default|description". The installer:
#   * creates config.yml from the shipped template when it is missing,
#   * on update, keeps the existing file and:
#       - adds properties newly introduced in this version (in the schema but
#         missing from the file) — interactive prompt defaults to "yes",
#       - prompts (default "no", i.e. keep) before removing properties that
#         are no longer in the schema.
# Descriptions must not contain the '|' field separator.
# ---------------------------------------------------------------------------
MARSHAL_CONF_SCHEMA=(
  "knowledge|contract_ref|references/knowledge-contract.md|General contract every knowledge implementation must satisfy."
  "knowledge|representation_ref|references/knowledge-markdown-spine.md|Active knowledge implementation; must satisfy contract_ref. Swap representations by pointing this at another implementation reference."
  "knowledge|autonomy|auto|auto = agents write knowledge without per-change approval and return a summary (default); review = every write produces a diff for human approval first."
  "knowledge|curator_invocation|driver|Who runs marshal-knowledge-curator after the knowledge inbox is populated: driver = the caller (driver or user) runs it (default); agent = the agent runs it itself."
  "knowledge|capture_during_process|false|Whether knowledge is augmented during the process (true: notes go to knowledge/learn/inbox) or only in the Learn stage (false: findings go to the phase learnings file)."
  "knowledge|rescan_period_days|7|Advisory rescan cadence in days. The rescan is still triggered explicitly via marshal-knowledge-maintain (mode: rescan)."
  "knowledge|root_index_max_lines|150|Cap for the always-loaded root knowledge INDEX.md."
  "knowledge|subindex_max_lines|150|Cap for any sub-index file (folder index, topic sub-index, etc.)."
  "knowledge|topic_max_lines|400|Soft cap for an individual topic file; exceeding it makes the curator propose splitting the topic into a folder with a sub-index plus subtopics."
  "sync|agent_config_dir|.agent-config|Config-sync source tree that cyncia consumes. marshal-promote-assets writes promoted assets here."
  "sync|skill_flavor|delegate|Which built-in skill flavor marshal-promote-assets promotes: delegate (thin subagent wrappers; default) or fallback (full inline skills)."
)

_lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# _yaml_has_key <file> <section> <key> -> prints 1 if section.key exists, else 0.
_yaml_has_key() {
  awk -v sec="$2" -v key="$3" '
    BEGIN { found=0; cur="" }
    {
      line=$0
      if (line ~ /^[A-Za-z0-9_-]+:/) { s=line; sub(/:.*$/,"",s); cur=s; next }
      if (cur==sec && line ~ /^[[:space:]]+[A-Za-z0-9_-]+:/) {
        k=line; sub(/^[[:space:]]+/,"",k); sub(/:.*$/,"",k)
        if (k==key) { found=1; exit }
      }
    }
    END { print found?1:0 }
  ' "$1"
}

# _yaml_keys <file> -> prints "section|key" for every nested leaf, in order.
_yaml_keys() {
  awk '
    {
      line=$0
      if (line ~ /^[A-Za-z0-9_-]+:/) { s=line; sub(/:.*$/,"",s); cur=s; next }
      if (cur!="" && line ~ /^[[:space:]]+[A-Za-z0-9_-]+:/) {
        k=line; sub(/^[[:space:]]+/,"",k); sub(/:.*$/,"",k)
        if (k!="") print cur"|"k
      }
    }
  ' "$1"
}

# _yaml_append_key <file> <section> <key> <default> <description>
# Adds the key (with a wrapped, 2-space-indented comment) under its section.
# If the section is absent, the section header is appended first.
_yaml_append_key() {
  local file="$1" section="$2" key="$3" def="$4" desc="$5" block
  block="$(printf '%s' "$desc" | awk '
    {
      n=split($0, w, /[[:space:]]+/); line="  #"
      for (i=1; i<=n; i++) {
        if (w[i]=="") continue
        t=line" "w[i]
        if (length(t)>78 && line!="  #") { print line; line="  # "w[i] }
        else { line=(line=="  #")?"  # "w[i]:line" "w[i] }
      }
      if (line!="  #") print line
    }')"
  block="${block}"$'\n'"  ${key}: ${def}"
  if grep -qE "^${section}:[[:space:]]*$" "$file"; then
    awk -v sec="$section" -v ins="$block" '
      { print }
      $0 ~ "^"sec":[[:space:]]*$" && !done { print ins; done=1 }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  else
    { printf '\n%s:\n%s\n' "$section" "$block"; } >> "$file"
  fi
}

# _yaml_remove_key <file> <section> <key> -> drops the section.key line.
_yaml_remove_key() {
  awk -v sec="$2" -v key="$3" '
    {
      line=$0
      if (line ~ /^[A-Za-z0-9_-]+:/) { s=line; sub(/:.*$/,"",s); cur=s; print; next }
      if (cur==sec && line ~ /^[[:space:]]+[A-Za-z0-9_-]+:/) {
        k=line; sub(/^[[:space:]]+/,"",k); sub(/:.*$/,"",k)
        if (k==key) next
      }
      print
    }
  ' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

# _ask_default <prompt> <default-yes|default-no> -> 0 for yes, 1 for no.
# Non-interactive (no TTY) falls back to the stated default, like cyncia.
_ask_default() {
  local prompt="$1" default="$2" reply hint
  if ! { exec 3</dev/tty; } 2>/dev/null; then
    case "$default" in
      default-yes) _info "  (no TTY) $prompt -> yes (default)"; return 0 ;;
      *)           _info "  (no TTY) $prompt -> no (default)";  return 1 ;;
    esac
  fi
  exec 3<&-
  if [ "$default" = default-yes ]; then hint="[Y/n]"; else hint="[y/N]"; fi
  read -r -p "  $prompt $hint " reply </dev/tty || reply=""
  reply="$(_lower "$reply")"
  if [ "$default" = default-yes ]; then
    [ -z "$reply" ] || [ "$reply" = y ] || [ "$reply" = yes ]
  else
    [ "$reply" = y ] || [ "$reply" = yes ]
  fi
}

# _reconcile_config <template> <target>
_reconcile_config() {
  local tmpl="$1" conf="$2" entry _sec _key _def _desc _esec _ekey known
  if [ ! -f "$conf" ]; then
    _info "creating $conf (defaults from template)"
    cp "$tmpl" "$conf"
    return
  fi
  _info "keeping existing $conf (reconciling against current schema)"
  # Pass 1: add properties in the schema but missing from the file.
  for entry in "${MARSHAL_CONF_SCHEMA[@]}"; do
    IFS='|' read -r _sec _key _def _desc <<< "$entry"
    if [ "$(_yaml_has_key "$conf" "$_sec" "$_key")" = "0" ]; then
      _info "new config property in this version: $_sec.$_key (default: $_def)"
      if _ask_default "add '$_key: $_def' under '$_sec:' in $conf?" default-yes; then
        _yaml_append_key "$conf" "$_sec" "$_key" "$_def" "$_desc"
        _info "  added $_sec.$_key"
      else
        _info "  skipped $_sec.$_key (MARSHAL will use the built-in default: $_def)"
      fi
    fi
  done
  # Pass 2: prompt (default keep) for properties no longer in the schema.
  while IFS='|' read -r _esec _ekey; do
    [ -z "${_ekey:-}" ] && continue
    known=no
    for entry in "${MARSHAL_CONF_SCHEMA[@]}"; do
      IFS='|' read -r _sec _key _ _ <<< "$entry"
      if [ "$_sec" = "$_esec" ] && [ "$_key" = "$_ekey" ]; then known=yes; break; fi
    done
    if [ "$known" = no ]; then
      _info "property in $conf no longer used by MARSHAL: $_esec.$_ekey"
      if _ask_default "remove '$_ekey' from '$_esec:'?" default-no; then
        _yaml_remove_key "$conf" "$_esec" "$_ekey"
        _info "  removed $_esec.$_ekey"
      else
        _info "  kept $_esec.$_ekey (ignored by MARSHAL)"
      fi
    fi
  done < <(_yaml_keys "$conf" | awk '!seen[$0]++')
}


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
# Copy the asset trees, preserving any local state the user already has.
# Static spec files and asset folders are refreshed; the agent-managed
# knowledge tree and the per-change work tree are left untouched if present.
# config.yml and marshal-override.md are handled specially below (never
# clobbered on update).
for item in AGENTS.md ENTRYPOINT.md \
            skills skills-fallback agents rules extensions references design; do
  if [ -e "$SRC/$item" ]; then
    rm -rf "${MARSHAL_DIR:?}/$item"
    cp -R "$SRC/$item" "$MARSHAL_DIR/$item"
  fi
done

# marshal-override.md: seed it on a fresh install, never clobber on update.
if [ -e "$SRC/marshal-override.md" ] && [ ! -e "$MARSHAL_DIR/marshal-override.md" ]; then
  cp "$SRC/marshal-override.md" "$MARSHAL_DIR/marshal-override.md"
fi

# config.yml: generate from the shipped template on a fresh install; on an
# update, reconcile in place (add newly introduced properties, leave existing
# values alone, keep obsolete ones unless the user opts to drop them). This
# mirrors how the cyncia installer reconciles its own cyncia.conf.
_reconcile_config "$SRC/config.yml" "$MARSHAL_DIR/config.yml"

# 2. Ensure cyncia is available.
# Note: the cyncia installer is fetched over HTTPS and piped to a shell, the
# same trust model cyncia documents for its own install. If you need a
# stronger guarantee, install cyncia separately (vetting/pinning a release)
# and re-run this script with --no-cyncia.
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
