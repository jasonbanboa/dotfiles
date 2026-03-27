# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything.
case $- in
*i*) ;;
*) return ;;
esac

add_path_if_missing() {
  local dir="$1"
  if [ -d "$dir" ]; then
    case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$dir:$PATH" ;;
    esac
  fi
}

# Keep local binaries and snap binaries available in every shell.
add_path_if_missing "$HOME/.local/bin"
add_path_if_missing "/snap/bin"
export PATH
unset -f add_path_if_missing

# History tuned for suggestion-style workflows.
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=20000
shopt -s histappend cmdhist checkwinsize

__dotfiles_history_sync() {
  history -a
  history -n
}

case ";$PROMPT_COMMAND;" in
*";__dotfiles_history_sync;"*) ;;
*)
  if [ -n "${PROMPT_COMMAND:-}" ]; then
    PROMPT_COMMAND="__dotfiles_history_sync; $PROMPT_COMMAND"
  else
    PROMPT_COMMAND="__dotfiles_history_sync"
  fi
  ;;
esac

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below).
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot="$(cat /etc/debian_chroot)"
fi

# Enable color support of ls and add handy aliases.
if [ -x /usr/bin/dircolors ]; then
  test -r "$HOME/.dircolors" && eval "$(dircolors -b "$HOME/.dircolors")" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vim='nvim'

# Add an "alert" alias for long running commands. Use like: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^[[:space:]]*[0-9]\+[[:space:]]*//;s/[;&|][[:space:]]*alert$//'\'')"'

if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi

# Enable programmable completion.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# VSCode-like shell suggestions: smarter tab completion + history search.
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'set menu-complete-display-prefix on'
bind 'set colored-stats on'
bind 'set visible-stats on'
bind 'set mark-symlinked-directories on'
bind 'set page-completions off'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
bind '"\eOA":history-search-backward'
bind '"\eOB":history-search-forward'

# fzf keybindings/completion (installed via apt fzf package).
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  . /usr/share/doc/fzf/examples/key-bindings.bash
fi
if [ -f /usr/share/bash-completion/completions/fzf ]; then
  . /usr/share/bash-completion/completions/fzf
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

export STARSHIP_CONFIG=~/dotfiles/starship/starship.toml
eval "$(starship init bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
eval "$(zoxide init bash)"
