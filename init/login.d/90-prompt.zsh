
function __create_prompt() {
  local generated_prompt=''

  if [ -z "$fg_bold" ]; then
    autoload colors
    colors
  fi
  
  if [[ $UID -eq 0 ]]; then
    local __prompt_end_char='#'
    local __prompt_user_color='%{$fg_bold[red]%}'
  else
    local __prompt_end_char='💩'
    local __prompt_user_color='%{$fg_bold[blue]%}'
  fi

  local user_part=${__prompt_user_color}'%n%{$reset_color%}'
  local path_part='%{$fg_bold[blue]%}${PWD##*/}%{$reset_color%}'
  local stop_part=$__prompt_end_char

  generated_prompt="${user_part}:${path_part}${stop_part}\u00A0"
  echo $generated_prompt
}

PROMPT=$(__create_prompt)

if typeset -f git_prompt_status > /dev/null; then
  RPROMPT='${return_status}$(git_prompt_info)$(git_prompt_status)%{$reset_color%}'
fi
