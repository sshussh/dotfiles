# Sourced as $ZDOTDIR/.zshenv (and via ~/.zshenv bootstrap on cold start)
# Prevent double-loading when ~/.zshenv sources this file
[[ -n ${_ZSHENV_LOADED:-} ]] && return
typeset -g _ZSHENV_LOADED=1

# zinit home (also set in .zsh_setup for interactive installs)
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# --- PATH (deduped) ----------------------------------------------------------
# typeset -U path keeps unique entries; path is tied to PATH in zsh
typeset -U path PATH
path=(
  $HOME/.grok/bin
  $HOME/.local/share/pnpm
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/go/bin
  /usr/local/go/bin
  $HOME/dev/sdk/flutter/bin
  $HOME/.spicetify
  $HOME/dev/opt
  /usr/local/bin
  /usr/sbin
  $path
)

export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export GOPATH="${GOPATH:-$HOME/go}"
export CHROME_EXECUTABLE="${CHROME_EXECUTABLE:-/usr/bin/chromium}"

# --- Editor / apps -----------------------------------------------------------
export EDITOR="${EDITOR:-zeditor}"
export VISUAL="${VISUAL:-zeditor}"

# Prefer letting the terminal set TERM. Only set TERMINAL for apps that spawn one.
export TERMINAL="${TERMINAL:-ghostty}"
# Do NOT force TERM=… — breaks ssh/tmux and non-Ghostty sessions.
# Ghostty shell integration is configured in ~/.config/ghostty/config (shell-integration = zsh).

# --- bat / less / man colors -------------------------------------------------
# No official Vesper bat theme; OneHalfDark is a close dark-minimal match.
export BAT_THEME="${BAT_THEME:-OneHalfDark}"
export LESS='-R --mouse --wheel-lines=3'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT='-c'

# --- fzf defaults (Vesper) ---------------------------------------------------
export FZF_DEFAULT_OPTS="\
  --height=60% \
  --layout=reverse \
  --border=rounded \
  --info=inline \
  --prompt='❯ ' \
  --pointer='▶' \
  --marker='✓' \
  --color=bg+:#1c1c1c,bg:#101010,spinner:#ffc799,hl:#ff8080 \
  --color=fg:#a0a0a0,header:#ff8080,info:#ffc799,pointer:#ffc799 \
  --color=marker:#99ffe4,fg+:#ffffff,prompt:#ffc799,hl+:#ff8080 \
  --color=border:#7e7e7e,label:#ffc799,gutter:#101010"

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers,changes --line-range=:200 {} 2>/dev/null || cat {}'"
export FZF_ALT_C_OPTS="--preview 'lsd --tree --depth 2 --color=always --icon=always {} 2>/dev/null || ls -la {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:hidden:wrap --bind '?:toggle-preview'"

# Machine-local overrides (not committed)
# Use if/fi so a missing file does not leave $? = 1 for the first prompt.
if [[ -r $ZDOTDIR/.zshenv.local ]]; then
  source "$ZDOTDIR/.zshenv.local"
fi


