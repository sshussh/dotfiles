#!/usr/bin/env bash
# Prepare (but do not push) a rewritten mirror. Force-pushing is a separate,
# destructive operation requiring an explicit human decision.
set -euo pipefail
repo=${1:?usage: $0 /path/to/repo [output-mirror]}
out=${2:-${repo}-history-scrubbed}
[[ -d "$repo/.git" ]] || { echo "not a git repository: $repo" >&2; exit 2; }
command -v git-filter-repo >/dev/null || { echo "install git-filter-repo first" >&2; exit 1; }
git clone --mirror "$repo" "$out"
git -C "$out" filter-repo --force --path-glob '**/.zsh_history' --path-glob '**/.zcompdump*' --invert-paths
echo "Created scrubbed mirror at $out. Review it; no remote was changed."
