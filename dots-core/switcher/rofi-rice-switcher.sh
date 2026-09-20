#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
RICES_DIR="$DOTFILES_DIR/rices"
SWITCHER="$DOTFILES_DIR/dots-core/switcher/switch.sh"

if [ ! -d "$RICES_DIR" ]; then
    notify-send "Rice Switcher" "Error: rices directory not found at $RICES_DIR"
    exit 1
fi

selected=$(find "$RICES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | rofi -dmenu -p "Select Rice")

if [ -n "$selected" ]; then
    bash "$SWITCHER" "$selected"
fi
