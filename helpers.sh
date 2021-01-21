#!/usr/bin/env bash

# === awk vs gawk ===
# https://github.com/tmux-plugins/tmux-copycat/blob/d7f7e6c1de0bc0d6915f4beea5be6a8a42045c09/scripts/helpers.sh#L12
command_exists() {
  command -v "$@" > /dev/null 2>&1
}

AWK_CMD='awk'
if command_exists gawk; then
  AWK_CMD='gawk'
fi

# Ensures a message is displayed for 5 seconds in tmux prompt.
# Does not override the 'display-time' tmux option.
#
# https://github.com/tmux-plugins/tmux-copycat/blob/e95528ebaeb6300d8620c8748a686b786056f374/scripts/check_tmux_version.sh#L19
display_message() {
  local message="$1"

  # display_duration defaults to 5 seconds, if not passed as an argument
  if [ "$#" -eq 2 ]; then
    local display_duration="$2"
  else
    local display_duration="5000"
  fi

  # saves user-set 'display-time' option
  local saved_display_time
  saved_display_time=$(get_tmux_option "display-time" "750")

  # sets message display time to 5 seconds
  tmux set-option -gq display-time "$display_duration"

  # displays message
  tmux display-message "$message"

  # restores original 'display-time' value
  tmux set-option -gq display-time "$saved_display_time"
}


