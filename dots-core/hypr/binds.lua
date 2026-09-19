require("programs")
require("wallpapers")

-------------------
--- KEYBINDINGS ---
-------------------

mainMod = "SUPER"

-- binds:

-- wm actions:
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + F1", hl.dsp.exit())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen("fullscreen", "toggle"))
hl.bind(mainMod .. " + V", hl.dsp.window.float())

-- programs:
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(fileManagerAlt))
hl.bind(mainMod .. " + tab", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(notificationCenter))
hl.bind(mainMod .. " + SHIFT + s", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.exec_cmd(powerMenu))
hl.bind(mainMod .. " + p", hl.dsp.exec_cmd(colorPicker))

-- scripts:
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/scripts/lock-in-mode.sh"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("~/.config/scripts/rofi-menu-scripts/rofi-menu.sh"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.config/scripts/rice_switcher/rofi-rice-switcher.sh"))

-- scratchpads (using pypr):
hl.bind(mainMod .. " + a", hl.dsp.exec_cmd("pypr toggle term"))
hl.bind(mainMod .. " + b", hl.dsp.exec_cmd("pypr toggle btop"))
hl.bind(mainMod .. " + t", hl.dsp.exec_cmd("pypr toggle bluetooth"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- swap windows
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.swap({ direction = "down" }))

-- Scrolling layout binds
hl.bind(mainMod .. " + r", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + s", hl.dsp.exec_cmd("~/.config/scripts/switch-layout.sh"))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Change wallpaper for workspaces 1-6
hl.bind(mainMod .. " + 1", hl.dsp.exec_cmd(wallp_1))
hl.bind(mainMod .. " + 2", hl.dsp.exec_cmd(wallp_2))
hl.bind(mainMod .. " + 3", hl.dsp.exec_cmd(wallp_3))
hl.bind(mainMod .. " + 4", hl.dsp.exec_cmd(wallp_4))
hl.bind(mainMod .. " + 5", hl.dsp.exec_cmd(wallp_5))
hl.bind(mainMod .. " + 6", hl.dsp.exec_cmd(wallp_6))

hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.exec_cmd(wallp_1))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.exec_cmd(wallp_2))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.exec_cmd(wallp_3))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.exec_cmd(wallp_4))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.exec_cmd(wallp_5))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.exec_cmd(wallp_6))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
