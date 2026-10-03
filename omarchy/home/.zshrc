# ~/.zshrc — jc's zsh setup on Omarchy
# Pieces live in ~/.config/zsh/; machine-specific tweaks go in ~/.config/zsh/local.zsh

# Omarchy environment (EDITOR, BROWSER, OMARCHY_PATH, PATH, locale)
emulate sh -c 'source /usr/share/omarchy/default/bash/envs'

# Attach to tmux before loading everything else (from dotfiles init.d/99-tmux)
source ~/.config/zsh/tmux-autostart.zsh

# oh-my-zsh (prompt is drawn by starship, so no theme)
export ZSH=~/.local/share/oh-my-zsh
ZSH_THEME=""
DISABLE_UNTRACKED_FILES_DIRTY="true"
plugins=(git dircycle)
source $ZSH/oh-my-zsh.sh

# History (same sizes as before; skip noise like the old HISTIGNORE)
HISTSIZE=32768
SAVEHIST=32768
HISTORY_IGNORE="(ls|cd|cd -|pwd|exit|date|* --help)"

source ~/.config/zsh/omarchy.zsh     # Omarchy aliases/functions + mise, starship, zoxide, fzf
source ~/.config/zsh/functions.zsh   # ported from dotfiles shellrc.d
source ~/.config/zsh/aliases.zsh
[[ -f ~/.config/zsh/local.zsh ]] && source ~/.config/zsh/local.zsh

# Plugins that must load last
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
