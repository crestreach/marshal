#!/usr/bin/env bash
#
# install-marshail.sh — fetch (or update) MARSHAIL durable assets in a repo,
# ensure cyncia is installed, and optionally fan the assets out to per-tool
# layouts with the cyncia sync.
#
# This mirrors what the `marshail-init` skill does, as a standalone,
# re-runnable script for users who would rather run a command than drive an
# AI assistant. It is idempotent: re-running it updates `.marshail/` to the
# requested ref.
#
# Usage:
#   install-marshail.sh [options]
#
#   --ref <git-ref>        MARSHAIL ref to install (branch/tag/sha). Default: main.
#   --repo <slug|url>      MARSHAIL source repo as owner/name (or a GitHub
#                          URL). Default: crestreach/marshail
#   --marshail-dir <path>   Where to place the durable assets in the target
#                          repo. Default: .marshail
#   --agent-config <path>  Config-sync source tree. Default: .agent-config
#   --no-cyncia            Do not install cyncia even if it is missing.
#   --no-sync              Do not run the cyncia sync at the end.
#   -h, --help             Show this help.
#
# What it does:
#   1. Downloads a tarball snapshot of the MARSHAIL repo at <ref> and copies
#      its `marshail-files/` subtree into <marshail-dir> (creating or updating it).
#      `config.yml` is generated from the shipped template on a fresh install;
#      on an update it is reconciled in place — newly introduced properties are
#      added (prompt defaults to yes), existing values are left alone, and
#      obsolete properties are kept unless you choose to drop them (prompt
#      defaults to no). `marshail-override.md` is seeded once and never
#      clobbered. This mirrors how cyncia reconciles its own cyncia.conf.
#      The `LICENSE` lives at the MARSHAIL repo *root* (outside `marshail-files/`)
#      and is installed *inside* <marshail-dir> (`.marshail/LICENSE`). The
#      canonical spec `marshail.md` ships inside `marshail-files/`, so it lands at
#      `<marshail-dir>/marshail.md` with the rest of the tree.
#      A `VERSION` file recording the installed ref (or, for `main`, any tag(s)
#      pointing at HEAD) is written into <marshail-dir>, like cyncia's VERSION.
#   2. Ensures cyncia is available (looks for <agent-config>/../.cyncia or a
#      `.cyncia/` at the repo root); installs it via cyncia's own installer
#      when missing (unless --no-cyncia). cyncia is committed into the repo,
#      not a git submodule.
#   3. When <agent-config> exists, runs `.cyncia/scripts/sync-all.sh` to fan
#      the source tree out to tool layouts (unless --no-sync).
#
# Note: wiring MARSHAIL's durable assets into <agent-config> (the
# `marshail-promote-assets` step) is a MARSHAIL skill, not part of this script.
# Run `marshail-promote-assets` (or `marshail-init`) once to populate
# <agent-config> before the sync can fan MARSHAIL skills out to tools.

set -euo pipefail

MARSHAIL_REPO="crestreach/marshail"
MARSHAIL_REF="main"
MARSHAIL_DIR=".marshail"
AGENT_CONFIG_DIR=".agent-config"
CYNCIA_INSTALLER="https://raw.githubusercontent.com/crestreach/cyncia/main/install/install.sh"
INSTALL_CYNCIA=true
RUN_SYNC=true

_die() { printf 'install-marshail: %s\n' "$*" >&2; exit 1; }
_info() { printf 'install-marshail: %s\n' "$*"; }
_usage() { sed -n '2,50p' "$0" | sed 's/^# \{0,1\}//'; }

# Normalize a repo reference (owner/name slug, https URL, or git@ URL, with or
# without a trailing .git) to the bare owner/name slug used to build the GitHub
# archive tarball URL.
_repo_slug() {
  local r="$1"
  r="${r%.git}"
  r="${r#https://github.com/}"
  r="${r#http://github.com/}"
  r="${r#git@github.com:}"
  printf '%s' "$r"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --ref) MARSHAIL_REF="${2:-}"; shift 2 ;;
    --repo) MARSHAIL_REPO="${2:-}"; shift 2 ;;
    --marshail-dir) MARSHAIL_DIR="${2:-}"; shift 2 ;;
    --agent-config) AGENT_CONFIG_DIR="${2:-}"; shift 2 ;;
    --no-cyncia) INSTALL_CYNCIA=false; shift ;;
    --no-sync) RUN_SYNC=false; shift ;;
    -h|--help) _usage; exit 0 ;;
    *) _die "unknown argument: $1 (try --help)" ;;
  esac
