# Hyprland Configuration

Personal Hyprland setup with a **Cyberpunk Dystopia** theme - blood red borders, harsh animations, industrial aesthetics.

## Files

| File | Description |
|------|-------------|
| `hyprland.conf` | Main config - monitors, keybinds, theme, window rules |
| `hyprlock.conf` | Lock screen config with fingerprint support |
| `hypridle.conf` | Idle behavior - dim, lock, DPMS, suspend timers |
| `mocha.conf` | Catppuccin Mocha color palette |
| `scripts/launch.sh` | Waybar reload script |

## Theme: Cyberpunk Dystopia

- **Colors**: Blood red (`#ff0000`) to crimson (`#8b0000`) borders
- **Borders**: 3px thick, sharp corners (0 rounding)
- **Gaps**: Minimal (2px inner, 4px outer) for claustrophobic feel
- **Shadows**: Dark red with offset
- **Blur**: Enabled with haze/smog effect
- **Animations**: Harsh, mechanical, glitch-like
- **Inactive windows**: Dimmed to 75% opacity

## Default Applications

| Keybind | Application |
|---------|-------------|
| `SUPER + Return` | kitty (terminal) |
| `SUPER + Space` | wofi (launcher) |
| `SUPER + E` | nautilus (files) |
| `SUPER + B` | zen-browser |
| `SUPER + C` | zeditor |
| `SUPER + M` | spotify-launcher |

## Key Bindings

### Window Management
- `SUPER + W` - Kill active window
- `SUPER + V` - Toggle floating
- `SUPER + F` - Fullscreen
- `SUPER + J` - Toggle split
- `SUPER + P` - Pseudo-tile
- `SUPER + Arrow keys` - Move focus

### Workspaces
- `SUPER + 1-0` - Switch workspace
- `SUPER + SHIFT + 1-0` - Move window to workspace
- `SUPER + S` - Toggle scratchpad
- `SUPER + SHIFT + S` - Move to scratchpad

### System
- `SUPER + L` - Lock screen
- `SUPER + SHIFT + L` - Exit Hyprland
- `SUPER + R` - Reload waybar
- `Print` - Screenshot (region)

### Window Resize
- `SUPER + =/-` - Resize width
- `SUPER + SHIFT + =/-` - Resize height
- `SUPER + LMB` - Move window
- `SUPER + RMB` - Resize window

## Idle Timeouts

| Timeout | Action |
|---------|--------|
| 5 min | Dim screen to 10% |
| 10 min | Lock screen |
| 15 min | Turn off display |
| 15 min | Suspend system |

## Autostart Services

- hyprpanel
- hyprpolkitagent
- waypaper (wallpaper restore)
- hypridle
- nm-applet
- blueman-applet

## Dependencies

- hyprland, hyprlock, hypridle, hyprpanel
- waybar, wofi, waypaper
- kitty, nautilus, zen-browser, zeditor
- brightnessctl, playerctl, wpctl
- hyprshot (screenshots)

## Resources

- [Hyprland Wiki](https://wiki.hypr.land)
- [Hyprlock Docs](https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock)
