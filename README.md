# Dotfiles

Personal Linux desktop configuration managed with GNU Stow.

## Install

From this directory, link the active packages into your home directory:

```sh
stow --target="$HOME" ghostty niri noctalia zed zsh
```

To remove those links:

```sh
stow --delete --target="$HOME" ghostty niri noctalia zed zsh
```

## GNOME settings

GNOME settings are intentionally not managed by Stow. The snapshot contains
functional settings only; themes, fonts, icons, backgrounds, dock, and blur
settings are excluded.

```sh
./gnome/.config/gnome/load    # apply the saved snapshot
./gnome/.config/gnome/export  # refresh it from the current session
```
