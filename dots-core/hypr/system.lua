local M = {}

local function check_is_laptop()
    -- 1. Check environment variable override if set
    local env_override = os.getenv("HYPR_DEVICE") or os.getenv("HOST_TYPE") or os.getenv("IS_LAPTOP")
    if env_override then
        env_override = env_override:lower()
        if env_override == "laptop" or env_override == "true" or env_override == "1" then
            return true
        elseif env_override == "pc" or env_override == "desktop" or env_override == "false" or env_override == "0" then
            return false
        end
    end

    -- 2. Check for battery device in /sys/class/power_supply/
    local b0 = io.open("/sys/class/power_supply/BAT0/type", "r")
    if b0 then b0:close(); return true end
    local b1 = io.open("/sys/class/power_supply/BAT1/type", "r")
    if b1 then b1:close(); return true end

    -- 3. Check DMI chassis type (laptop / notebook codes)
    local f_chassis = io.open("/sys/class/dmi/id/chassis_type", "r")
    if f_chassis then
        local ctype = tonumber(f_chassis:read("*a") or "")
        f_chassis:close()
        if ctype and (ctype == 8 or ctype == 9 or ctype == 10 or ctype == 11 or ctype == 14 or ctype >= 30) then
            return true
        end
    end

    -- 4. Check /etc/hostname
    local f_host = io.open("/etc/hostname", "r")
    if f_host then
        local host = (f_host:read("*l") or ""):lower()
        f_host:close()
        if host:find("laptop") or host:find("notebook") then
            return true
        end
    end

    return false
end

M.is_laptop = check_is_laptop()
M.is_pc = not M.is_laptop

return M
