# Dotfiles

This repository uses GNU Stow with `--no-folding`. Each package mirrors the
path it should occupy under `$HOME`, so `~/.config/ghostty/config` is stored as
`terminal/.config/ghostty/config`. Stow creates those parent directories as
real directories and links only the files this repo owns. Application-generated
files next to them (GTK bookmarks, OpenRGB logs, Matugen palettes) stay on the
machine and out of git.

```sh
git clone git@github.com:sshussh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`./install.sh` restows the packages below, enables `matugen-wallpaper.service`,
loads the sanitized GNOME dconf snapshot, and generates a palette from the
current wallpaper.

On a machine that already has regular files at these paths, preview first:

```sh
./install.sh --simulate
```

Then replace the conflicting files with Stow links (a timestamped copy is
written under `~/.cache/dotfiles-stow-backup-*`). `--force` skips paths that
are already the packaged file, unfolds leftover directory-level Stow folds,
and restores the backup if Stow aborts:

```sh
./install.sh --force
```

Do **not** use Stow `--adopt`. Adoption copies whatever is already on the
machine into this public repository, including SSH metadata and generated
palettes.

## Packages

| Package | Deploys |
| --- | --- |
| `zsh-bootstrap` | `~/.zshenv`, which sets `ZDOTDIR` so the rest of zsh lives under `~/.config/zsh` |
| `gnome-desktop` | GTK CSS wrappers, desktop associations, user directories, autostart, pavucontrol, session PATH, and the Matugen user service |
| `matugen` | Matugen configuration and templates, helper commands, and XDG discovery links for the generated theme/icons/Helium launcher |
| `terminal` | Fish, Zsh, Ghostty, btop, Neovim |
| `zed` | Zed settings, keymap, tasks, and the static Dank theme |
| `hardware` | OpenRGB profiles and Qt preference files |

`~/.zshenv` comes from `zsh-bootstrap`. After stowing, `install.sh` also
creates relative discovery links (not Stow links) so GNOME can find generated
assets without folding those directories into git:

- `~/.local/bin/matugen-wallpaper` and `matugen-helium-browser`
- `~/.local/share/themes/Matugen`, `icons/Matugen`, and `applications/helium.desktop`

Those point at `~/.config/matugen/...`, where Stow-managed sources sit next to
Matugen-generated palettes.

Generated palettes (GTK `matugen.css`, Ghostty/Zed/btop/fastfetch/Spicetify
themes, folder SVGs, GNOME Shell CSS) are **not** versioned. `matugen-wallpaper`
creates them as regular files after install.

## GNOME settings

GNOME is reproduced from a sanitized `dconf` snapshot in `gnome/dconf/`, not
from the binary `~/.config/dconf/user` database. `./install.sh` loads it after
stowing. See `gnome/README.md` for the restore steps, extension list, and how
to refresh the export.

Monitor layout is machine-local (`~/.config/monitors.xml`) and is not stowed.

## Intentional exclusions

This is a public, credential-free configuration repository. It excludes browser
profiles, Discord, mail clients, Codex state, the binary dconf user database,
connection databases, credentials, history files, caches, logs, backups,
generated menus, nested Git metadata, machine-session data, Zed SSH hosts, and
wallpaper-derived palettes. The GNOME dump also strips wallpaper URIs, window
sizes, file-chooser last paths, NetworkManager EAP entries, remote-desktop
certificate paths, and location coordinates.
