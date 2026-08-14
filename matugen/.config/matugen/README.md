# Wallpaper color synchronization

`matugen-wallpaper.service` watches GNOME's light and dark wallpaper keys and
regenerates a Material palette after each change. It also follows GNOME's
light/dark appearance mode. If the Hanabi live-wallpaper extension is enabled,
the watcher extracts a representative video frame with FFmpeg.

Integrated targets:

- GNOME Shell 50 and GNOME's nearest native accent color
- GTK 3, GTK 4, libadwaita, and Qt applications using the GTK platform theme
- Nautilus folder, XDG user-directory, home, desktop, and bookmark icons through
  a small Matugen icon theme that inherits every other icon from Adwaita
- Ghostty, including live config reload
- Zed, with dedicated light and dark themes
- btop, including live theme reload
- Fastfetch, with a generated true-color logo and output palette
- Helium Browser's native Chromium custom theme, applied safely before launch
- Steam through AdwSteamGtk custom CSS; Steam may need a natural restart

The generated outputs are written to `.new` files, validated, and renamed over
their final paths atomically. Existing Ghostty, Zed, and btop configuration was
backed up before their single theme-selection lines were changed.

## Layout

All Matugen-owned configuration, templates, generated GNOME theme/icon assets,
launch helpers, and the Helium launcher source live below `~/.config/matugen`.
GNOME and the desktop specification require their discovery paths under
`~/.local/share`, and the shell/service require helper commands on
`~/.local/bin`; those locations are symlinks to the files in this directory.
The Matugen executable itself remains on `~/.local/bin` and transient palette
state remains under `~/.cache/matugen` by design.

Useful commands:

```sh
matugen-wallpaper                    # apply the current GNOME wallpaper now
matugen-wallpaper /path/to/image     # one-shot palette from another image
matugen-wallpaper --status           # show the last successful source/palette
systemctl --user status matugen-wallpaper.service
journalctl --user -u matugen-wallpaper.service -f
```

The default scheme is `scheme-tonal-spot`. For an experimental one-shot palette:

```sh
MATUGEN_SCHEME=scheme-vibrant matugen-wallpaper /path/to/image
```

For a persistent alternative, add `Environment=MATUGEN_SCHEME=scheme-vibrant`
with `systemctl --user edit matugen-wallpaper.service`, then restart the service.

To pause automatic updates without deleting anything:

```sh
systemctl --user disable --now matugen-wallpaper.service
```

Timestamped originals are under `~/.config/matugen/backups/`. A full rollback
also restores the Adwaita icon theme, sets the User Themes name back to empty,
and turns off AdwSteamGtk custom CSS:

```sh
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.shell.extensions.user-theme name ''
gsettings set io.github.Foldex.AdwSteamGtk prefs-install-custom-css false
```

GTK monitors the active icon theme for content changes, so open Nautilus windows
should refresh when a wallpaper produces new SVGs. If one window keeps a stale
folder icon, close and reopen Nautilus once; the watcher never quits it
automatically because that would close active tabs and file-operation windows.

Helium's browser chrome follows Matugen's source color through its native
Chromium custom-theme setting. The watcher updates it while Helium is closed;
the user-local Helium launcher also applies the latest palette just before a
new browser start. An already-open Helium window is never rewritten or killed.
