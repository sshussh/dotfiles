# Dotfiles

This repository uses GNU Stow. Every package is rooted at `.config`, so the
default deployment target is the home directory only to reach `~/.config`.
It does not put application configuration files directly in `$HOME`.

```sh
git clone git@github.com:sshussh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The only intentional links outside `~/.config` are in the `matugen` package:

- `~/.local/bin/matugen-wallpaper` and `matugen-helium-browser`, so the user
  service and desktop launcher can execute them;
- `~/.local/share/themes/Matugen`, `icons/Matugen`, and
  `applications/helium.desktop`, because GNOME discovers those assets through
  the XDG data directory.

## Packages

| Package | Deploys |
| --- | --- |
| `gnome-desktop` | GTK overrides, desktop associations, user directories, monitor layout, OpenRGB and Remmina autostart, pavucontrol, and the Matugen user service |
| `matugen` | Matugen configuration, templates, generated GNOME theme and Nautilus folder-icon assets, and required XDG discovery links |
| `terminal` | Fish, Zsh, Ghostty, btop, and Fastfetch |
| `zed` | Zed settings, keymap, tasks, and themes |
| `hardware` | OpenRGB profiles and Qt preference files |
| `steam` | AdwSteamGtk custom CSS |

## GNOME settings

GNOME is reproduced from a sanitized `dconf` snapshot in `gnome/dconf/`,
not from the binary `~/.config/dconf/user` database. `./install.sh` loads
it after stowing. See `gnome/README.md` for the restore steps, extension
list, and how to refresh the export.

## Intentional exclusions

This is a public, credential-free configuration repository. It excludes browser
profiles, Discord, mail clients, Codex state, the binary dconf user database,
connection databases, credentials, history files, caches, logs, backups,
generated menus, nested Git metadata, and machine-session data. No Btrfs
Assistant user configuration was present to include; `connections.db` was
excluded because it is an opaque database and may contain remote/session
information. The GNOME dump also strips wallpaper URIs, window sizes,
file-chooser last paths, NetworkManager EAP entries, remote-desktop
certificate paths, and location coordinates.

The live Nautilus configuration directory currently contains no regular user
preference files. Its Matugen folder-icon theme is included in the `matugen`
package instead.

## Adopting an existing machine

On a machine that already has regular files at these paths, review the dry run
first:

```sh
DOTFILES_TARGET="$HOME" ./install.sh --simulate
```

Do **not** use `--adopt` against this public repository: adoption can pull
intentionally excluded local-only data, such as saved SSH connection metadata,
back into the repository. Merge or back up existing conflicting settings
locally, then run `./install.sh`. GNU Stow links the managed paths into this
repository; it does not create loose application configuration files in
`$HOME`.
