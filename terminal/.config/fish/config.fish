set -g fish_greeting

set -gx EDITOR zeditor
set -gx VISUAL zeditor
set -gx MANPAGER "nvim +Man!"

fish_add_path ~/.local/bin
fish_add_path ~/dev/opt

abbr ll 'ls -lah'

if status is-interactive
    abbr cd 'z'
    zoxide init fish | source
    starship init fish | source
end

