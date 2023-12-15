#!/usr/bin/env bash
# shellcheck disable=SC2001

# Strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
IFS=$'\n\t'

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SUPPORTED_VERSION="2.4"

# Pull in helpers
# shellcheck source=helpers.sh
. "$CURRENT_DIR/helpers.sh"

CAPTURE_FILENAME="$(get_capture_filename)"

finder_split_cmd() {
  local fuzzback_finder="$3"
  local hide_preview="$5"
  local finder
  local preview_window=""
  if [ "$hide_preview" -eq 1 ];then
    preview_window=":hidden"
  fi

  finder='fzf-tmux'
  if [ "$fuzzback_finder" = "sk" ]; then
    finder='sk-tmux'
  fi
  "$finder" \
    --delimiter=":" \
    --ansi \
    --bind="$1" \
    --delimiter=":" \
    --layout="$finder_layout" \
    --no-multi \
    --print-query \
    --with-nth="3.." \
    --color="$4" \
    --preview="$CURRENT_DIR/preview.sh $CAPTURE_FILENAME {}" \
    --preview-window="$preview_window"
}

fzf_popup_cmd() {
  local hide_preview="$5"
  local preview_window=""
  if [ "$hide_preview" -eq 1 ];then
    preview_window=":hidden"
  fi

  fzf-tmux -p "$1" \
    --ansi \
    --bind="$2" \
    --delimiter=":" \
    --layout="$3" \
    --no-multi \
    --print-query \
    --with-nth="3.." \
    --color="$4" \
    --preview="$CURRENT_DIR/preview.sh $CAPTURE_FILENAME {}" \
    --preview-window="$preview_window"
}

rev_cmd() {
  if cmd_exists tac; then
    tac
  else
    tail -r
  fi
}

cursor_up() {
  local line_number
  line_number="$1"
  tmux send-keys -X -N "$line_number" cursor-up
}

cursor_down() {
  local line_number
  line_number="$1"
  tmux send-keys -X -N "$line_number" cursor-down
}

# https://github.com/tmux-plugins/tmux-copycat/blob/d7f7e6c1de0bc0d6915f4beea5be6a8a42045c09/scripts/copycat_jump.sh#L68
escape_backslash() {
  local string="$1"
  echo "$string" | sed 's/\\/\\\\/g'
}

# Get columns position of search query
# https://github.com/tmux-plugins/tmux-copycat/blob/d7f7e6c1de0bc0d6915f4beea5be6a8a42045c09/scripts/copycat_jump.sh#L73
query_column() {
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
  result_line="$(escape_backslash "$result_line")"
  query="$(escape_backslash "$query")"

  column=$($AWK_CMD -v a="$result_line" -v b="$query" 'BEGIN{print index(a,b)}')
  zero_index=$((column - 1))
  echo "$zero_index"
}

# maximum line number that can be reached via tmux goto-line
# https://github.com/tmux-plugins/tmux-copycat/blob/e95528ebaeb6300d8620c8748a686b786056f374/scripts/copycat_jump.sh#L159
get_max_jump() {
  local max_jump max_lines pane_height
  local max_lines="$1"
  local pane_height="$2"
  max_jump=$((max_lines - pane_height))
  # max jump can't be lower than zero
  if [ "$max_jump" -lt "0" ]; then
    max_jump="0"
  fi
  echo "$max_jump"
}

# Goto line in scrollback buffer
goto_line() {
  local correction
  local line_number="$1"
  local direction="$2"
  local max_jump="$3"
  local max_lines="$4"
  correction="0"

  if [ "$direction" -eq "1" ];then
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

    tmux send-keys -X goto-line "$correct_line_number"

    # Correct if needed
    if [ "$correction" -gt "0" ]; then
      local scroll_top="$(( max_lines - line_number - 1 ))"
      cursor_up "$max_lines"
      cursor_down "$scroll_top"
    fi

    # Centering
    # -------------
    # If no corrections (meaning result is not at the top of scrollback)
    # we can then 'center' the result within a pane.
    if [ "$correction" -eq "0" ]; then
      local half_pane_height="$((pane_height / 2))"
      # creating as much padding as possible, up to half pane height
      center "$line_number" "$half_pane_height"
    fi
  else
    tmux send-keys -X goto-line "0"
    cursor_down "$(( line_number + 1))"
  fi

}

goto_column() {
  local column="$1"
  tmux send-keys -X start-of-line
  if [ "$column" -gt "0" ]; then
    tmux send-keys -X -N "$column" cursor-right
  fi
}

