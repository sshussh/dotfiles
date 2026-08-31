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
  vscodium
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
  # Generated DMS files must be real files. Older revisions tracked two of
  # them, so detach any stale Stow links before the generator writes again.
  for generated_path in \
    "$target_dir/.config/ghostty/themes/dankcolors" \
    "$target_dir/.config/zed/themes/dank-zed-theme.json"; do
    if [[ -L "$generated_path" ]]; then
      link_target="$(readlink "$generated_path")"
      if [[ "$link_target" = /* ]]; then
        resolved_target="$(realpath -m "$link_target")"
      else
        resolved_target="$(realpath -m "$(dirname "$generated_path")/$link_target")"
      fi
      if [[ "$resolved_target" == "$repo_dir"/* ]]; then
        preserved_path="${generated_path}.dms-migrate.$$"
        if [[ -f "$generated_path" ]]; then
          cp -L -- "$generated_path" "$preserved_path"
        fi
        unlink "$generated_path"
        if [[ -f "$preserved_path" ]]; then
          mv -- "$preserved_path" "$generated_path"
        fi
      fi
    fi
  done

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

# DMS owns GTK's generated imports. Drop the obsolete pre-DMS import once so
# GTK4 does not parse two complete wallpaper palettes on every application start.
gtk4_css="$target_dir/.config/gtk-4.0/gtk.css"
if [[ -f "$gtk4_css" && ! -L "$gtk4_css" ]]; then
  sed -i \
    -e '/Matugen owns only the imported file/d' \
    -e '/@import url("matugen\.css");/d' \
    "$gtk4_css"
fi

if [ "$target_dir" != "$HOME" ]; then
  exit 0
fi

dms_vscode_vsix="/usr/share/quickshell/dms/matugen/dms-theme.vsix"
if command -v codium >/dev/null 2>&1 && [[ -f "$dms_vscode_vsix" ]]; then
  echo "Installing the bundled DMS dynamic theme for VSCodium..."
  if ! codium --install-extension "$dms_vscode_vsix" --force; then
    echo "install.sh: VSCodium's DMS theme extension could not be installed" >&2
  fi
fi

if command -v systemctl >/dev/null 2>&1 && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  systemctl --user daemon-reload
  systemctl --user enable matugen-wallpaper.service >/dev/null
fi

if [ "$skip_dconf" != "1" ]; then
  "$repo_dir/scripts/load-gnome"
fi

"$repo_dir/scripts/setup-gnome-extensions" || true

if command -v zen-browser >/dev/null 2>&1 || [[ -f /usr/share/applications/zen.desktop ]]; then
  echo "Setting Zen as the default web browser..."
  xdg-settings set default-web-browser zen.desktop 2>/dev/null || true
  xdg-mime default zen.desktop x-scheme-handler/http 2>/dev/null || true
  xdg-mime default zen.desktop x-scheme-handler/https 2>/dev/null || true
  xdg-mime default zen.desktop text/html 2>/dev/null || true
else
  echo "install.sh: Zen Browser is not installed; skipped default-browser change" >&2
fi

if command -v zsh >/dev/null 2>&1; then
  zsh_path="$(command -v zsh)"
  current_shell="$(getent passwd "${USER:-$(id -un)}" | cut -d: -f7 || true)"
  if [[ -n "$zsh_path" && "$current_shell" != "$zsh_path" && "$current_shell" != /bin/zsh && "$current_shell" != /usr/bin/zsh ]]; then
    echo "Setting the login shell to zsh ($zsh_path)..."
    if chsh -s "$zsh_path"; then
      echo "Login shell is now zsh. Open a new terminal for it to take effect."
    else
      echo "install.sh: chsh failed. Run: chsh -s $zsh_path" >&2
    fi
  fi
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
