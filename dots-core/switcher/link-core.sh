#!/usr/bin/env bash
# ==============================================================================
# UNIFIED CORE DOTFILES LINKER
# Location: ~/dotfiles/dots-core/switcher/link-core.sh
# Purpose: Establishes permanent shared core configuration symlinks in ~/.config.
# Run this ONCE on initial setup, or when adding a new shared program to dots-core.
# ==============================================================================
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CORE_DIR="$DOTFILES_DIR/dots-core"
CONFIG_BASE="$HOME/.config"

echo "==> Establishing permanent shared core configs from $CORE_DIR..."

# Dynamically iterate over every application directory in dots-core
for dir_path in "$CORE_DIR"/*/; do
    [ -d "$dir_path" ] || continue
    app=$(basename "$dir_path")

    [ "$app" = "switcher" ] && continue

    echo "  -> Linking core files for: $app"

    if [ -L "$CONFIG_BASE/$app" ]; then
        rm "$CONFIG_BASE/$app"
    fi
    mkdir -p "$CONFIG_BASE/$app"

    for item in "$dir_path"* "$dir_path".[!.]*; do
        [ -e "$item" ] || continue
        ln -sfn "$item" "$CONFIG_BASE/$app/$(basename "$item")"
    done
done

echo "==> Permanent core setup complete!"
