# Verification report — 2026-09-03

The repository was checked against the live Arch workstation and an isolated
temporary home. The reproducibility controller is internally consistent and
reports all known unapplied host drift without hiding failures.

## Passed checks

- Twelve unit/integration tests: two real idempotent Stow deployments, Stow's
  real simulator, regular-file conflict preservation, all six mutable-file
  migration classes, preserved btop runtime writes, lock JSON/hash comparison,
  Git-remote normalization, and non-mutating GNOME help.
- Python compilation; Bash and Zsh syntax; all five TOML and two YAML files;
  `pacman-conf`; `niri validate`; and `git diff --check`.
- All 118 official package names resolve in the configured Arch repositories.
  Eight AUR names have one-to-one full-commit source locks; `pyrs` has a full
  commit plus Rust 1.98.0; all six Zsh Git sources are at their declared commits.
- Both lock files are equal and match a fresh preview except for generation
  time. Audit now compares package membership/versions, unmanaged explicit
  packages, AUR/Cargo/Git pins, tool versions, Stow hash, and all 12 rendered
  system-template hashes, plus the complete mutable-state tree hash.
- All eight Stow packages resolve to repository-owned links in the live home.
  Niri's portable policy, Kitty helpers, fontconfig, Xresources, wallpaper,
  and Matugen discovery files validate at their final paths.
- MIME defaults, btop and pavucontrol preferences, both XDG user-directory
  files, the Niri entrypoint, and all OpenRGB data are regular files matching
  explicit state snapshots. Migration tests prove each handler safely replaces
  its old link, including dangling links whose former repository parent was
  removed.
- Niri validates the complete live composition: the regular entrypoint loads
  Stow-managed portable policy plus optional DMS-generated fragments. Btop is
  seeded as a regular file and retains its normal save-on-exit behavior.
- The GNOME capture/apply/capture round trip is clean. The snapshot excludes
  location, certificates, app-folder IDs, stale extension inventory/settings,
  unavailable launchers, hardware sensor IDs, GameMode, and runtime palette
  values. Candidate files are staged before replacement.
- Live GNOME has locking enabled, a five-minute idle timeout, immediate lock
  after blanking, password-required sharing, the curated extensions, and the
  committed wallpaper. Matugen regeneration completed successfully.
- The account login shell and timezone already match `/usr/bin/zsh` and
  `Asia/Amman`. Declared non-optional system and user services are enabled.
- Current paths contain no obvious credential filenames or common key/token
  signatures. Historical path inspection finds only the two documented shell
  state paths. Local Gitleaks is not yet installed; immutable pre-commit and CI
  pins are configured.

## Current reported drift

The real-host default audit reports **13 warnings and 0 errors**:

- six normalized `/etc` templates differ: pacman, mkinitcpio, GRUB, the
  GRUB-Btrfs drop-in, vconsole, and the X11 keyboard file;
- five selected official packages are absent: `ripgrep`, `starship`,
  `gnome-shell-extensions`, `git-filter-repo`, and `pre-commit`;
- `pyrs` is installed from a local path instead of the pinned Git revision;
- this clone's pre-commit hook is inactive because `pre-commit` is absent.

Auditing the opt-in Snapper policy adds the two differing Snapper templates,
for **15 warnings and 0 errors**. Its optional services are already enabled.

The full dry run passes. It proposes only the five missing official packages,
the pinned Rust/Cargo install, changed `/etc` templates, and declared state and
service actions. It does not pass any installed package—including `cava`—to
pacman, and performs no pruning, upgrade, or downgrade.

No privileged package or `/etc` apply was performed during verification. Run
the dry run, review it, then invoke the real apply with interactive `sudo` to
clear the remaining host drift. User-layer changes were applied: migrated Stow
links are live, the GNOME safety baseline is active, and the pinned Oh My Zsh
checkout was installed.

## Remaining boundaries and decisions

- Arch locks are observational; historical official package binaries are not
  archived. The manual Codex helper intentionally follows OpenAI's current
  standalone release channel and authentication remains interactive.
- DMS preferences/session state, generated Niri fragments/monitor output, Zed extension
  installation, browser/mail/chat profiles, and all application authentication
  remain manual.
- Filesystem identifiers, kernel root/encryption arguments, Secure Boot, UFW
  rules, and whether to opt into the supplied Snapper policy remain per-host
  decisions.
- The user-authored OpenRGB autostart enables its SDK server using OpenRGB's
  all-interface default. Keep UFW restrictive or add `--server-host 127.0.0.1`
  if LAN clients are not intended. Binary profiles may expose device metadata.
- Old Git history still contains `.config/zsh/.zsh_history` and
  `.config/zsh/.zcompdump` paths. The mirror-only purge helper has not rewritten
  or pushed history; secret rotation and any force-push remain separate,
  explicitly destructive decisions.

Within those boundaries, a booting Arch installation can converge additively:
software and user Git sources are pinned where upstream permits, static home
files are Stow-owned, mutable files have explicit snapshots, system policy is
rendered and backed up, and both content and machine drift are auditable.
