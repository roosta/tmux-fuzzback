#!/usr/bin/env bash

# Source: https://github.com/tmux-plugins/tmux-copycat/blob/master/scripts/check_tmux_version.sh

VERSION="$1"
UNSUPPORTED_MSG="$2"

fuzzback::tmux_option() {
  local option default_value option_value
  option=$1
  default_value=$2
  option_value=$(tmux show-option -gqv "$option")
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

# Ensures a message is displayed for 5 seconds in tmux prompt.
# Does not override the 'display-time' tmux option.
fuzzback::display() {
  local message display_duration saved_display_time
  message="$1"

  # display_duration defaults to 5 seconds, if not passed as an argument
  if [ "$#" -eq 2 ]; then
    display_duration="$2"
  else
    display_duration="5000"
  fi

  # saves user-set 'display-time' option
  saved_display_time=$(fuzzback::tmux_option "display-time" "750")

  # sets message display time to 5 seconds
  tmux set-option -gq display-time "$display_duration"

  # displays message
  tmux display-message "$message"

  # restores original 'display-time' value
  tmux set-option -gq display-time "$saved_display_time"
}

# this is used to get "clean" integer version number. Examples:
# `tmux 1.9` => `19`
# `1.9a`     => `19`
fuzzback::digits() {
  local string only_digits
  string="$1"
  only_digits="$(echo "$string" | tr -dC '[:digit:]')"
  echo "$only_digits"
}

fuzzback::version_int() {
  local tmux_version_string
  tmux_version_string=$(tmux -V)
  fuzzback::digits "$tmux_version_string"
}

fuzzback::unsupported_msg() {
  if [ -n "$UNSUPPORTED_MSG" ]; then
    echo "$UNSUPPORTED_MSG"
  else
    echo "fuzzback error: tmux version unsupported, please install version $VERSION or greater!"
  fi
}

fuzzback::check() {
  local current_version="$1"
  local supported_version="$2"
  if [ "$current_version" -lt "$supported_version" ]; then
    fuzzback::display "$(fuzzback::unsupported_msg)"
    exit 1
  fi
}

main() {
  local supported_version_int current_version_int
  supported_version_int="$(fuzzback::digits "$VERSION")"
  current_version_int="$(fuzzback::version_int)"
  fuzzback::check "$current_version_int" "$supported_version_int"
}
main
