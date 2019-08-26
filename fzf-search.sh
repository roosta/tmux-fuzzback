#!/usr/bin/env bash

_fzf_cmd() {
    fzf-tmux --delimiter=":" --ansi --with-nth="2.." --no-preview
}

_enter_mode() {
	tmux copy-mode
}

main() {
  local conten, match, line_number corrected
  content="$(tmux capture-pane -e -J -p -S -)"
  match=$(echo "$content" | tac | nl -b 'a' -s ':' | _fzf_cmd)
  line_number=$(echo "$match" | cut -d':' -f1 | tr -d '[:space:]')
  corrected=$((line_number - 1))

  _enter_mode
  tmux send-keys -X goto-line "$corrected"
}

main
