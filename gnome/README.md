# GNOME settings

Portable GNOME Shell 50 settings for reproducing this desktop on another
machine. This is a sanitized `dconf` snapshot, not the binary
`~/.config/dconf/user` database.

## What is included

- appearance: dark mode, accent, fonts, icon theme, user theme
- input: US + Arabic layouts, mouse, touchpad, numlock
- window manager: 4 fixed workspaces, Super+1..4, Super+q, tiling
- Nautilus, Papers, power, night light, privacy, break reminders
- app folders, favorite apps, Dash to Dock, Blur my Shell
- GTK file chooser defaults, Blanket, AdwSteamGtk, Mission Center

## What is excluded

Wallpaper file URIs, window sizes, file-chooser last paths, command
history, NetworkManager EAP entries, remote-desktop certificate paths,
night-light GPS coordinates, monitor serials, software timestamps, and
Hanabi live-wallpaper paths. Those are machine-local or credential-adjacent.

The current wallpaper is applied by the `matugen` package, not by this
dump.

## Reproduce on a new machine

1. Install GNOME, GNU Stow, `dconf`, JetBrains Mono, and
   JetBrainsMono Nerd Font.
2. Install the **enabled** extensions listed in `extensions.txt`.
3. From the repo root:

   ```sh
   ./install.sh
   ```

   That stows the packages and loads these dconf files. To load settings
   only:

   ```sh
   ./scripts/load-gnome
   ```

4. Log out and back in so GNOME Shell reloads extensions and keybindings.
5. Generate the theme from a wallpaper:

   ```sh
   matugen-wallpaper /path/to/wallpaper.jpg
   ```

## Refresh the export

On the source machine, after changing GNOME settings:

```sh
./scripts/export-gnome
```

Review the diff, then commit. Do not check in `~/.config/dconf/user`.
