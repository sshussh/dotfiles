#!/usr/bin/env bash
# Deploy these packages into $HOME with GNU Stow, then restore GNOME settings.
set -euo pipefail

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
target_dir="${DOTFILES_TARGET:-$HOME}"
cd "$repo_dir"

packages=(
  gnome-desktop
  matugen
  terminal
  zed
  hardware
  zsh-bootstrap
)

simulate=0
force=0
yes=0
skip_deps=0
skip_dconf="${GNOME_SKIP_DCONF:-0}"
skip_matugen="${MATUGEN_SKIP_GENERATE:-0}"
stow_args=()

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Deploy GNU Stow packages from this repository into \$DOTFILES_TARGET (default: \$HOME).

Options:
  -n, --simulate, --no   Dry run; print Stow actions and exit
  --force                Replace conflicting regular files/symlinks with Stow links
  -y, --yes              Install missing packages without asking
  --skip-deps            Skip the dependency check
  --skip-dconf           Do not load gnome/dconf snapshots
  --skip-matugen         Do not generate a palette after stowing
  -h, --help             Show this help

Environment:
  DOTFILES_TARGET        Install destination (default: \$HOME)
  GNOME_SKIP_DCONF=1     Same as --skip-dconf
  MATUGEN_SKIP_GENERATE=1  Same as --skip-matugen
EOF
}

for arg in "$@"; do
  case "$arg" in
    -n|--no|--simulate)
      simulate=1
      stow_args+=(--simulate)
      ;;
    --force|--replace-existing)
      force=1
      ;;
    -y|--yes)
      yes=1
      ;;
    --skip-deps)
      skip_deps=1
      ;;
    --skip-dconf)
      skip_dconf=1
      ;;
    --skip-matugen)
      skip_matugen=1
      ;;
    --adopt)
      echo "install.sh: refusing --adopt (it can pull machine-local data into the repo)" >&2
      exit 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "install.sh: unknown option: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if (( ! skip_deps )); then
  deps_args=()
  (( simulate )) && deps_args+=(--report-only)
  (( yes )) && deps_args+=(--yes)
  [[ "$skip_dconf" == 1 ]] && deps_args+=(--skip-dconf)
  [[ "$skip_matugen" == 1 ]] && deps_args+=(--skip-matugen)
  "$repo_dir/scripts/check-deps" "${deps_args[@]}"
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "install.sh: GNU Stow is not installed" >&2
  exit 1
fi

backup_dir=""
if (( ! simulate )); then
  # Directory-level folds (a symlink at OpenRGB/, matugen/, fish/functions/, ...)
  # make Stow report "existing target is not owned by stow" and abort. Turn
  # those into real directories before linking files with --no-folding.
  python3 "$repo_dir/scripts/replace-existing" \
    --unfold-only \
    --target "$target_dir" \
    --repo "$repo_dir" \
    "${packages[@]}"
fi

if (( force )) && (( ! simulate )); then
  backup_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-stow-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  echo "Backing up conflicting paths to $backup_dir"
  python3 "$repo_dir/scripts/replace-existing" \
    --target "$target_dir" \
    --repo "$repo_dir" \
    --backup "$backup_dir" \
    "${packages[@]}"
fi

# --force already removed stale targets, so stow (do not restow/unstow).
# --restow is for a later git-pull update of an already-linked tree.
stow_mode=(--restow)
if (( force )); then
  stow_mode=()
fi

if ! stow --dir="$repo_dir" --target="$target_dir" --no-folding \
  --ignore='__pycache__' --ignore='\.pyc$' \
  "${stow_mode[@]}" "${stow_args[@]}" "${packages[@]}"; then
  echo "install.sh: GNU Stow aborted" >&2
  if [[ -n "$backup_dir" ]]; then
    echo "install.sh: restoring files from $backup_dir" >&2
    python3 "$repo_dir/scripts/replace-existing" \
      --restore "$backup_dir" \
      --target "$target_dir"
  fi
  exit 1
fi

ensure_xdg_links() {
  local target="$1"
  mkdir -p \
    "$target/.local/bin" \
    "$target/.local/share/applications" \
    "$target/.local/share/themes" \
    "$target/.local/share/icons"
  # Relative to the link location so they keep working if $HOME is renamed.
  ln -sfn ../../.config/matugen/bin/matugen-wallpaper \
    "$target/.local/bin/matugen-wallpaper"
  ln -sfn ../../.config/matugen/bin/matugen-helium-browser \
    "$target/.local/bin/matugen-helium-browser"
  ln -sfn ../../../.config/matugen/runtime/applications/helium.desktop \
    "$target/.local/share/applications/helium.desktop"
  ln -sfn ../../../.config/matugen/runtime/themes/Matugen \
    "$target/.local/share/themes/Matugen"
  ln -sfn ../../../.config/matugen/runtime/icons/Matugen \
    "$target/.local/share/icons/Matugen"
}

if (( simulate )); then
  exit 0
fi

ensure_xdg_links "$target_dir"

if [ "$target_dir" != "$HOME" ]; then
  exit 0
fi

if command -v systemctl >/dev/null 2>&1 && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  systemctl --user daemon-reload
  systemctl --user enable matugen-wallpaper.service >/dev/null
fi

if [ "$skip_dconf" != "1" ]; then
  "$repo_dir/scripts/load-gnome"
fi

if [ "$skip_matugen" != "1" ]; then
  if command -v matugen-wallpaper >/dev/null 2>&1; then
    if ! matugen-wallpaper; then
      echo "install.sh: stow succeeded, but the first Matugen run failed." >&2
      echo "install.sh: set a wallpaper, then run: matugen-wallpaper" >&2
    fi
  else
    echo "install.sh: matugen-wallpaper is not on PATH yet; skip palette generation" >&2
  fi
fi
