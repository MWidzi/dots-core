#!/bin/bash

options="mikuteto\ninabashell"
selected=$(echo -e "$options" | rofi -dmenu)
case "$selected" in
    "mikuteto")
        sh -c "~/.config/scripts/rice_switcher/switch.sh ~/dotfiles-Miku-Teto" ;;
    "inabashell")
        sh -c "~/.config/scripts/rice_switcher/switch.sh ~/inabashell" ;;
esac
