# cmux has its own tabs/splits/persistence; do not nest tmux inside it.
# cmux exports CMUX_WORKSPACE_ID / CMUX_SOCKET_PATH to every shell it spawns.
if [ -n "$CMUX_WORKSPACE_ID" ] || [ -n "$CMUX_SOCKET_PATH" ]; then
  return 0
fi

if [ -z "$TMUX" ]; then
  command tmux new -A -s "$(hostname -s)"
fi
