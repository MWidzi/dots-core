#!/bin/bash

options="󰮯\n󰣇\n\n\n\n"
selected=$(echo -e "$options" | rofi -dmenu -theme-str 'window {width: 700px;} listview {columns: 3; lines: 2;}')
case "$selected" in
    "󰮯")
        kitty --class floating-kitty ~/.config/scripts/rofi-menu-scripts/omarchy-pkg-install.sh ;;
    "󰣇")
        kitty --class floating-kitty ~/.config/scripts/rofi-menu-scripts/omarchy-pkg-aur-install.sh ;;
    "")
        ~/.config/scripts/rofi-menu-scripts/rofi-submenu-dirs.sh ;;
    "")
        kitty sh -c "~/.config/scripts/rofi-menu-scripts/nvimWrapper.sh;" ;;
    "")
        ~/.config/scripts/rofi-menu-scripts/rofi-submenu-autism.sh ;;
    "")
        ~/.config/scripts/rofi-menu-scripts/rofi_clipboard.sh ;;
esac
