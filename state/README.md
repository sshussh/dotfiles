# Portable state handlers

Stow is appropriate for static files. These handlers cover settings that need
an application-aware export or restore. `dotfiles audit` runs only the read-only
`audit` entry points; `dotfiles capture` is the explicit write operation.

| Handler | Audit | Apply | Capture |
| --- | --- | --- | --- |
| `login-shell` | Confirms the account resolves to `/usr/bin/zsh` | Uses `chsh` only when needed | Intentional no-op |
| `pre-commit` | Validates config and confirms this clone's hook | Installs the hook and its pinned environments | Intentional no-op |
| `mimeapps` | Confirms `mimeapps.list` is a regular file matching the snapshot | Atomically installs a regular file so desktop applications can replace it safely | Atomically captures the live default-application associations |
| `pavucontrol` | Confirms its preferences are a regular file matching the snapshot | Atomically installs a regular file safe for GLib replacement writes | Atomically captures the live preferences |
| `user-dirs` | Confirms both XDG user-directory files are regular and match | Atomically installs both files and creates their declared directories | Atomically captures both live files |
| `gnome` | Verifies the sanitized round trip, safety keys, and wallpaper | Additively loads sanitized dconf, requires package-owned extensions, enforces idle lock/passworded sharing, sets the committed wallpaper, regenerates the palette | Atomically stages sanitized dconf and extensions; refuses an unknown enabled-extension state |
| `dms` | Reports whether DMS is installed | Leaves session-owned preferences manual | Intentional no-op |
| `niri` | Validates a regular entrypoint plus the Stow-owned portable policy | Atomically installs the regular DMS-safe entrypoint | Intentional no-op; DMS fragments and output state remain machine-local |
| `vscodium` | Compares exact extension versions | Installs every `publisher.name@version` entry | Captures versions through a non-empty temporary file, then atomically replaces the manifest |
| `zed` | Compares installed extension names | Prints the manual extension-manager requirement | Captures names through a non-empty temporary file, then atomically replaces the manifest |
| `openrgb` | Confirms every reviewed data file is regular and matches | Atomically installs ordinary files safe for application rewrites | Atomically captures all data; hardware identifiers require review |

State handlers run only for the real home target. Setting `DOTFILES_TARGET` to
an isolated directory automatically suppresses them; `--skip-state` suppresses
them explicitly.

Capture is not an automatic commit. Always inspect `git diff`, especially for
application-generated IDs, paths, coordinates, or newly introduced extension
metadata. GNOME's `--check` path is non-writing:

```sh
./scripts/export-gnome --check
```

DMS `settings.json`, generated Niri includes, monitor/output layout, browser
profiles, application logins, and credentials are deliberately manual. The
controller separately audits/installs six full-commit Zsh Git sources.

OpenRGB's detector registry and binary profiles are ordinary runtime files and
can contain exact device identifiers. Capture explicitly and review their diffs
before publishing.
The current user-authored autostart entry enables the SDK server on OpenRGB's
default all-interface address; restrict it to loopback or enforce UFW port 6742
rules if remote SDK clients are not intended.

Application-owned mutable files are deliberately not Stow links. GLib-based
writers may replace them atomically, while other applications rewrite them in
place; either behavior can break a link or silently modify the repository.
This boundary covers `mimeapps.list`, pavucontrol, XDG user directories, the
Niri entrypoint DMS edits, and OpenRGB data. Use `dotfiles capture` after an
intentional change, inspect the diff, and commit the updated snapshot.