done

command -v tar >/dev/null 2>&1 || _die "tar is required but not found on PATH"
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  _die "curl or wget is required but neither was found on PATH"
fi
MARSHAIL_SLUG="$(_repo_slug "$MARSHAIL_REPO")"

# ---------------------------------------------------------------------------
# config.yml schema + nested-YAML reconcile (mirrors cyncia's cyncia.conf
# logic, adapted for MARSHAIL's two-section nested config).
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
MARSHAIL_CONF_SCHEMA=(
  "knowledge|contract_ref|references/knowledge-contract.md|General contract every knowledge implementation must satisfy."
  "knowledge|representation_ref|references/knowledge-markdown-spine.md|Active knowledge implementation; must satisfy contract_ref. Swap representations by pointing this at another implementation reference."
  "knowledge|autonomy|auto|auto = agents write knowledge without per-change approval and return a summary (default); review = every write produces a diff for human approval first."
  "knowledge|curator_invocation|driver|Who runs marshail-knowledge-curator after the knowledge inbox is populated: driver = the caller (driver or user) runs it (default); agent = the agent runs it itself."
  "knowledge|capture_during_process|true|Whether knowledge is augmented during the process (true: notes go to knowledge/learn/inbox) or only in the Learn stage (false: findings go to the phase learnings file)."
  "knowledge|scan_depth|standard|How aggressively init / rebuild deepen the knowledge tree from a real entrypoint-driven code scan. shallow = stay near a per-subsystem / per-module map and expand only clearly complex areas; standard = analyze each non-trivial module and capability on its own (default); deep = also give complex components, algorithms, and end-to-end flows their own focused topics. Depth is still decided locally per node, so agents go deeper for complex areas and shallower for trivial ones."
  "knowledge|rescan_period_days|7|Advisory rescan cadence in days. The rescan is still triggered explicitly via marshail-knowledge-maintain (mode: rescan)."
  "knowledge|root_index_max_lines|150|Cap for the always-loaded root knowledge INDEX.md."
  "knowledge|subindex_max_lines|150|Cap for any sub-index file (folder index, topic sub-index, etc.)."
  "knowledge|topic_max_lines|400|Soft cap for an individual topic file; exceeding it makes the curator propose splitting the topic into a folder with a sub-index plus subtopics."
  "extensions|autonomy|review|Approval mode for MARSHAIL extension and guidance assets created or updated outside the knowledge layer (mx-* rules/skills/subagents under .marshail/extensions/, plus Learn-stage AGENTS.md / README updates). review = every create or update produces a diff for human approval first (default); auto = the agent applies it directly and returns a summary. Knowledge writes are governed separately by knowledge.autonomy."
  "sync|agent_config_dir|.agent-config|Config-sync source tree that cyncia consumes. marshail-promote-assets writes promoted assets here."
  "sync|skill_flavor|delegate|Which built-in skill flavor marshail-promote-assets promotes: delegate (thin subagent wrappers; default) or fallback (full inline skills)."
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
    # Pass the (multi-line) block via the environment, not `awk -v`: awk
    # rejects embedded newlines in a -v assignment ("newline in string"),
    # but ENVIRON values carry them fine.
    _yaml_ins="$block" awk -v sec="$section" '
      { print }
      $0 ~ "^"sec":[[:space:]]*$" && !done { printf "%s\n", ENVIRON["_yaml_ins"]; done=1 }
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
  for entry in "${MARSHAIL_CONF_SCHEMA[@]}"; do
    IFS='|' read -r _sec _key _def _desc <<< "$entry"
    if [ "$(_yaml_has_key "$conf" "$_sec" "$_key")" = "0" ]; then
      _info "new config property in this version: $_sec.$_key (default: $_def)"
      if _ask_default "add '$_key: $_def' under '$_sec:' in $conf?" default-yes; then
        _yaml_append_key "$conf" "$_sec" "$_key" "$_def" "$_desc"
        _info "  added $_sec.$_key"
      else
        _info "  skipped $_sec.$_key (MARSHAIL will use the built-in default: $_def)"
      fi
    fi
  done
  # Pass 2: prompt (default keep) for properties no longer in the schema.
  while IFS='|' read -r _esec _ekey; do
    [ -z "${_ekey:-}" ] && continue
    known=no
    for entry in "${MARSHAIL_CONF_SCHEMA[@]}"; do
      IFS='|' read -r _sec _key _ _ <<< "$entry"
      if [ "$_sec" = "$_esec" ] && [ "$_key" = "$_ekey" ]; then known=yes; break; fi
    done
    if [ "$known" = no ]; then
      _info "property in $conf no longer used by MARSHAIL: $_esec.$_ekey"
      if _ask_default "remove '$_ekey' from '$_esec:'?" default-no; then
        _yaml_remove_key "$conf" "$_esec" "$_ekey"
        _info "  removed $_esec.$_ekey"
      else
        _info "  kept $_esec.$_ekey (ignored by MARSHAIL)"
      fi
    fi
  done < <(_yaml_keys "$conf" | awk '!seen[$0]++')
}

