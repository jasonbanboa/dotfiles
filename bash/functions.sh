tmux() {
  if [[ $# -gt 0 ]]; then
    command tmux "$@"
    return
  fi

  local name="$(basename $PWD)"

  if command tmux has-session -t "$name" 2>/dev/null; then
    command tmux attach-session -t "$name"
    return
  fi

  command tmux new-session -d -s "$name" -n 'neovim'
  command tmux send-keys -t "$name:neovim" 'nvim .' Enter
  command tmux new-window -t "$name"
  command tmux split-window -h -t "$name"
  command tmux new-window -t "$name" -n 'ai'
  command tmux send-keys -t "$name:ai" 'claude' Enter
  command tmux select-window -t "$name:neovim"
  command tmux attach-session -t "$name"
}
