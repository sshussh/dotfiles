# System layer

The controller copies these files below `/etc`; GNU Stow never targets `/`.
Every changed existing file is backed up under
`/var/backups/dotfiles/YYYYMMDD-HHMMSS/etc/...` before replacement. Content,
declared mode, and `root:root` ownership converge; a content-identical file with
wrong metadata is repaired. A dry run prints every operation without invoking
`sudo`.

## Templates and activation

| Source | Target | Activation or follow-up |
| --- | --- | --- |
| `etc/pacman.conf` | `/etc/pacman.conf` | Installed before packages; testing repos disabled without downgrading installed packages |
| `etc/xdg/reflector/reflector.conf` | `/etc/xdg/reflector/reflector.conf` | `reflector.timer` is enabled; use `--start-services` to start now |
| `etc/mkinitcpio.conf` | `/etc/mkinitcpio.conf` | Review, then manually run `sudo mkinitcpio -P` |
| `etc/default/grub` | `/etc/default/grub` | Add machine-specific root/encryption arguments, then regenerate GRUB manually |
| `etc/systemd/zram-generator.conf` | `/etc/systemd/zram-generator.conf` | Effective after daemon reload and next boot/device recreation |
| `etc/systemd/system/grub-btrfsd.service.d/override.conf` | matching systemd drop-in | Controller runs `systemctl daemon-reload` |
| `etc/systemd/coredump.conf.d/50-remediation-limits.conf` | matching coredump drop-in | Applies to subsequent coredumps |
| `etc/locale.conf` | `/etc/locale.conf` | Ensure the locale is uncommented in `/etc/locale.gen`, then run `sudo locale-gen` |
| `etc/vconsole.conf` | `/etc/vconsole.conf` | Console keyboard/font; effective at boot |
| `etc/X11/xorg.conf.d/00-keyboard.conf` | matching X11 file | XKB layout/model/options for Xorg consumers |
| `etc/snapper/configs/{root,home}` | matching Snapper configs | Optional; requires verified Btrfs subvolumes and `--include-optional-system` |

The profile also sets `Asia/Amman` through `timedatectl`; override it with
`DOTFILES_VAR_TIMEZONE=Region/City`.

The controller enables services but does not start them by default. Add
`--start-services` only when immediate activation is desired. Enable failures
are fatal; they are not suppressed. User units receive their own daemon reload
before enablement, and a real apply fails clearly if no user runtime is
available.

## Machine-specific boundary

Never copy these values between installations:

- `/etc/fstab` UUIDs/PARTUUIDs and device paths;
- root, resume, encryption, and Secure Boot arguments or keys;
- NetworkManager connection secrets and SSH host keys;
- UFW runtime rules;
- monitor serials/output placement and hardware calibration.

`mounts.toml` instead records portable mount semantics. `dotfiles audit` checks
the current mount type and required options for `/`, `/home`, `/boot`, and
`/mnt/storage` without storing identifiers.

## Snapper and Btrfs gate

The Snapper templates and these services are omitted by default:

- `snapper-cleanup.timer`
- `snapper-timeline.timer`
- `btrfs-scrub@-.timer`
- `btrfs-scrub@mnt-storage.timer`

Before opting in, verify that `/` uses subvolume `@`, `/home` uses `@home`, and
`/mnt/storage` exists with the recorded layout. Create and validate the
`.snapshots` subvolumes/configs before enabling timers. Then preview and apply:

```sh
./dotfiles apply --dry-run --include-optional-system
./dotfiles apply --include-optional-system
```

Default audit omits this opt-in policy so a standard apply can converge cleanly.
Audit it explicitly with `./dotfiles audit --include-optional-system`.

## Stable repository transition

The profile installs the stable pacman template before resolving missing
packages. Package installation selects only names absent from `pacman -Q`; an
installed testing build is therefore neither downgraded nor upgraded. After
testing repos are disabled, allow versions to converge naturally or handle a
deliberate downgrade separately.

## Post-apply checklist

1. Compare `/etc/fstab`, current mounts, and `system/mounts.toml`.
2. Confirm timezone, locale, and keyboard behavior; run `sudo locale-gen` if needed.
3. Review mkinitcpio hooks, then run `sudo mkinitcpio -P`.
4. Add the new machine's root/encryption arguments to GRUB configuration and
   run `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
5. Inspect `systemctl --failed` and the enabled units.
6. Configure UFW rules interactively; only the service enablement is managed.
7. Reboot when the boot artifacts and service state have been reviewed.

To recover one replaced file, copy it from the matching timestamp below
`/var/backups/dotfiles/` back to its original path and repeat any relevant
activation step. Backups are never placed inside `/etc/snapper/configs`, where
Snapper would misinterpret them as live configurations.
