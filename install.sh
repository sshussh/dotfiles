#!/usr/bin/env bash
# Compatibility wrapper; new automation should invoke ./dotfiles directly.
set -euo pipefail
repo=$(CDPATH= cd -- "$(dirname "$0")" && pwd -P)

args=()
for argument in "$@"; do
  case "$argument" in
    -n|--no|--simulate) args+=(--dry-run) ;;
    --skip-deps) args+=(--skip-packages) ;;
    --skip-dconf|--skip-matugen) args+=(--skip-state) ;;
    --force|--replace-existing|--adopt)
      echo "install.sh: $argument is intentionally unsupported; resolve conflicts explicitly" >&2
      exit 2
      ;;
    -y|--yes)
      echo "install.sh: unattended package confirmation is intentionally unsupported" >&2
      exit 2
      ;;
    *) args+=("$argument") ;;
  esac
done

exec "$repo/dotfiles" apply --profile "${DOTFILES_PROFILE:-workstation}" "${args[@]}"
