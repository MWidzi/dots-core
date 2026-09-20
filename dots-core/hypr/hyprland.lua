--------------------------------------------------------------------------------
-- HYPRLAND MASTER CONFIGURATION (Dots Core)
-- Dynamic Multi-Rice Loader (Zero-Symlink Architecture)
--------------------------------------------------------------------------------
local home = os.getenv("HOME")

-- 1. Read active rice name from state file (default to "inabashell")
local state_file = io.open(home .. "/.config/rice/current", "r")
local current_rice = "inabashell"
if state_file then
    local content = state_file:read("*l")
    if content and content:match("%S") then
        current_rice = content:gsub("%s+", "")
    end
    state_file:close()
end

-- 2. Inject shared core & active rice directories into Lua package.path
local core_hypr_dir = home .. "/dotfiles/dots-core/hypr"
local rice_hypr_dir = home .. "/dotfiles/rices/" .. current_rice .. "/hypr"

package.path = core_hypr_dir .. "/?.lua;" .. rice_hypr_dir .. "/?.lua;" .. package.path

-- 3. Load Shared Core Logic (from dots-core/hypr/)
pcall(require, "system")       -- Chassis detection (laptop vs PC)
require("mainMonitor")  -- Primary display
require("monitors")     -- Monitor setups & workspace assignments
require("input")        -- Keyboard layout & mouse sensitivities
require("env_vars")     -- Environment variables & cursors
require("rules")        -- Window & layer rules

-- 4. Load Active Rice Theme & Variables (from rices/<current_rice>/hypr/)
pcall(require, "colors")       -- Rice palette variables
pcall(require, "visuals")      -- Layout (master vs scrolling), gaps, borders, blur
pcall(require, "animations")   -- Rice-specific bezier curves and animation speeds
pcall(require, "programs")     -- Declares: terminal, menu, powerMenu, colorPicker
pcall(require, "wallpapers")   -- Wallpaper definitions

-- 5. Load Shared Keybindings (evaluated AFTER rice programs are declared!)
require("binds")        -- Keybindings calling terminal, menu, etc.

-- 6. Load Active Rice Autostart Commands
pcall(require, "autostart")
