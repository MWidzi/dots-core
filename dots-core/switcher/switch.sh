#!/usr/bin/env bash
# ==============================================================================
# DYNAMIC MULTI-RICE SWITCHER ENGINE
# Location: ~/dotfiles/dots-core/switcher/switch.sh
# Usage:
#   switch.sh inabashell
#   switch.sh miku-teto
#   switch.sh everforest-dots
# ==============================================================================
set -euo pipefail

TARGET_INPUT="${1:-}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CORE_DIR="$DOTFILES_DIR/dots-core"
RICES_DIR="$DOTFILES_DIR/rices"
CONFIG_BASE="$HOME/.config"
STATE_DIR="$CONFIG_BASE/rice"

if [ -z "$TARGET_INPUT" ]; then
    echo "Usage: $0 <rice_name_or_path>"
    echo "Available rices in $RICES_DIR:"
    find "$RICES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | sed 's/^/  - /'
    exit 1
fi

# Resolve target directory whether given as a name or a path
if [ -d "$RICES_DIR/$TARGET_INPUT" ]; then
    TARGET_RICE_DIR="$RICES_DIR/$TARGET_INPUT"
    RICE_NAME="$TARGET_INPUT"
elif [ -d "$TARGET_INPUT" ]; then
    TARGET_RICE_DIR="$(realpath "$TARGET_INPUT")"
    RICE_NAME="$(basename "$TARGET_RICE_DIR")"
elif [ -d "$HOME/$TARGET_INPUT" ]; then
    TARGET_RICE_DIR="$HOME/$TARGET_INPUT"
    RICE_NAME="$TARGET_INPUT"
else
    echo "Error: Rice directory not found for '$TARGET_INPUT' in $RICES_DIR"
    exit 1
fi

mkdir -p "$STATE_DIR"
OLD_RICE=""
if [ -f "$STATE_DIR/current" ]; then
    OLD_RICE="$(cat "$STATE_DIR/current")"
fi

echo "==> Switching rice from '${OLD_RICE:-none}' to '$RICE_NAME'..."

# ------------------------------------------------------------------------------
# 1. Terminate services exclusive to the previous rice
# ------------------------------------------------------------------------------
if [ -n "$OLD_RICE" ] && [ -f "$RICES_DIR/$OLD_RICE/manifest.json" ]; then
    echo "Stopping previous rice services..."
    mapfile -t old_services < <(jq -r '.services[]?' "$RICES_DIR/$OLD_RICE/manifest.json" 2>/dev/null || true)
    for item in "${old_services[@]}"; do
        bin="${item%% *}"
        [ -n "$bin" ] && pkill -x "$bin" 2>/dev/null || true
    done
fi

# ------------------------------------------------------------------------------
# 2. Update Global Rice State
# ------------------------------------------------------------------------------
echo "$RICE_NAME" > "$STATE_DIR/current"
echo "$TARGET_RICE_DIR" > "$STATE_DIR/current_path"
ln -sfn "$TARGET_RICE_DIR" "$STATE_DIR/active"

# ------------------------------------------------------------------------------
# 3. Dynamic Whole-Folder Per-Rice Linking
# Any folder in the rice that is NOT managed by dots-core gets linked as a whole.
# Stale whole-folder symlinks pointing to old rices are automatically removed.
# ------------------------------------------------------------------------------
echo "Updating visual components..."

# Clean up stale whole-folder symlinks pointing to previous rices
for link in "$CONFIG_BASE"/*; do
    if [ -L "$link" ]; then
        dest=$(readlink "$link" || true)
        if [[ "$dest" == "$RICES_DIR"/* ]]; then
            app=$(basename "$link")
            if [ ! -d "$TARGET_RICE_DIR/$app" ]; then
                rm "$link"
            fi
        fi
    fi
done

# Dynamically link whole-folder components present in the new rice
for dir_path in "$TARGET_RICE_DIR"/*/; do
    [ -d "$dir_path" ] || continue
    app=$(basename "$dir_path")

    # Skip core-managed apps and special directories (handled separately)
    [ -d "$CORE_DIR/$app" ] && continue
    [[ "$app" =~ ^(firefox|screenshots|\.git)$ ]] && continue

    ln -sfn "$dir_path" "$CONFIG_BASE/$app"
done

