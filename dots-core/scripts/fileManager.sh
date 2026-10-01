#!/usr/bin/env bash

set -u
set -o pipefail

tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
live_tmp="$(mktemp -t "yazi-live-cwd.XXXXXX")"
trap 'rm -f "$tmp" "$live_tmp"' EXIT

env EDITOR=nvim VISUAL=nvim kitty --title yazi -e bash -c '
  target_entry=""
  while true; do
    if [ -n "$target_entry" ]; then
      YAZI_LIVE_CWD_FILE="'"$live_tmp"'" yazi "$target_entry" --cwd-file="'"$tmp"'"
    else
      YAZI_LIVE_CWD_FILE="'"$live_tmp"'" yazi "$@" --cwd-file="'"$tmp"'"
    fi
    ret=$?
    if [ "$ret" -eq 138 ]; then
      if [ -f "'"$live_tmp"'" ]; then
        last_cwd="$(cat "'"$live_tmp"'" 2>/dev/null || true)"
        if [ -n "$last_cwd" ] && [ -d "$last_cwd" ]; then
          target_entry="$last_cwd"
        fi
      fi
      continue
    fi
    break
  done
' bash "$@" || true

cwd="$(cat "$tmp" 2>/dev/null || cat "$live_tmp" 2>/dev/null || echo "")"

if [ -z "$cwd" ] || [ "$cwd" = "$HOME" ]; then
  exit 0
fi

exec env EDITOR=nvim VISUAL=nvim kitty --directory "$cwd"
