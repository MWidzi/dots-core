local system = require("system")

mainMonitor = system.is_laptop and "eDP-1" or "DP-1"

-- Sync mainMonitor.conf for hyprlock.conf or external configs
local home = os.getenv("HOME")
if home then
    local f = io.open(home .. "/.config/hypr/mainMonitor.conf", "w")
    if f then
        f:write("$mainMonitor = " .. mainMonitor .. "\n")
        f:close()
    end
end
