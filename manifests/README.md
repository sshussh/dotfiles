# Profiles, manifests, and locks

`profiles/workstation.toml` composes the portable `common` layer with the
`host-intel-nvidia` layer. Includes are recursive, ordered, deduplicated, and
cycle-checked. Later variable values override earlier ones; list values merge in
stable order.

The controller validates schema version 1, package names, duplicate system
targets, template source containment, `/etc` target containment, file modes,
full Git revisions, HTTPS source URLs, safe user-source targets, an exact Rust
toolchain, and one source lock for every AUR package before any mutation.

## Package semantics

- `manifests.pacman` contains official repository packages.
- `manifests.aur` contains AUR packages. Every entry has a matching
  `[[aur_sources]]` repository and full commit.
- `bootstrap.paru` pins the initial AUR helper PKGBUILD. Missing subsequent AUR
  packages are also cloned and built directly from their pinned commits.
- `[[cargo_sources]]` installs workspace binaries from exact Git revisions with
  `cargo install --locked` and an exact toolchain.
- `[[git_sources]]` installs Zinit, Oh My Zsh, and plugins below the live home
  at full commits; tracked changes or unexpected remotes stop apply.

Only absent package names are passed to installers. Existing packages—including
newer testing builds—are left untouched. Extra packages are unmanaged and are
never removed.

## System and service fields

`[[system_templates]]` maps a repository source to an absolute `/etc` target and
mode and converges the target as `root:root`. `optional = true` requires
`--include-optional-system`. `services.system`
is always enabled during a system apply, while `services.optional_system` uses
the same opt-in gate. User services are enabled only for the live home/session.

Template placeholders use `{{UPPER_CASE_NAME}}`. Defaults come from profile
`variables`; environment overrides use `DOTFILES_VAR_NAME`.

## Locks

```sh
./dotfiles lock --profile workstation
```

This writes both `locks/workstation.json` and a dated snapshot. It records:

- installed versions for the desired official/AUR packages;
- desired packages currently missing;
- explicit installed packages outside the contract;
- pinned AUR, Cargo, and user Git source revisions plus the Rust toolchain;
- controller/tool versions;
- hashes for the complete Stow source tree and rendered system templates.

Audit compares all recorded fields except generation time: package membership
and versions, unmanaged explicit packages, source pins, tools, and Stow/system
hashes. Locks detect drift and document a known state; they do not archive
historical Arch binaries. The unmanaged package field is useful evidence but
can fingerprint a host, so review it before publishing.
