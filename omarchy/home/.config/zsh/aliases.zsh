# Aliases ported from github.com/jchiatt/dotfiles

alias vim="nvim"
alias vi="nvim"
alias v="nvim"

alias -- -='cd -'
alias map="xargs -n1"

alias dt='date "+%Y-%m-%dT%H:%M:%S"'   # ISO 8601 timestamp
alias epoch='date "+%s"'

alias dkl="docker ps -lq"
alias dcu="docker compose up"

# j: jump to a frecent directory (was fasd's `j`; zoxide replaces fasd on Omarchy)
alias j="z"
alias ji="zi"   # interactive picker (fzf)
