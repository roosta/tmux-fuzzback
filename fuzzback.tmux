#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=scripts/helpers.sh
. "$CURRENT_DIR/scripts/helpers.sh"

support_note() {
  "$CURRENT_DIR/scripts/supported.sh" "3.1" "" 0  # Pass 0 to suppress message
  return $?
}

key="$(tmux_get '@fuzzback-bind' '?')"
table="$(tmux_get '@fuzzback-table' 'prefix')"

if support_note; then
  tmux bind-key -N "Fuzzback through pane history" -T "$table" "$key" run -b "$CURRENT_DIR/scripts/fuzzback.sh";
else
  tmux bind-key -T "$table" "$key" run -b "$CURRENT_DIR/scripts/fuzzback.sh";
fi
