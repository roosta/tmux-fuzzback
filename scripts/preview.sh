#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

REVERSE="\x1b[7m"
RESET="\x1b[m"

# Pull in helpers
# shellcheck source=helpers.sh
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$CURRENT_DIR/helpers.sh"

get_line_number() {
  local position
  position=$(echo "$1" | cut -d':' -f2 | xargs)
  echo "$position"
}

highlight_line() {
  local content linum
  content="$1"
  linum="$2"
  awk "{ \
    if (NR == $linum) \
      { gsub(/\x1b[[0-9;]*m/, \"&$REVERSE\"); printf(\"$REVERSE%s\n$RESET\", \$0); } \
      else printf(\"$RESET%s\n\", \$0); \
      }" <<< "$content"
}

reverse_n() {
  local max min num;
  max="$1"
  min="$2"
  num="$3"
  max_min=$((max + min))
  echo $((max_min - num));
}
preview() {
  local linum total half_lines start end total fuzzback_finder preview_lines
  fuzzback_finder="$(tmux_get '@fuzzback-finder' 'fzf')"
  match="$2"
  capture_file="$1"

  if [ "$fuzzback_finder" = "sk" ]; then
    preview_lines=$LINES
  else
    preview_lines=$FZF_PREVIEW_LINES
  fi

  # trim trailing newlines
  trimmed=$(printf "%s" "$(< "$capture_file")")

  total=$(wc -l <<< "$trimmed")
  half_lines=$(( preview_lines / 2))
  line_rev=$(get_line_number "$match")
  linum=$(reverse_n "$total" 1 "$line_rev")

  [[ $(( linum - half_lines )) -lt 1 ]] && start=1 || start=$(( linum - half_lines ))
  [[ $(( linum + half_lines )) -gt $total ]] && end=$total || end=$(( linum + half_lines ))
  [[ $start -eq 1 &&  $end -ne $total ]] && end=$preview_lines
  hl=$(highlight_line "$trimmed" "$linum")
  sed -n "${start},${end}p" <<< "$hl"
}

main() {
  if [ "$#" != "2" ]; then
    echo "preview.sh takes exactly two arguments" >&2;
    exit 1;
  else
    preview "$@"
  fi
}

main "$@"
