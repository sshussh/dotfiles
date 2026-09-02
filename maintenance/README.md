# Maintenance and security

## Routine verification

`check-reproducibility` runs strict audit mode, so any warning or error returns
nonzero. Unit/integration tests additionally perform a real two-pass Stow deploy
inside a temporary home, conflict rejection, lock serialization, and a
non-mutating GNOME help check.

CI repeats syntax, unit, isolated-home audit, Stow simulation, and Gitleaks
checks with actions pinned to full commits. The standard profile selects
`pre-commit`, and full apply installs the local Gitleaks/whitespace/conflict
hook environments from full commits. Until that package is applied, CI is the
active Gitleaks enforcement point.

## Codex CLI

`install-codex` downloads the official standalone installer to a temporary
file and runs it non-interactively in the user scope. The upstream installer is
the current-release channel rather than a version-pinned archive, so
`dotfiles lock` records the resulting version. Authentication is deliberately
not automated; run `codex` and choose a login method after installation.

## Historical shell-state purge

Old commits contain `.zsh_history` and `.zcompdump` paths. Their contents are
not inspected by this workflow. To prepare a reviewable rewritten mirror:

```sh
./maintenance/purge-sensitive-history.sh ~/.dotfiles /absolute/path/to/scrubbed.git
```

The script clones a separate mirror and removes those paths with
`git-filter-repo`. It never updates the working repository and never pushes.
Reviewing the rewritten graph, coordinating clones, revoking exposed secrets if
needed, running a full-history secret scan before and after, verifying the paths
are absent from every rewritten ref, and force-pushing affected refs are
separate destructive decisions.

## Retired compatibility paths

`scripts/check-deps` is retained as a read-only alias for `dotfiles audit`.
Its former installers were removed because they cloned unpinned sources and
could remove packages outside the current additive contract.

## Local migration backup

During the 2026-09-02 verification, five previously unmanaged files were copied
into Stow packages and replaced with links. Their recoverable originals, plus
two unfolded Matugen discovery links, are under:

```text
~/.cache/dotfiles-stow-backup-20260902-verification/
```

Keep that directory until the linked Niri, Kitty, fontconfig, Xresources, and
Matugen behavior has been used successfully for a while.
