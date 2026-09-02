# GNOME portable state

The files under `gnome/dconf/` are sanitized text exports for GNOME Shell 50,
not the binary `~/.config/dconf/user` database. Restore is additive: `dconf
load` updates keys present in the snapshot and leaves unrelated keys on the
target machine intact. It is therefore a portable baseline, not a destructive
factory reset.

## Included

- portable appearance settings, fonts, input sources, keyboard shortcuts, and
  workspace/window rules;
- Nautilus, Papers, power, privacy, break reminders, and file chooser defaults;
- curated favorites and extension settings for the enabled extension set;
- a committed wallpaper at
  `~/.local/share/backgrounds/dotfiles-wallpaper.jpg`, followed by DMS/Matugen
  palette generation.

The desired enabled extensions are listed in `extensions.txt` and installed by
the official/AUR package manifests. The restore helper refuses an absent
extension instead of downloading an unpinned bundle. GameMode and unrelated
installed extensions are not part of the baseline.

## Excluded or overridden for safety

- wallpaper source URIs from the machine, monitor serials, window sizes, and
  file chooser/history paths;
- the GNOME accent and legacy GTK theme override, which DMS/Matugen manages
  after restore; the portable dark/light preference and generated icon/Shell
  theme remain reproducible;
- app folders and stale game/media/chat application lists;
- disabled-extension inventory, removed-extension settings, unavailable search
  providers, hardware sensor IDs, and applicationless monitor commands;
- world-clock coordinates and system location state;
- NetworkManager EAP and remote-desktop certificate paths;
- passwordless file sharing and disabled screen locking.

Apply explicitly enables locking, sets a five-minute idle timeout with immediate
lock after blanking, requires a file-sharing password, and points GNOME at the
committed wallpaper.

## Restore

The normal profile apply invokes the handler automatically. To restore only
GNOME state:

```sh
./state/gnome/apply
```

This loads non-empty dconf fragments, installs/enables the desired extensions,
sets the safe overrides and wallpaper, and generates the palette. Log out of
GNOME and back in after extension changes.

## Capture safely

First inspect without writing:

```sh
./scripts/export-gnome --check
```

Then capture only when the proposed drift is intentional:

```sh
./scripts/export-gnome
git diff -- gnome/
```

When `gnome-extensions` cannot contact a running Shell, the exporter falls back
to the dconf-backed `gsettings` value. If neither source is trustworthy, it
aborts before touching the tracked snapshot. It never silently converts an
extension failure into an empty enabled list. All candidate files are staged
and flushed before any tracked snapshot file is replaced, and keys are emitted
in canonical order so capture/apply/capture is stable.
