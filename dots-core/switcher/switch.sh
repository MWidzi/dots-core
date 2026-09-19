#!/bin/bash

rice_path="$1"

# 1. Kill services from current rice
current_programs_file="${2:-$HOME/.config/scripts/rice_switcher/programs.json}"

if [ -f "$current_programs_file" ]; then
    echo "Stopping running services..."

    mapfile -t services < <(jq -r '.services[]?' "$current_programs_file" 2>/dev/null)

    for item in "${services[@]}"; do
        bin="${item%% *}"
        echo "killing $bin..."
        pkill -x "$bin" 2>/dev/null || true
    done
fi

# 2. Map all directories in the rice
mapfile -t dirs < <(find "$rice_path" -mindepth 1 -maxdepth 1 -type d)

config_base="$HOME/.config"

# 3. Symlink standard configs (safely overwriting old ones)
for dir in "${dirs[@]}"; do
  basename_dir=$(basename "$dir")
  
  # Skip non-config folders
  if [[ ! "$basename_dir" =~ ^(vesktop|firefox|screenshots|\.git)$ ]]; then
    target="$config_base/$basename_dir"
    ln -sfn "$dir" "$target"
  fi
done

# 4. Handle Firefox seamlessly
echo "Linking Firefox config..."
# Parse profiles.ini to find the default profile path
PROFILE_DIR=$(awk -F '=' '/^\[Profile/ {in_profile=1} in_profile && /^Path=/ {path=$2} in_profile && /^Default=1/ {print path; exit}' ~/.mozilla/firefox/profiles.ini)

# Fallback just in case Default=1 is missing
if [ -z "$PROFILE_DIR" ]; then
    PROFILE_DIR=$(awk -F '=' '/^\[Profile/ {in_profile=1} in_profile && /^Path=/ {path=$2; print path; exit}' ~/.mozilla/firefox/profiles.ini)
fi

if [ -n "$PROFILE_DIR" ]; then
    TARGET_CHROME="$HOME/.mozilla/firefox/$PROFILE_DIR/chrome"
    
    mkdir -p "$TARGET_CHROME"
    
    ln -sfn "$rice_path/firefox/config.css" "$TARGET_CHROME/config.css"
    echo "Successfully linked Firefox config to $PROFILE_DIR"
else
    echo "Could not find a default Firefox profile."
fi

# 5. Inject Pywalfox mock colors
echo "Applying Firefox Theme via Pywalfox..."
mkdir -p "$HOME/.cache/wal"
if [ -f "$rice_path/firefox/pywalfox_colors.json" ]; then
    cp "$rice_path/firefox/pywalfox_colors.json" "$HOME/.cache/wal/colors.json"
    if command -v pywalfox >/dev/null 2>&1; then
        pywalfox update
        echo "Firefox theme updated via pywalfox!"
    else
        echo "pywalfox CLI not found. Please install: pip install pywalfox"
    fi
fi

# 6. Link vesktop themes
echo "Linking Vesktop themes..."

vesktop_theme_dir="$rice_path/vesktop/themes"

mkdir -p "$config_base/vesktop/themes"

find "$config_base/vesktop/themes" -maxdepth 1 -type l -delete

for theme in "$vesktop_theme_dir"/*; do
    [ -e "$theme" ] || continue
    ln -sfn "$theme" "$config_base/vesktop/themes/$(basename "$theme")"
done
echo "Successfully linked Vesktop themes from $vesktop_theme_dir"

# 7. Open programs from current rice
new_programs_file="${2:-$HOME/.config/scripts/rice_switcher/programs.json}"

if [ -f "$new_programs_file" ]; then
    mapfile -t new_services < <(jq -r '.services[]?' "$new_programs_file" 2>/dev/null)

    for cmd in "${new_services[@]}"; do
        echo "Starting service: $cmd"
        eval "$cmd" &
    done

    mapfile -t one_times < <(jq -r '.one_time[]? // .["one_time"][]?' "$new_programs_file" 2>/dev/null)

    for cmd in "${one_times[@]}"; do
        echo "Running: $cmd"
        eval "$cmd"
    done
fi

# 8. Reload the environment
hyprctl reload