# ------------------------------------------------------------------------------
# 4. Hybrid Subdirectory Themes (btop, rmpc, vesktop)
# For apps with a themes/ subfolder, populate ~/.config/<app>/themes/
# ------------------------------------------------------------------------------
for app in btop rmpc vesktop; do
    if [ -d "$TARGET_RICE_DIR/$app/themes" ]; then
        mkdir -p "$CONFIG_BASE/$app/themes"
        find "$CONFIG_BASE/$app/themes" -maxdepth 1 -type l -delete
        for theme_file in "$TARGET_RICE_DIR/$app/themes"/*; do
            [ -e "$theme_file" ] || continue
            ln -sfn "$theme_file" "$CONFIG_BASE/$app/themes/$(basename "$theme_file")"
        done
    fi
done

# ------------------------------------------------------------------------------
# 5. Single-File Theme Injections into Hybrid Configs
# Injects individual theme files into existing ~/.config/<app>/ directories
# ------------------------------------------------------------------------------
declare -A THEME_FILES=(
    ["kitty/theme.conf"]="kitty/theme.conf"
    ["yazi/theme.toml"]="yazi/theme.toml"
    ["nvim/palette.lua"]="nvim/lua/config/themes/palette.lua"
    ["hypr/hyprlock.conf"]="hypr/hyprlock.conf"
    ["colors.css"]="colors.css"
)

for src in "${!THEME_FILES[@]}"; do
    dest="${THEME_FILES[$src]}"
    target_dest="$CONFIG_BASE/$dest"
    if [ -f "$TARGET_RICE_DIR/$src" ]; then
        mkdir -p "$(dirname "$target_dest")"
        ln -sfn "$TARGET_RICE_DIR/$src" "$target_dest"
    elif [ -L "$target_dest" ]; then
        rm "$target_dest"
    fi
done

# ------------------------------------------------------------------------------
# 6. Zsh Theme & Prompt Injections
# Links all theme and prompt configurations present in rice/zsh/ into ~/.config/zsh/
# ------------------------------------------------------------------------------
if [ -d "$TARGET_RICE_DIR/zsh" ]; then
    mkdir -p "$CONFIG_BASE/zsh"
    for zsh_file in "$TARGET_RICE_DIR/zsh"/* "$TARGET_RICE_DIR/zsh"/.[!.]*; do
        [ -e "$zsh_file" ] || continue
        ln -sfn "$zsh_file" "$CONFIG_BASE/zsh/$(basename "$zsh_file")"
    done
fi

# ------------------------------------------------------------------------------
# 7. Unique Program Handlers (Firefox & Spicetify)
# ------------------------------------------------------------------------------
# Firefox: Textfox userChrome CSS & Pywalfox mock cache
if [ -f "$HOME/.mozilla/firefox/profiles.ini" ] && [ -f "$TARGET_RICE_DIR/firefox/config.css" ]; then
    profile_dir=$(awk -F '=' '/^\[Profile/ {in_profile=1} in_profile && /^Path=/ {path=$2} in_profile && /^Default=1/ {print path; exit}' "$HOME/.mozilla/firefox/profiles.ini" || true)
    [ -z "$profile_dir" ] && profile_dir=$(awk -F '=' '/^\[Profile/ {in_profile=1} in_profile && /^Path=/ {path=$2; print path; exit}' "$HOME/.mozilla/firefox/profiles.ini" || true)

    if [ -n "$profile_dir" ]; then
        target_chrome="$HOME/.mozilla/firefox/$profile_dir/chrome"
        mkdir -p "$target_chrome"
        ln -sfn "$TARGET_RICE_DIR/firefox/config.css" "$target_chrome/config.css"
    fi
fi

if [ -f "$TARGET_RICE_DIR/firefox/pywalfox_colors.json" ]; then
    mkdir -p "$HOME/.cache/wal"
    cp "$TARGET_RICE_DIR/firefox/pywalfox_colors.json" "$HOME/.cache/wal/colors.json"
    command -v pywalfox >/dev/null 2>&1 && pywalfox update || true
fi

# Spicetify: Trigger theme apply if installed
if [ -d "$TARGET_RICE_DIR/spicetify" ] && command -v spicetify >/dev/null 2>&1; then
    echo "Applying Spicetify..."
    spicetify apply 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 8. Hyprland Hot-Reload (Lua Engine reads ~/.config/rice/current dynamically)
# ------------------------------------------------------------------------------
echo "Reloading Hyprland..."
hyprctl reload || true

# ------------------------------------------------------------------------------
# 9. Launch New Rice Manifest Commands & Background Services
# ------------------------------------------------------------------------------
if [ -f "$TARGET_RICE_DIR/manifest.json" ]; then
    mapfile -t one_times < <(jq -r '.one_time[]?' "$TARGET_RICE_DIR/manifest.json" 2>/dev/null || true)
    for cmd in "${one_times[@]}"; do
        echo "Executing: $cmd"
        eval "$cmd" || true
    done

    mapfile -t new_services < <(jq -r '.services[]?' "$TARGET_RICE_DIR/manifest.json" 2>/dev/null || true)
    for cmd in "${new_services[@]}"; do
        echo "Spawning service: $cmd"
        eval "$cmd" &
    done
fi

# ------------------------------------------------------------------------------
# 10. Hot-Reload Open Applications
# ------------------------------------------------------------------------------
pkill -SIGUSR1 -u "$USER" kitty 2>/dev/null || true
pkill -USR2 cava 2>/dev/null || true

if command -v swaync-client >/dev/null 2>&1; then
    swaync-client -R 2>/dev/null || true
    swaync-client -rs 2>/dev/null || true
fi

echo "==> Successfully switched to '$RICE_NAME'!"
