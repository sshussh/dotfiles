# Portable state handlers

Stow is appropriate for static files. These handlers cover settings that need
an application-aware export or restore. `dotfiles audit` runs only the read-only
`audit` entry points; `dotfiles capture` is the explicit write operation.

| Handler | Audit | Apply | Capture |
| --- | --- | --- | --- |
| `login-shell` | Confirms the account resolves to `/usr/bin/zsh` | Uses `chsh` only when needed | Intentional no-op |
| `pre-commit` | Validates config and confirms this clone's hook | Installs the hook and its pinned environments | Intentional no-op |
| `gnome` | Verifies the sanitized round trip, safety keys, and wallpaper | Additively loads sanitized dconf, requires package-owned extensions, enforces idle lock/passworded sharing, sets the committed wallpaper, regenerates the palette | Atomically stages sanitized dconf and extensions; refuses an unknown enabled-extension state |
| `dms` | Reports whether DMS is installed | Leaves session-owned preferences manual | Intentional no-op |
| `niri` | Verifies `config.kdl` is linked to the Stow package | Static config is already handled by Stow | Runtime/output state remains machine-local |
| `vscodium` | Compares exact extension versions | Installs every `publisher.name@version` entry | Captures versions through a non-empty temporary file, then atomically replaces the manifest |
| `zed` | Compares installed extension names | Prints the manual extension-manager requirement | Captures names through a non-empty temporary file, then atomically replaces the manifest |
| `openrgb` | Verifies the primary profile is Stow-owned | Reports that direct Stow links are already active | Intentional no-op; detector/profile changes must be reviewed directly |

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

OpenRGB's detector registry and binary profiles are direct, mutable Stow links
and can contain exact device identifiers. Review their diffs before publishing.
The current user-authored autostart entry enables the SDK server on OpenRGB's
default all-interface address; restrict it to loopback or enforce UFW port 6742
rules if remote SDK clients are not intended.
