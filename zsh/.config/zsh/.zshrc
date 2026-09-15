# Interactive zsh entrypoint ($ZDOTDIR/.zshrc)

source "$ZDOTDIR/.zsh_setup"
source "$ZDOTDIR/.zsh_aliases"
if [[ -r $ZDOTDIR/.zsh_functions ]]; then
  source "$ZDOTDIR/.zsh_functions"
fi
source "$ZDOTDIR/.zsh_prompt"

# >>> grok installer >>>
# Path is also set in .zshenv; ensure completions are on fpath.
fpath=(~/.grok/completions/zsh $fpath)
# <<< grok installer <<<

# Machine-local overrides (not committed)
# Use if/fi (not `&&`) so a missing file does not leave $? = 1 on the first prompt.
if [[ -r $ZDOTDIR/.zshrc.local ]]; then
  source "$ZDOTDIR/.zshrc.local"
fi

