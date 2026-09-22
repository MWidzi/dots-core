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
    [[ "$app" =~ ^(firefox|screenshots|\.git|spicetify)$ ]] && continue

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
# 5. Hyprland Rice Injections
# Links all rice-specific Hyprland configurations into ~/.config/hypr/
# ------------------------------------------------------------------------------
if [ -d "$CONFIG_BASE/hypr" ]; then
    # Clean up stale rice-specific symlinks in ~/.config/hypr pointing to other rices
    for link in "$CONFIG_BASE/hypr"/*; do
        if [ -L "$link" ]; then
            dest=$(readlink "$link" || true)
            if [[ "$dest" == "$RICES_DIR"/* ]]; then
                file=$(basename "$link")
                if [ ! -e "$TARGET_RICE_DIR/hypr/$file" ]; then
                    rm "$link"
                fi
            fi
        fi
    done
fi

if [ -d "$TARGET_RICE_DIR/hypr" ]; then
    mkdir -p "$CONFIG_BASE/hypr"
    for hypr_file in "$TARGET_RICE_DIR/hypr"/*; do
        [ -e "$hypr_file" ] || continue
        ln -sfn "$hypr_file" "$CONFIG_BASE/hypr/$(basename "$hypr_file")"
    done
fi

# ------------------------------------------------------------------------------
# 6. Single-File Theme Injections into Hybrid Configs
# Injects individual theme files into existing ~/.config/<app>/ directories
# ------------------------------------------------------------------------------
declare -A THEME_FILES=(
    ["kitty/theme.conf"]="kitty/theme.conf"
    ["yazi/theme.toml"]="yazi/theme.toml"
    ["nvim/palette.lua"]="nvim/lua/config/themes/palette.lua"
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
# 7. Zsh Theme & Prompt Injections
# Links all theme and prompt configurations present in rice/zsh/ into ~/.config/zsh/
# ------------------------------------------------------------------------------
if [ -d "$TARGET_RICE_DIR/zsh" ]; then
    mkdir -p "$CONFIG_BASE/zsh"
    for zsh_file in "$TARGET_RICE_DIR/zsh"/* "$TARGET_RICE_DIR/zsh"/.[!.]*; do
        [ -e "$zsh_file" ] || continue
        ln -sfn "$zsh_file" "$CONFIG_BASE/zsh/$(basename "$zsh_file")"
    done
fi

# Helper for launching apps on specific workspaces in Hyprland (supports both Lua & legacy syntax)
hypr_exec() {
    local cmd="$1"
    local ws="${2:-}"
    if [ -n "$ws" ]; then
        hyprctl dispatch "hl.dsp.exec_cmd(\"[workspace $ws silent] $cmd\")" >/dev/null 2>&1 || \
        hyprctl dispatch exec "[workspace $ws silent] $cmd" >/dev/null 2>&1 || \
        gtk-launch "$cmd" >/dev/null 2>&1 || \
        nohup $cmd >/dev/null 2>&1 &
    else
        hyprctl dispatch "hl.dsp.exec_cmd(\"$cmd\")" >/dev/null 2>&1 || \
        hyprctl dispatch exec "$cmd" >/dev/null 2>&1 || \
        gtk-launch "$cmd" >/dev/null 2>&1 || \
        nohup $cmd >/dev/null 2>&1 &
    fi
}

# ------------------------------------------------------------------------------
# 8. Unique Program Handlers (Firefox & Spicetify)
# ------------------------------------------------------------------------------
# Firefox: Textfox userChrome CSS & Pywalfox mock cache
if [ -f "$TARGET_RICE_DIR/firefox/config.css" ]; then
    for profile_dir in "$HOME/.mozilla/firefox"/*/; do
        if [ -d "$profile_dir/chrome" ] || [ -f "$profile_dir/prefs.js" ]; then
            mkdir -p "$profile_dir/chrome"
            ln -sfn "$TARGET_RICE_DIR/firefox/config.css" "$profile_dir/chrome/config.css"
        fi
    done
fi

