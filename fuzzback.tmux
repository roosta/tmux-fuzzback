#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck source=scripts/helpers.sh
. "$CURRENT_DIR/scripts/helpers.sh"

key="$(tmux_get '@fuzzback-bind' '?')"
table="$(tmux_get '@fuzzback-table' 'prefix')"

tmux bind-key -N "Fuzzback through pane history" -T "$table" "$key" run -b "$CURRENT_DIR/scripts/fuzzback.sh";
