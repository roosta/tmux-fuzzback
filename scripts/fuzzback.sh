#!/usr/bin/env bash
# shellcheck disable=SC2001

# Strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
IFS=$'\n\t'

# Pull in helpers
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUPPORTED_VERSION="2.3"

# https://github.com/tmux-plugins/tmux-copycat/blob/d7f7e6c1de0bc0d6915f4beea5be6a8a42045c09/scripts/helpers.sh#L12
fuzzback::cmd_exists() {
  command -v "$@" > /dev/null 2>&1
}

# Fall back to awk if gawk isn't present on system
AWK_CMD='awk'
if fuzzback::cmd_exists gawk; then
  AWK_CMD='gawk'
fi

fuzzback::fzf_cmd() {
  fzf-tmux --delimiter=":" \
           --ansi \
           --with-nth="2.." \
           --no-multi \
           --no-sort \
           --no-preview \
           --print-query
}

# Move cursor up in scrollback buffer, used when goto_line fails and we have to
# correct
fuzzback::cursor_up() {
  local line_number
  line_number="$1"
  tmux send-keys -X -N "$line_number" cursor-up
}

# https://github.com/tmux-plugins/tmux-copycat/blob/d7f7e6c1de0bc0d6915f4beea5be6a8a42045c09/scripts/copycat_jump.sh#L68
fuzzback::escape_backslash() {
  local string="$1"
  echo "$string" | sed 's/\\/\\\\/g'
}

# Get columns position of search query
# https://github.com/tmux-plugins/tmux-copycat/blob/d7f7e6c1de0bc0d6915f4beea5be6a8a42045c09/scripts/copycat_jump.sh#L73
fuzzback::query_column() {
  local query="$1"
  local result_line="$2"
  local column zero_index platform

  # OS X awk cannot have `=` as the first char in the variable (bug in awk).
  # If exists, changing the `=` character with `.` to avoid error.
  platform="$(uname)"
  if [ "$platform" == "Darwin" ]; then
    result_line="$(echo "$result_line" | sed 's/^=/./')"
    query="$(echo "$query" | sed 's/^=/./')"
  fi

  # awk treats \r, \n, \t etc as single characters and that messes up match
  # highlighting. For that reason, we're escaping backslashes so above chars
  # are treated literally.
  result_line="$(fuzzback::escape_backslash "$result_line")"
  query="$(fuzzback::escape_backslash "$query")"

  column=$($AWK_CMD -v a="$result_line" -v b="$query" 'BEGIN{print index(a,b)}')
  zero_index=$((column - 1))
  echo "$zero_index"
}

# maximum line number that can be reached via tmux goto-line
# https://github.com/tmux-plugins/tmux-copycat/blob/e95528ebaeb6300d8620c8748a686b786056f374/scripts/copycat_jump.sh#L159
fuzzback::get_max_jump() {
  local max_jump max_lines window_height
  local max_lines="$1"
  local window_height="$2"
  max_jump=$((max_lines - window_height))
  # max jump can't be lower than zero
  if [ "$max_jump" -lt "0" ]; then
    max_jump="0"
  fi
  echo "$max_jump"
}

# Goto line in scrollback buffer
fuzzback::goto_line() {
  local line_number="$1"
  tmux send-keys -X goto-line "$line_number"
}

# Center result on screen
# https://github.com/tmux-plugins/tmux-copycat/blob/e95528ebaeb6300d8620c8748a686b786056f374/scripts/copycat_jump.sh#L127
fuzzback::center() {
  local number_of_lines="$1"
  local maximum_padding="$2"
  local padding

  # Padding should not be greater than half pane height
  # (it wouldn't be centered then).
  if [ "$number_of_lines" -gt "$maximum_padding" ]; then
    padding="$maximum_padding"
  else
    padding="$number_of_lines"
  fi

  # cannot create padding, exit function
  if [ "$padding" -eq "0" ]; then
    return
  fi

  tmux send-keys -X -N "$padding" cursor-down
  tmux send-keys -X -N "$padding" cursor-up
}

fuzzback::get_line_number() {
  local position line_number
  position=$(echo "$1" | cut -d':' -f1 | xargs)
  line_number=$((position - 1))
  echo "$line_number"
}

fuzzback() {

  local content match line_number window_height query max_lines max_jump
  local correction correct_line_number trimmed_line column

  content="$(tmux capture-pane -e -p -S -)"
  match=$(echo "$content" | tac | nl -b 'a' -s ':' | fuzzback::fzf_cmd)

  if [ -n "$match" ]; then
    readarray -t match <<< "$match"
    query="${match[0]}"
    rest="${match[1]}"
    trimmed_line=$(echo "$rest" | sed 's/[[:space:]]\+[[:digit:]]\+://')
    line_number=$(fuzzback::get_line_number "$rest")
    window_height="$(tmux display-message -p '#{pane_height}')"
    max_lines=$(echo "$content" | wc -l)
    max_jump=$(fuzzback::get_max_jump "$max_lines" "$window_height")
    correction="0"
    column=$(fuzzback::query_column "$query" "$trimmed_line")

    # To go line
    # -----------------
    if [ "$line_number" -gt "$max_jump" ]; then
      # We need to reach a line number that is not accessible via goto-line.
      # So we need to correct position to reach the desired line number
      correct_line_number="$max_jump"
      correction=$((line_number - correct_line_number))
    else
      # we can reach the desired line number via goto-line. Correction not
      # needed.
      correct_line_number="$line_number"
    fi

    tmux copy-mode
    fuzzback::goto_line "$correct_line_number"

    # Correct if needed
    if [ "$correction" -gt "0" ]; then
      fuzzback::cursor_up "$correction"
    fi

    # Set cursor to start of line when all vertical movement is done
    tmux send-keys -X start-of-line

    # Centering
    # -------------
    # If no corrections (meaning result is not at the top of scrollback)
    # we can then 'center' the result within a pane.
    if [ "$correction" -eq "0" ]; then
      local half_window_height="$((window_height / 2))"
      # creating as much padding as possible, up to half pane height
      fuzzback::center "$line_number" "$half_window_height"
    fi

    # Move to column
    # ------------------
    if [ "$column" -gt "0" ]; then
      tmux send-keys -X -N "$column" cursor-right
    fi

  fi
}

fuzzback::version_ok() {
  "$CURRENT_DIR/supported.sh" "$SUPPORTED_VERSION"
}

main() {
  if fuzzback::version_ok; then
    fuzzback
  fi
}

main
