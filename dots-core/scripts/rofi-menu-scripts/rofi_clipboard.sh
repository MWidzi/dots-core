#!/usr/bin/bash

env WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
cliphist list | rofi -dmenu -display-columns 2 -theme-str 'window {width: 800px; orientation: horizontal;} listview {lines: 7; columns: 1;} element-text { font: "Mononoki Nerd Font 14"; } element { padding: 10px; }' | \
cliphist decode | wl-copy

if [ -n "$selection" ]; then
  echo "$selection" | cliphist decode | wl-copy
fi
