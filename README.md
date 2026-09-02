# Reproducible Arch workstation

This repository rebuilds the user configuration and selected system policy for
an Arch Linux Intel/NVIDIA workstation running both Niri and GNOME. GNU Stow
owns files below `$HOME`; the `dotfiles` controller installs missing software,
copies reviewed `/etc` templates, restores portable application state, and
records version/source locks.

The boundary is deliberately post-install: disks, bootstrapping, networking,
the user account, and working `sudo` must already exist. The result is highly
repeatable, but not a bit-for-bit image. Filesystem UUIDs, credentials, browser
profiles, private Codex state, and volatile caches remain machine-local. The
reviewed OpenRGB package is the deliberate exception for hardware metadata: it
contains this host class's detector/profile data and must be reviewed before a
public push.

## New-machine quick start

Install the controller prerequisites first:

```sh
sudo pacman -S --needed git python stow base-devel
git clone https://github.com/sshussh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Always inspect the two read-only views before applying:

```sh
./dotfiles audit --profile workstation
./dotfiles apply --profile workstation --dry-run
```

Then apply the standard profile:

```sh
./dotfiles apply --profile workstation
```

The real apply is interactive where pacman, AUR builds, or root writes require
confirmation. Its order is intentional:

1. validate the full profile and reject Stow conflicts;
2. install the stable `pacman.conf` before resolving packages;
3. install only packages that are absent—never prune, upgrade, or downgrade an
   already-installed package;
4. build missing AUR packages from pinned PKGBUILD commits and install `pyrs`
   with its pinned Git commit and Rust 1.98.0 toolchain;
5. restow the user packages with `--no-folding`;
6. install Zinit, Oh My Zsh, and four plugins at full Git commits;
7. converge `/etc` content, mode, and ownership and set the profile timezone;
8. restore portable state, including the Zsh login shell and local pre-commit
   hook; then reload and enable declared services.

Snapper configs and Btrfs scrub timers are gated separately. After verifying
the subvolume and mount layout described in [`system/README.md`](system/README.md),
apply them with:

```sh
./dotfiles apply --profile workstation --include-optional-system
```

The controller does not regenerate initramfs or GRUB and does not start newly
enabled services unless `--start-services` is supplied. Review the post-apply
checklist in `system/README.md` before rebooting.

## Commands

| Command | Purpose |
| --- | --- |
| `./dotfiles audit` | Report Stow, package, system-template, service, mount, Cargo, state, and lock drift without writing |
| `./dotfiles audit --strict` | Return nonzero for warnings; used by the local reproducibility check |
| `./dotfiles apply --dry-run` | Run GNU Stow's real simulator and print every other proposed operation |
| `./dotfiles apply` | Apply the additive workstation contract |
| `./dotfiles capture` | Run explicit state exporters; review the resulting diff before committing |
| `./dotfiles lock` | Write both current and dated package/source snapshots under `locks/` |

Useful apply controls:

- `--skip-packages`, `--skip-system`, and `--skip-state` omit an entire phase.
- `--include-optional-system` opts into Snapper and Btrfs timer policy.
- `--start-services` changes service activation from `enable` to `enable --now`.
- `--allow-testing` is an explicit escape hatch when testing repositories are
  enabled and the system phase is skipped.
- `DOTFILES_TARGET=/path` changes the Stow target. State operations are
  automatically skipped unless the target is the real home directory.
- `DOTFILES_VAR_LOCALE`, `DOTFILES_VAR_KEYMAP`,
  `DOTFILES_VAR_XKB_LAYOUT`, `DOTFILES_VAR_GRUB_DISTRIBUTOR`, and
  `DOTFILES_VAR_TIMEZONE` override profile variables.

`install.sh` is only a compatibility wrapper. New automation should invoke
`dotfiles` directly. It refuses the old `--force`, `--adopt`, and unattended
confirmation modes rather than silently changing their meaning.

## Managed layers

| Layer | Managed | Deliberately manual |
| --- | --- | --- |
| Packages | Curated official/AUR lists, pinned AUR commits, pinned `pyrs` source/toolchain | Extra installed packages are recorded in locks but never removed |
| Home | Stow links plus six pinned Zsh Git sources, login shell, and repository hook | DMS session/preferences, browser/mail/chat profiles, credentials |
| GNOME | Sanitized additive dconf, package-owned extensions, five-minute lock, committed wallpaper | Monitor layout, location, app usage/history, runtime palette values |
| System | Stable pacman policy, timezone, locale/keyboard, mkinitcpio/GRUB input, zram, Reflector, coredumps, GRUB-Btrfs | fstab, kernel root/encryption arguments, Secure Boot keys, UFW rules |
| Versions | Latest/dated locks, source revisions, Stow/system hashes, tool versions | Historical Arch binaries and the Codex current-release channel |

## GNU Stow packages

All packages mirror their final paths below `$HOME`; `--no-folding` keeps parent
directories real so applications can create adjacent state safely.

| Package | Main contents |
| --- | --- |
| `zsh-bootstrap` | `~/.zshenv` and `ZDOTDIR` bootstrap |
| `terminal` | Zsh, Fish, Ghostty, Kitty helpers, btop, and Neovim |
| `gnome-desktop` | MIME defaults, environment, user directories, OpenRGB autostart, user service, committed wallpaper |
| `matugen` | DMS-compatible templates, wallpaper controller, theme/icon discovery files |
| `zed` | Zed settings, keymap, and tasks |
| `niri` | Portable Niri compositor configuration; generated DMS includes stay local |
| `fontconfig` / `xresources` | Arabic font preference and cursor defaults |
| `hardware` | OpenRGB detector/profile data for this host class |

Stow conflicts are rejected before package or system mutations. Do not use
`stow --adopt`: it can copy unreviewed machine state into this public repo.
For an intentional migration, back up the exact conflicting paths and use
`scripts/replace-existing` explicitly.

## Locks and rolling-release limits

`./dotfiles lock` writes `locks/workstation.json` plus a dated
`locks/workstation-YYYY-MM-DD.json`. A lock records selected installed package
versions, pinned AUR/Cargo sources, unmanaged explicit packages, tool versions,
and content hashes. Audit compares the full package membership and versions,
unmanaged explicit set, every source pin, tool versions, and both content-hash
sets with the latest lock.

The lock is evidence and drift detection, not a binary package archive. Arch
mirrors may stop carrying an old official package version; rebuilding that exact
binary would require a separate package archive. AUR packages are stronger:
their PKGBUILD repositories are checked out at full commits before building.
Because `explicit_unmanaged` fingerprints locally installed software, review or
remove that observational field before publishing a lock from a private host.

## State, secrets, and history

See [`state/README.md`](state/README.md) for the handler matrix. Captures use
temporary files and refuse to replace good manifests with empty output. GNOME
capture has a safe fallback when it cannot contact a running Shell and supports
the non-writing `./scripts/export-gnome --check` mode.

The ignore policy blocks common credential stores, browser profiles, shell
histories, private Codex state, nested repositories, databases, logs, and
generated palettes. A full apply installs the pinned pre-commit hook; Gitleaks
also runs in CI. Historical `.zsh_history` and
`.zcompdump` paths still exist in old Git commits; the repository contains a
mirror-only scrub helper, but no history rewrite or force-push is performed
without a separate explicit decision. See [`maintenance/README.md`](maintenance/README.md).

Codex uses OpenAI's current standalone user installer through
`maintenance/install-codex`; it is intentionally not part of the base profile.
On a new system run that helper explicitly, then start `codex` to authenticate.
The installer channel and authentication remain manual.

## Verification

The latest verified results and known drift are recorded in
[`docs/verification.md`](docs/verification.md). Locally, run:

```sh
PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s tests -v
./maintenance/check-reproducibility
```