if [ -f "$TARGET_RICE_DIR/firefox/pywalfox_colors.json" ]; then
    mkdir -p "$HOME/.cache/wal"
    cp "$TARGET_RICE_DIR/firefox/pywalfox_colors.json" "$HOME/.cache/wal/colors.json"
    command -v pywalfox >/dev/null 2>&1 && pywalfox update 2>/dev/null || true
fi

# Hot-restart Firefox to apply Textfox userChrome CSS while preserving workspace and session
if pgrep -x firefox >/dev/null 2>&1; then
    echo "Reloading Firefox with updated theme..."
    ff_ws=$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.class == "firefox" or .initialClass == "firefox")][0].workspace.id // empty' 2>/dev/null || true)
    pkill -TERM -x firefox 2>/dev/null || true
    for _ in {1..40}; do
        pgrep -x firefox >/dev/null 2>&1 || break
        sleep 0.1
    done
    sleep 0.3
    hypr_exec "firefox" "$ff_ws"
fi

# Spicetify: Link theme files and apply
if [ -d "$TARGET_RICE_DIR/spicetify" ] && command -v spicetify >/dev/null 2>&1; then
    echo "Applying Spicetify..."
    if [ -d "$TARGET_RICE_DIR/spicetify/Themes" ]; then
        mkdir -p "$CONFIG_BASE/spicetify/Themes"
        for theme_dir in "$TARGET_RICE_DIR/spicetify/Themes"/*; do
            [ -d "$theme_dir" ] || continue
            theme_name=$(basename "$theme_dir")
            rm -rf "$CONFIG_BASE/spicetify/Themes/$theme_name"
            ln -sfn "$theme_dir" "$CONFIG_BASE/spicetify/Themes/$theme_name"
        done
    fi


    # Hot-reload if Spotify is currently running, or apply without launching if closed
    if pgrep -x spotify >/dev/null 2>&1; then
        sp_ws=$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.class == "Spotify" or .class == "spotify" or .initialClass == "Spotify")][0].workspace.id // empty' 2>/dev/null || true)
        pkill -x spotify 2>/dev/null || true
        for _ in {1..20}; do
            pgrep -x spotify >/dev/null 2>&1 || break
            sleep 0.1
        done
        spicetify apply -n 2>/dev/null || true
        hypr_exec "spotify" "$sp_ws"
    else
        spicetify apply -n 2>/dev/null || true
    fi
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
        eval "$cmd" >/dev/null 2>&1 || true
    done

    mapfile -t new_services < <(jq -r '.services[]?' "$TARGET_RICE_DIR/manifest.json" 2>/dev/null || true)
    for cmd in "${new_services[@]}"; do
        echo "Spawning service: $cmd"
        eval "$cmd" >/dev/null 2>&1 &
    done
fi

# ------------------------------------------------------------------------------
# 10. Hot-Reload Open Applications
# ------------------------------------------------------------------------------
pkill -SIGUSR1 -u "$USER" kitty 2>/dev/null || true
pkill -USR2 -u "$USER" cava 2>/dev/null || true
pkill -SIGUSR2 -u "$USER" btop 2>/dev/null || true
pkill -USR1 -u "$USER" yazi 2>/dev/null || true

# Hot-reload running Neovim instances via active RPC sockets
for sock in /run/user/"$UID"/nvim.*.0; do
    [ -S "$sock" ] || continue
    pid=$(basename "$sock" | cut -d. -f2)
    if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$sock"
        continue
    fi
    nvim --server "$sock" --remote-send '<Cmd>lua local p = dofile(vim.fn.stdpath("config") .. "/lua/config/themes/palette.lua"); if p and p.config then p.config() end; package.loaded["palette.highlights"] = nil; package.loaded["palette.theme"] = nil; package.loaded["palette.colors"] = nil; package.loaded["palette.utils"] = nil; require("palette").load(); if package.loaded["lualine"] then require("lualine").setup({ options = { theme = _G.lualine_theme or "auto" } }) end; vim.cmd("redraw!")<CR>' 2>/dev/null || true
done

if command -v swaync-client >/dev/null 2>&1; then
    swaync-client -R 2>/dev/null || true
    swaync-client -rs 2>/dev/null || true
fi

echo "==> Successfully switched to '$RICE_NAME'!"