# Center result on screen
# https://github.com/tmux-plugins/tmux-copycat/blob/e95528ebaeb6300d8620c8748a686b786056f374/scripts/copycat_jump.sh#L127
center() {
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

get_line_number() {
  local position line_number
  position=$(echo "$1" | cut -d':' -f2 | xargs)
  line_number=$((position - 1))
  echo "$line_number"
}

# Direction to move is stored in results at pos 1
get_direction() {
  local direction
  direction=$(echo "$1" | cut -d':' -f1 | xargs)
  echo "$direction"
}

# Get the cursor y position when starting fuzzback
get_pos() {
  local cursor_y
  cursor_y=$(tmux display -p '#{cursor_y}')
  echo "$cursor_y"
}

# Store captured scrollback in temp file
create_capture_file() {
	mkdir -p "$(get_tmp_dir)"
	chmod 0700 "$(get_tmp_dir)"
  tmux capture-pane -e -p -S - > "$CAPTURE_FILENAME"
}

# Create a file that is the head of the scrollback. Ends where the cursor y
# position was when fuzzback was started
create_head_file() {
  local head_n="$1"
  local head_filename
  head_filename="$(get_head_filename)"
  head -n "$head_n" < "$CAPTURE_FILENAME" \
    | rev_cmd \
    | nl -b 'a' -s ':' \
    | sed 's/^/1:/' \
    | sed '1s/$/[m/' \
    > "$head_filename"
}

# Create a file that is the content below cursor then starting fuzzback
create_tail_file() {
  local tail_n="$1"
  local tail_filename trimmed
  tail_filename="$(get_tail_filename)"
  tmp_filename="$(get_tmp_filename)"
  tail -n "$tail_n" < "$CAPTURE_FILENAME" > "$tmp_filename"
  trimmed=$(cat "$tmp_filename")
  if [ -z "$trimmed" ]; then
    echo "$trimmed" > "$tail_filename"
  else
    nl -b 'a' -s ':' < "$tmp_filename" \
      | rev_cmd \
      | sed 's/^/-1:/' \
      | sed 's/$/[m/' \
      > "$tail_filename"
  fi
  rm -f "$tmp_filename"
}

fuzzback() {
  local match line_number pane_height query max_lines max_jump
  local correct_line_number trimmed_line column pos pos_rev
  local capture_height head_n tail_n
  local enable_popup popup_size finder_bind finder_layout

  create_capture_file

  # Options
  enable_popup="$(tmux_get '@fuzzback-popup' 0)"
  popup_size="$(tmux_get '@fuzzback-popup-size' "50%")"
  finder_bind="$(tmux_get '@fuzzback-finder-bind' 'ctrl-y:accept')"
  finder_layout="$(tmux_get '@fuzzback-finder-layout' 'default')"
  fuzzback_finder="$(tmux_get '@fuzzback-finder' 'fzf')"
  fzf_colors="$(tmux_get '@fuzzback-fzf-colors' 'dark')"
  fzf_hide_preview="$(tmux_get '@fuzzback-hide-preview' 0)"

  pos=$(get_pos)
  pane_height="$(tmux display-message -p '#{pane_height}')"
  pos_rev=$(( pane_height - pos ))
  head_file=$(get_head_filename)
  tail_file=$(get_tail_filename)
  capture_height=$(wc -l < "$CAPTURE_FILENAME")
  head_n=$(( capture_height - pos_rev + 1 ))
  tail_n=$(( pos_rev - 1 ))

  # We need to create two separate files to account for upward and downward
  # movement when starting fuzzback, scrollback movement is relative to start
  # cursor_y position
  create_head_file "$head_n"
  create_tail_file "$tail_n"

  # Combine head and tail when searching with fzf
  if [ "$enable_popup" -eq 1 ];then
    match=$(cat "$tail_file" "$head_file" | fzf_popup_cmd "$popup_size" "$finder_bind" "$finder_layout" "$fzf_colors" "$fzf_hide_preview")
  else
    match=$(cat "$tail_file" "$head_file" | finder_split_cmd "$finder_bind" "$finder_layout" "$fuzzback_finder" "$fzf_colors" "$fzf_hide_preview")
  fi

  if [ "$(echo "$match" | wc -l)" -gt "1" ]; then
    query="$(head -n 1 <<< "$match")"
    rest="$(tail -n 1 <<< "$match")"
    trimmed_line=$(echo "$rest" | sed -E 's/-?[0-9]+: +[0-9]+://')
    line_number=$(get_line_number "$rest")
    direction=$(get_direction "$rest")
    column=$(query_column "$query" "$trimmed_line")

    max_lines=$(wc -l < "$head_file")
    max_jump=$(get_max_jump "$max_lines" "$pane_height")

    # Quit copy-mode before starting a new fuzzback session. This solves issues
    # with starting fuzzback when already in copy-mode
    tmux copy-mode -q

    tmux copy-mode

    # Move to position
    goto_line "$line_number" "$direction" "$max_jump" "$max_lines"
    goto_column "$column"

  fi
  delete_old_files
}

version_ok() {
  "$CURRENT_DIR/supported.sh" "$SUPPORTED_VERSION"
}

main() {
  if version_ok; then
    fuzzback
  fi
}

main
