# Every interactive terminal lands in tmux.
# The first one attaches to the session named after this host. If that session is
# already showing in another window, the new terminal joins it as a *grouped*
# session: same windows, but its own current window (so terminals don't mirror
# each other). The grouped view is destroyed when its terminal closes.
# Skipped inside Herdr panes, Claude Code, and editor terminals.
if [[ -o interactive && -t 0 && -t 1 && -z $TMUX && -z $CLAUDECODE && $TERM != dumb \
      && $TERM_PROGRAM != vscode && -z $INSIDE_EMACS && -z $TMUX_AUTOSTART_DISABLE && -z $HERDR_PANE_ID ]] \
   && (( $+commands[tmux] )); then
  () {
    local session=${HOST%%.*}
    if ! tmux has-session -t "=$session" 2>/dev/null; then
      tmux new-session -s "$session"
    elif [[ -z $(tmux list-clients -t "=$session" 2>/dev/null) ]]; then
      tmux attach-session -t "=$session"
    else
      tmux new-session -t "=$session" \; set-option destroy-unattached on
    fi
  }
fi
