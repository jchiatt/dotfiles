# Every interactive terminal lands in tmux.
# The first one attaches to the session named after this host; if that session is
# already showing in another window, a throwaway session is created instead (and
# destroyed when its window closes) so tiled terminals don't mirror each other.
if [[ -o interactive && -t 0 && -t 1 && -z $TMUX && -z $CLAUDECODE && $TERM != dumb \
      && $TERM_PROGRAM != vscode && -z $INSIDE_EMACS && -z $TMUX_AUTOSTART_DISABLE ]] \
   && (( $+commands[tmux] )); then
  () {
    local session=${HOST%%.*}
    if ! tmux has-session -t "=$session" 2>/dev/null; then
      tmux new-session -s "$session"
    elif [[ -z $(tmux list-clients -t "=$session" 2>/dev/null) ]]; then
      tmux attach-session -t "=$session"
    else
      tmux new-session \; set-option destroy-unattached on
    fi
  }
fi
