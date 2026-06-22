#!/usr/bin/env bash
#
# generate-release-notes.sh — produce the GitHub-release variant of a MARSHAIL
# release-notes file.
#
# The committed notes file `rn/<version>.md` uses repo-relative `../` links so they
# resolve when the file is viewed inside the repo. On a GitHub *release page* those
# `../` links do not resolve (the page lives under `/<owner>/<repo>/releases/tag/...`),
# so this script rewrites them to root-relative links pinned to the release tag:
#
#   ../path/to/file           ->  /<owner>/<repo>/blob/<tag>/path/to/file
#   ../path/to/dir/  (slash)  ->  /<owner>/<repo>/tree/<tag>/path/to/dir
#
# Root-relative links stay relative (no `https://github.com` host hardcoded) yet
# resolve correctly from the release page. Absolute links (`https://...`) and
# in-page anchors (`#...`) are left untouched.
#
# `<owner>/<repo>` is derived from the `origin` remote; `<tag>` defaults to
# `<version>` (override with --tag for pre-tag dry runs).
#
# The generated file is a throwaway: pass it to `gh release create|edit --notes-file`
# and then delete it. Only `rn/<version>.md` (and this script) are committed; the
# `rn/release/` output directory is gitignored.
#
# Usage:
#   rn/generate-release-notes.sh <version> [-o <output-path>] [--tag <tag>]
#
#   <version>        e.g. v1.0.0  (reads rn/v1.0.0.md)
#   -o <output-path> where to write (default: rn/release/<version>-release.md;
#                    use `-` to write to stdout)
#   --tag <tag>      ref to pin links to (default: <version>)
#
# On success the output path is printed to stdout (unless -o -), so callers can do:
#   gh release edit v1.0.0 --notes-file "$(rn/generate-release-notes.sh v1.0.0)"
#
set -euo pipefail

version=""
out=""
tag=""

while [ $# -gt 0 ]; do
  case "$1" in
    -o|--output) out="${2:-}"; shift 2 ;;
    --tag)       tag="${2:-}"; shift 2 ;;
    -h|--help)   sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          echo "error: unknown option: $1" >&2; exit 2 ;;
    *)           if [ -z "$version" ]; then version="$1"; else echo "error: unexpected arg: $1" >&2; exit 2; fi; shift ;;
  esac
done

if [ -z "$version" ]; then
  echo "usage: $0 <version> [-o <output-path>] [--tag <tag>]" >&2
  exit 2
fi
[ -n "$tag" ] || tag="$version"

repo_root="$(git rev-parse --show-toplevel)"
src="$repo_root/rn/$version.md"
if [ ! -f "$src" ]; then
  echo "error: source notes not found: $src" >&2
  exit 1
fi

# Derive <owner>/<repo> from the origin remote (handles git@, https://, ssh://).
remote="$(git -C "$repo_root" remote get-url origin)"
slug="$(printf '%s' "$remote" | sed -E 's#^.*github\.com[:/]##; s#\.git$##; s#/$##')"
if [ -z "$slug" ]; then
  echo "error: could not derive owner/repo from origin remote: $remote" >&2
  exit 1
fi

[ -n "$out" ] || out="$repo_root/rn/release/$version-release.md"

# Rewrite markdown link targets that start with `../`:
#   directory links (target ends in `/`) -> tree/<tag>, file links -> blob/<tag>.
# Run the directory rule first; the file rule then can't re-match (no more `../`).
rewrite() {
  SLUG="$slug" TAG="$tag" perl -pe '
    s{\]\(\.\./([^)]*?)/\)}{](/$ENV{SLUG}/tree/$ENV{TAG}/$1)}g;
    s{\]\(\.\./([^)]+)\)}{](/$ENV{SLUG}/blob/$ENV{TAG}/$1)}g;
  ' "$src"
}

if [ "$out" = "-" ]; then
  rewrite
else
  mkdir -p "$(dirname "$out")"
  rewrite > "$out"
  printf '%s\n' "$out"
fi
