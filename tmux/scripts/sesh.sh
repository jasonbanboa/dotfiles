#!/bin/bash
export PATH="$HOME/go/bin:$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

selected=$(sesh list --icons | fzf-tmux -p 80%,70% \
  --no-sort --ansi --cycle --border-label ' sesh ' --prompt '⚡ ' \
  --header ' ^a all ^t tmux ^z zoxide ^x tmux kill ^f find' \
  --bind 'ctrl-n:down,ctrl-p:up' \
  --bind 'ctrl-a:change-prompt(⚡ )+reload(sesh list --icons)' \
  --bind 'ctrl-t:change-prompt( )+reload(sesh list -t --icons)' \
  --bind 'ctrl-z:change-prompt( )+reload(sesh list -z --icons)' \
  --bind 'ctrl-x:execute-silent(tmux has-session -t {2} 2>/dev/null && tmux kill-session -t {2})+reload(sesh list --icons)' \
  --preview-window 'right:55%' \
  --preview 'sesh preview {}')

[ -n "$selected" ] && sesh connect "$selected"
exit 0
