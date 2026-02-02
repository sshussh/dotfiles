# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"   # .config directory for zsh

# --------- #

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# History
HISTSIZE=5000
HISTFILE=$ZDOTDIR/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Environment

# mesa shaders
# MESA_SHADER_CACHE_MAX_SIZE="12G"

# rust
# export RUSTC_WRAPPER=sccache

# spicetify
export TERM="kitty"
export TERMINAL="kitty"
export TerminalEmulator="kitty"

export PATH=$PATH:/home/shush/.spicetify

# editors
export EDITOR="nvim"
export VISUAL="code"

# Rust
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/home/shush/.cargo/bin

# JetBrains
export PATH=$PATH:/home/shush/.local/share/JetBrains/Toolbox/scripts

# Golang
GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Added by Toolbox App
export PATH="$PATH:/home/shush/.local/share/JetBrains/Toolbox/scripts"

# Installation paths
export PATH=$PATH:/home/shush/.local/bin

# Keybindings
bindkey -e  # Use emacs keybindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Dotnet
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"

# pnpm
export PNPM_HOME="/home/shush/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Aliases
# lsd - better ls
alias ls="lsd --color=always"
alias ll="lsd -latrh --color=always"

alias grep="grep --color=auto"
alias cls="clear"
alias ff="fastfetch"

alias sys-update="sudo pacman -Syu && paru && flatpak update"
alias weather="curl http://wttr.in/amman"

# oh-my-posh
# eval "$(oh-my-posh init zsh)"
# eval "$(oh-my-posh init zsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/amro.omp.json')"
# eval "$(oh-my-posh init zsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/bubblesextra.omp.json')"
# eval "$(oh-my-posh init zsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/froczh.omp.json')"
# eval "$(oh-my-posh init zsh --config 'https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/json.omp.json')"
eval "$(oh-my-posh init zsh --config ${ZDOTDIR}/avit.omp.json)"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

