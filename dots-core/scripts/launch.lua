local home = os.getenv("HOME")
local system = dofile(home .. "/.config/hypr/system.lua")

if system.is_laptop then
	os.execute("waybar -c " .. home .. "/.config/waybar/output-laptop.jsonc")
else
	os.execute("waybar -c " .. home .. "/.config/waybar/output-pc.jsonc")
end
