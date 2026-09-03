# Dotfiles

GNU Stow packages for `$HOME`, plus sanitized GNOME dconf dumps.

```sh
sudo pacman -S --needed stow
git clone https://github.com/sshussh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` restows every top-level directory except `gnome/` onto `$HOME`
with `--no-folding`. Preview with `./install.sh --simulate`. Use
`STOW_TARGET=/path` to install into a different home.

## Add a config

Put files in this repo at the same path they should have under `$HOME`, then
stow:

```sh
mkdir -p zed/.config/zed
cp ~/.config/zed/settings.json zed/.config/zed/
./install.sh
```

A new top-level directory is a new package. `./install.sh` picks it up
automatically.

Existing regular files that match a package are replaced with links.
Differing files are copied to `~/.cache/dotfiles-backup/` first. Unexpected
symlinks still make Stow abort.

## GNOME

Dconf snapshots live under `gnome/dconf/` and are independent of Stow.

```sh
./gnome/export --check    # show drift without writing
./gnome/export            # capture, then git diff gnome/
./gnome/load              # restore onto this machine
```

Load is additive: keys in the snapshot are updated, other keys are left
alone. Install the extensions listed in `gnome/extensions.txt`, then log out
of GNOME.

## Packages

| Package | Contents |
| --- | --- |
| `zsh-bootstrap` | `~/.zshenv` so Zsh reads `~/.config/zsh` |
| `terminal` | Zsh, Fish, Ghostty, Kitty, Neovim, btop |
| `gnome-desktop` | Environment, OpenRGB autostart, user unit, wallpaper, MIME, pavucontrol, user-dirs |
| `matugen` | Templates and wallpaper helper |
| `niri` | Niri config and portable policy |
| `fontconfig` | Arabic font preference |
| `xresources` | Cursor defaults |
| `wireplumber` | Analog-only headset/speakers, NVIDIA HDMI disabled |
| `zed` | Editor settings, keymap, and tasks |
| `openrgb` | Device profiles |

Generated Matugen palettes, browser profiles, credentials, and shell history
are gitignored.