# ---------------------------------------------------------------------------
# VERSION file. Records the installed MARSHAIL ref in <marshail-dir>/VERSION.
# Semantics mirror cyncia's installer: write the literal ref; when that ref is
# the default branch ("main"), best-effort query the GitHub API for tag(s)
# pointing at HEAD and list those instead. The lookup may fail silently
# (offline / rate-limited / private repo) — on any failure, fall back to the
# literal ref.
# ---------------------------------------------------------------------------

# Extract the first top-level "sha" string from a GitHub commit JSON payload.
# (GitHub returns the commit SHA as the first "sha" field; nested "sha" fields
# under "tree"/"parents"/"author" come later.)
_extract_first_sha() {
  awk '
    match($0, /"sha"[[:space:]]*:[[:space:]]*"[0-9a-f]+"/) {
      s = substr($0, RSTART, RLENGTH)
      sub(/^"sha"[[:space:]]*:[[:space:]]*"/, "", s)
      sub(/"$/, "", s)
      print s
      exit
    }
  '
}

# Print tag names (one per line) whose commit.sha equals $1, parsed from the
# /repos/OWNER/NAME/tags JSON payload on stdin.
_extract_tags_for_sha() {
  awk -v target="$1" '
    BEGIN { RS = "}" }
    {
      name = ""; commit_sha = ""
      if (match($0, /"name"[[:space:]]*:[[:space:]]*"[^"]*"/)) {
        s = substr($0, RSTART, RLENGTH)
        sub(/^"name"[[:space:]]*:[[:space:]]*"/, "", s)
        sub(/"$/, "", s)
        name = s
      }
      if (match($0, /"sha"[[:space:]]*:[[:space:]]*"[0-9a-f]+"/)) {
        s = substr($0, RSTART, RLENGTH)
        sub(/^"sha"[[:space:]]*:[[:space:]]*"/, "", s)
        sub(/"$/, "", s)
        commit_sha = s
      }
      if (name != "" && commit_sha == target) print name
    }
  '
}

# _write_version <marshail-dir>
_write_version() {
  local dir="$1" version_text="$MARSHAIL_REF" api_sha api_tags
  if [ "$MARSHAIL_REF" = "main" ] && command -v curl >/dev/null 2>&1; then
    api_sha="$(curl -fsSL -H 'Accept: application/vnd.github+json' \
                "https://api.github.com/repos/${MARSHAIL_SLUG}/commits/${MARSHAIL_REF}" 2>/dev/null \
                | _extract_first_sha 2>/dev/null || true)"
    if [ -n "${api_sha:-}" ]; then
      api_tags="$(curl -fsSL -H 'Accept: application/vnd.github+json' \
                    "https://api.github.com/repos/${MARSHAIL_SLUG}/tags?per_page=100" 2>/dev/null \
                    | _extract_tags_for_sha "$api_sha" 2>/dev/null || true)"
      if [ -n "${api_tags:-}" ]; then
        version_text="$api_tags"
      fi
    fi
  fi
  printf '%s\n' "$version_text" > "$dir/VERSION"
  _info "wrote $dir/VERSION:"
  while IFS= read -r _line; do
    [ -n "$_line" ] && _info "  $_line"
  done <<< "$version_text"
}


# Resolve the target repo root (prefer the git toplevel; fall back to cwd).
if command -v git >/dev/null 2>&1 && REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  :
else
  REPO_ROOT="$(pwd)"
fi
cd "$REPO_ROOT"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# 1. Fetch the requested MARSHAIL ref as a tarball snapshot and copy its
# marshail-files/ subtree. This mirrors how the cyncia installer fetches files
# (curl | tar) — no git clone, and no git dependency.
MARSHAIL_TARBALL="https://github.com/${MARSHAIL_SLUG}/archive/${MARSHAIL_REF}.tar.gz"
_info "fetching MARSHAIL ($MARSHAIL_REF) from $MARSHAIL_TARBALL"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$MARSHAIL_TARBALL" | tar -xz -C "$TMP_DIR" \
    || _die "failed to download or extract $MARSHAIL_TARBALL (is ref '$MARSHAIL_REF' valid?)"
else
  wget -qO- "$MARSHAIL_TARBALL" | tar -xz -C "$TMP_DIR" \
    || _die "failed to download or extract $MARSHAIL_TARBALL (is ref '$MARSHAIL_REF' valid?)"
fi

# GitHub tarballs contain a single top-level directory; its name is
# "<repo>-<ref>" but the prefix can vary (tags drop a leading "v"), so find it.
SRC_ROOT="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
[ -n "$SRC_ROOT" ] || _die "extracted MARSHAIL archive is empty"
SRC="$SRC_ROOT/marshail-files"
[ -d "$SRC" ] || _die "the MARSHAIL snapshot has no marshail-files/ directory"

_info "installing durable assets into $MARSHAIL_DIR"
mkdir -p "$MARSHAIL_DIR"
# Copy the asset trees, preserving any local state the user already has.
# Static spec files and asset folders are refreshed; the agent-managed
# knowledge tree and the per-change work tree are left untouched if present.
# config.yml and marshail-override.md are handled specially below (never
# clobbered on update).
for item in AGENTS.md ENTRYPOINT.md marshail.md \
            skills skills-fallback agents rules extensions references; do
  if [ -e "$SRC/$item" ]; then
    rm -rf "${MARSHAIL_DIR:?}/$item"
    cp -R "$SRC/$item" "$MARSHAIL_DIR/$item"
  fi
done

# LICENSE lives at the MARSHAIL repo *root* (outside marshail-files/), so it is
# sourced from the snapshot root and installed *inside* <marshail-dir> (i.e.
# .marshail/LICENSE) so the install carries its own license without clobbering
# the consumer repo's own root LICENSE. (marshail.md ships as part of the
# marshail-files/ subtree above, landing at <marshail-dir>/marshail.md.)
if [ -e "$SRC_ROOT/LICENSE" ]; then
  cp "$SRC_ROOT/LICENSE" "$MARSHAIL_DIR/LICENSE"
fi

# marshail-override.md: seed it on a fresh install, never clobber on update.
if [ -e "$SRC/marshail-override.md" ] && [ ! -e "$MARSHAIL_DIR/marshail-override.md" ]; then
  cp "$SRC/marshail-override.md" "$MARSHAIL_DIR/marshail-override.md"
fi

# config.yml: generate from the shipped template on a fresh install; on an
# update, reconcile in place (add newly introduced properties, leave existing
# values alone, keep obsolete ones unless the user opts to drop them). This
# mirrors how the cyncia installer reconciles its own cyncia.conf.
_reconcile_config "$SRC/config.yml" "$MARSHAIL_DIR/config.yml"

# Record the installed version (mirrors cyncia's VERSION file semantics).
_write_version "$MARSHAIL_DIR"

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
    _info "run 'marshail-promote-assets' (or 'marshail-init') to populate $AGENT_CONFIG_DIR first."
  fi
fi

_info "done. MARSHAIL assets are in $MARSHAIL_DIR."
