#!/bin/bash

options="\n\n󱁿\n"
selected=$(echo -e "$options" | rofi -dmenu -theme-str 'window {width: 700px;} listview {columns: 4;}')

case "$selected" in
    "")
        kitty -d ~/.config ;;
    "")
        kitty -d ~/Documents/Programming ;;
    "󱁿")
        kitty -d ~/.config ;;
    "")
        ~/.config/scripts/fileManager.sh ~/.local/share/Trash/files ;;
esac
