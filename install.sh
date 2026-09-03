#!/usr/bin/env bash
# Stow every package directory onto $HOME (or $STOW_TARGET).
set -euo pipefail

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
target=${STOW_TARGET:-$HOME}

if ! command -v stow >/dev/null 2>&1; then
  echo "install.sh: GNU Stow is required" >&2
  exit 1
fi

simulate=()
case "${1:-}" in
  "" ) ;;
  -n|--simulate|--dry-run) simulate=(--simulate) ;;
  -h|--help)
    echo "usage: $0 [--simulate]"
    echo "  STOW_TARGET=/path  install into a different home"
    exit 0
    ;;
  *)
    echo "usage: $0 [--simulate]" >&2
    exit 2
    ;;
esac

is_stow_package() {
  local dir=$1 name
  [[ -d "$dir/.config" || -d "$dir/.local" ]] && return 0
  for name in "$dir"/.[!.]* "$dir"/..?*; do
    [[ -e "$name" ]] || continue
    [[ $(basename -- "$name") == .stow-local-ignore ]] && continue
    return 0
  done
  return 1
}

packages=()
for dir in "$repo"/*/; do
  name=$(basename -- "$dir")
  [[ "$name" == __pycache__ ]] && continue
  is_stow_package "$dir" || continue
  packages+=("$name")
done

if ((${#packages[@]} == 0)); then
  echo "install.sh: no Stow packages found" >&2
  exit 1
fi

cd -- "$repo"
mkdir -p -- "$target"
stow --dir="$repo" --target="$target" --no-folding --restow "${simulate[@]}" "${packages[@]}"
echo "stowed: ${packages[*]}"
