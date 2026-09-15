# GNOME settings

Sanitized, functionality-only text dumps for GNOME Shell—not the binary
`~/.config/dconf/user` database. Appearance settings (themes, fonts, icons,
cursors, backgrounds, dock/blur configuration, and visual extension settings)
are intentionally excluded. The exact functional keys that may be exported are
allowlisted in `export`; add its section prefix and key there only when you
want to preserve it.
Restore is additive: `dconf load` updates keys in the snapshot and leaves
unrelated keys intact.

```sh
./gnome/export --check
./gnome/export
git diff -- gnome/
./gnome/load
```

`export` drops location, certificates, window sizes, hardware sensor IDs,
runtime palette values, and similar machine-local keys. It also records
enabled extensions in `extensions.txt`.

Install those extensions yourself, load the dump, then log out of GNOME so
the shell picks them up. `./install.sh` does not load dconf.
