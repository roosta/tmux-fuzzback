#!/usr/bin/env bash

fzf_cmd() {
    fzf-tmux --cycle --bind='ctrl-s:toggle-sort' --no-preview
}

content="$(tmux capture-pane -J -p -S -)"
echo "$content"
