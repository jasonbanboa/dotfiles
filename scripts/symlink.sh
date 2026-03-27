#!/bin/bash
DOTFILES=~/dotfiles
CONFIG=~/.config

mkdir -p "$CONFIG"

for dir in "$DOTFILES"/*/; do
    name="$(basename "$dir")"
    [[ "$name" == "scripts" ]] && continue

    if [ -e "$CONFIG/$name" ] && [ ! -L "$CONFIG/$name" ]; then
        mv "$CONFIG/$name" "$CONFIG/$name.bak"
        echo "Backed up $CONFIG/$name → $CONFIG/$name.bak"
    fi
    ln -sfn "$dir" "$CONFIG/$name"
    echo "Linked $name → $CONFIG/$name"
done

ln -sf "$DOTFILES/.bashrc" ~/.bashrc
echo "Linked .bashrc → ~/.bashrc"
