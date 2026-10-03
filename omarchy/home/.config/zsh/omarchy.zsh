# Omarchy's bash integrations, adapted for zsh.
# Source of truth: /usr/share/omarchy/default/bash/{aliases,fns,init}

source "$OMARCHY_PATH/default/bash/aliases"
# fns use bash-style (0-indexed) arrays, so they run under sh emulation.
# Skip worktrees: its ga/gd functions clash with oh-my-zsh's ga (git add) / gd (git diff).
for _f in "$OMARCHY_PATH"/default/bash/fns/*; do
  [[ ${_f:t} == worktrees ]] && continue
  emulate sh -c "source '$_f'"
done
unset _f

# Prefer oh-my-zsh's meaning (git checkout main) over Omarchy's (git commit -m)
alias gcm='git checkout $(git_main_branch)'

(( $+commands[mise] ))     && eval "$(mise activate zsh)"
(( $+commands[starship] )) && [[ $TERM != dumb ]] && eval "$(starship init zsh)"
(( $+commands[zoxide] ))   && eval "$(zoxide init zsh)"
(( $+commands[fzf] ))      && source <(fzf --zsh)

if (( $+commands[try] )); then
  try() {
    unfunction try
    eval "$(SHELL=/bin/zsh command try init ~/Work/tries)"
    try "$@"
  }
fi

# Tab completion for the `omarchy` command (bash completion via bashcompinit)
autoload -Uz bashcompinit && bashcompinit
source "$OMARCHY_PATH/default/bash/completions" 2>/dev/null
