# Bootstrap only — real config lives in $ZDOTDIR
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# zsh only auto-reads ONE .zshenv: $ZDOTDIR/.zshenv if ZDOTDIR is already set,
# otherwise ~/.zshenv. Bridge the cold-start case:
if [[ -z ${_ZSHENV_LOADED:-} && -r $ZDOTDIR/.zshenv ]]; then
  source "$ZDOTDIR/.zshenv"
fi
