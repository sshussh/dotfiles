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

backup_root=
clear_regular_conflicts() {
  local package=$1 source dest rel
  while IFS= read -r -d '' source; do
    rel=${source#"$repo/$package/"}
    dest=$target/$rel
    [[ -e "$dest" || -L "$dest" ]] || continue
    [[ -L "$dest" || -d "$dest" ]] && continue
    [[ -f "$dest" ]] || {
      echo "install.sh: refusing to replace $dest" >&2
      return 1
    }
    if cmp -s -- "$source" "$dest"; then
      echo "replace identical $dest"
    else
      if [[ -z "$backup_root" ]]; then
        backup_root=$target/.cache/dotfiles-backup/$(date +%Y%m%d-%H%M%S)
      fi
      if ((${#simulate[@]})); then
        echo "would backup $dest -> $backup_root/$rel"
      else
        mkdir -p -- "$backup_root/$(dirname -- "$rel")"
        cp -a -- "$dest" "$backup_root/$rel"
        echo "backed up $dest -> $backup_root/$rel"
      fi
    fi
    if ((${#simulate[@]})); then
      echo "would remove $dest"
    else
      rm -f -- "$dest"
    fi
  done < <(find "$repo/$package" -type f \
    ! -name .stow-local-ignore \
    ! -name .gitignore \
    ! -name .gitattributes \
    ! -path '*/__pycache__/*' \
    ! -name '*.pyc' \
    -print0)
}

cd -- "$repo"
mkdir -p -- "$target"
for package in "${packages[@]}"; do
  clear_regular_conflicts "$package"
done
stow --dir="$repo" --target="$target" --no-folding --restow "${simulate[@]}" "${packages[@]}"
echo "stowed: ${packages[*]}"
[[ -n "$backup_root" ]] && echo "previous files: $backup_root"
