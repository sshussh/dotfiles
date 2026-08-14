#!/usr/bin/env bash
# Deploy selected dotfiles into ~/.config (and Matugen's required ~/.local links).
set -euo pipefail

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
target_dir="${DOTFILES_TARGET:-$HOME}"
cd "$repo_dir"

stow --target="$target_dir" --restow "$@" \
  gnome-desktop \
  matugen \
  terminal \
  zed \
  hardware \
  steam

case " $* " in
  *" --simulate "*) ;;
  *)
    if [ "$target_dir" = "$HOME" ]; then
      systemctl --user daemon-reload
    fi
    ;;
esac
