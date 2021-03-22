#!/bin/bash
# $ read_input buf <t.txt
read_input() {
  : "${1:?Must provide a variable to read into}"

  if [[ "$1" == '_line' || "$1" == '_contents' ]]; then
    echo "Cannot store contents to $1, use a different name." >&2
    return 1
  fi

  local _line _contents=()
   while IFS='' read -r _line; do
     _contents+=("$_line"$'\n')
   done
   # Include $_line once more to capture any content after the last newline
   printf -v "$1" '%s' "${_contents[@]}" "$_line"
}
