# Pull in helpers
# shellcheck source=helpers.sh


get_line_number() {
  local position
  position=$(echo "$1" | cut -d':' -f2 | xargs)
  echo "$position"
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
  local linum total half_lines start end total
  match="$2"
  capture_file="$1"
  # head_file=$(get_head_filename)
  # tail_file=$(get_tail_filename)

  total=$(wc -l < "$capture_file")
  half_lines=$(( FZF_PREVIEW_LINES / 2))
  line_rev=$(get_line_number "$match")
  linum=$(reverse_n "$total" 0 "$line_rev")

  [[ $(( linum - half_lines )) -lt 1 ]] && start=1 || start=$(( linum - half_lines ))
  [[ $(( linum + half_lines )) -gt $total ]] && end=$total || end=$(( linum + half_lines ))
  [[ $start -eq 1 &&  $end -ne $total ]] && end=$FZF_PREVIEW_LINES
  sed -n "${start},${end}p" < "$capture_file"
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
