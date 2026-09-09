# Niri DMS config backup — 2026-09-07

Snapshot of `~/.config/niri/dms/` (DankMaterialShell-generated niri fragments)
taken just before DMS was removed and the shell switched to Noctalia.

These files are archival only. They are NOT stowed and NOT included by niri.

Contents:
- `binds.kdl`      — DMS `dms ipc call` keybinds (remapped to `noctalia msg` in niri/binds.kdl)
- `colors.kdl`     — DMS Matugen colours for niri focus-ring/border
- `layout.kdl`     — gaps 4, border width 1, focus-ring width 1, window corner-radius 15
- `outputs.kdl`    — HDMI-A-1 1920x1080@200 scale 1 (folded into niri/config.kdl)
- `windowrules.kdl`— user window rules (steam_app_8500, Nautilus, pavucontrol, zen)
- `input.kdl` / `cursor.kdl` / `alttab.kdl` / `wpblur.kdl` — redundant with portable.kdl/config.kdl
- `dms-session.json.reference` — DMS runtime state (wallpaper path, weather location,
  pinned apps, GPU PCI id). Kept for reference only; not used by Noctalia.
