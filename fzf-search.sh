#!/usr/bin/env bash

fzf_cmd() {
    fzf-tmux --delimiter=":" --with-nth="2.." --ansi --no-preview
}

content="$(tmux capture-pane -e -J -p -S -)"
match=$(echo "$content" | tac | nl -b 'a' -s ':' | fzf_cmd)
line_nr=$(echo "$match" | cut -d':' -f1 | tr -d '[:space:]')
echo "$line_nr"
# echo $match
# line_nr=()
