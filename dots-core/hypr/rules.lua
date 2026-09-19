hl.config({
    xwayland = {
        enabled = true,
        force_zero_scaling = true,
    },
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { 
        class = ".*"
    },
    suppress_event = maximize
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true
})

hl.window_rule({ match = { class = "com.github.wwmm.easyeffects" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })

hl.window_rule({ match = { class = "via-nativia" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })

hl.window_rule({ match = { class = "unityhub" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })

-- Both cause there's some wierd ass name switching going on
hl.window_rule({ match = { class = "Spotify" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })
hl.window_rule({ match = { class = "spotify" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })

hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "nm-connection-editor" }, size = { "monitor_w*0.35", "monitor_h*0.3"} })

hl.window_rule({ match = { class = "small-floating-kitty" }, float = true, center = true, size = { "monitor_w*0.5", "monitor_h*0.5" } })

hl.window_rule({ match = { title = "yazi" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })

hl.window_rule({ match = { class = "org.gnome.Nautilus" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })

hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
hl.layer_rule({ match = { namespace = "logout_dialog" }, xray = false })

hl.layer_rule({ match = { namespace = "swaync-control-center" }, animation = "slide left" })

hl.layer_rule({ match = { namespace = "hyprpaper" }, no_anim = true })
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell" }, animation = "fade" })
