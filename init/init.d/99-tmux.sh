# cmux and Herdr have their own tabs/splits/persistence; do not nest tmux inside them.
# cmux exports CMUX_WORKSPACE_ID / CMUX_SOCKET_PATH; Herdr exports HERDR_ENV=1.
if [ -n "$CMUX_WORKSPACE_ID" ] || [ -n "$CMUX_SOCKET_PATH" ] || [ "${HERDR_ENV:-}" = "1" ]; then
  return 0
fi

# Only attach from a real terminal: `zsh -ic '…'` from scripts and tools has no tty.
if [ -z "$TMUX" ] && [ -t 0 ] && [ -t 1 ]; then
  command tmux new -A -s "$(hostname -s)"
fi
