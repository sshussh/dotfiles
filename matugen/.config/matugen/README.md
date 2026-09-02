# Wallpaper color synchronization

`matugen-wallpaper.service` watches GNOME's light and dark wallpaper keys and
regenerates a Material palette after each change. It follows the GNOME
light/dark preference and, when the optional Hanabi extension is active,
extracts a representative video frame with FFmpeg.

The current integration covers:

- GNOME's nearest native accent and the Stow-managed `Matugen` Shell/icon
  themes;
- GTK 3/4 and the DMS-generated application targets detected by `dms matugen`;
- Nautilus folder, XDG directory, home, desktop, and bookmark icons while
  inheriting all other icons from Adwaita;
- Ghostty, Kitty, Zed, Neovim, btop, Fastfetch, Oh My Posh, and the Zsh palette;
- Zen Browser's profile-local `userChrome.css` loader when a Zen profile exists.

Helium, Steam/AdwSteamGtk, Spotify/Spicetify, credentials, and browser profile
data are not managed. Old helpers and templates for those integrations were
removed so a palette update cannot rewrite unrelated application state.

## Ownership and generated files

The controller, templates, and stable theme/icon discovery files are installed
by GNU Stow from this package. Generated palettes stay outside Git under
`~/.cache/matugen`, application config directories, and
`~/.config/DankMaterialShell`. The stable executable and discovery links are:

```text
~/.local/bin/matugen-wallpaper
~/.local/share/icons/Matugen/index.theme
~/.local/share/themes/Matugen/index.theme
```

Generation uses temporary files, validates each recognized output, and then
renames it over the destination. The committed GNOME wallpaper is restored
before the first generation on a new system.

## Commands

```sh
matugen-wallpaper                    # apply the current GNOME wallpaper
matugen-wallpaper /path/to/image     # one-shot palette from another image
matugen-wallpaper --status           # show the last successful palette
systemctl --user status matugen-wallpaper.service
journalctl --user -u matugen-wallpaper.service -f
```

For an experimental one-shot scheme:

```sh
MATUGEN_SCHEME=scheme-vibrant matugen-wallpaper /path/to/image
```

For a persistent alternative, add the same environment setting with
`systemctl --user edit matugen-wallpaper.service`, then restart the service.
To pause automatic updates:

```sh
systemctl --user disable --now matugen-wallpaper.service
```

To return GNOME to its inherited icon and Shell themes:

```sh
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.shell.extensions.user-theme name ''
```

Zen receives `~/.config/DankMaterialShell/zen.css` as
`chrome/dank-colors.css`; one managed import is added to `userChrome.css` and
the supported custom-stylesheet preference is enabled in `user.js`. Zen must
reload its UI stylesheet, normally by restarting, to display a new palette.
