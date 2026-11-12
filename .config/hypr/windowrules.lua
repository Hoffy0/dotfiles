-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
-- ▀▄▀▄▀ █ █▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█

----------------------------------------------------------------------------- OPACIDAD
hl.window_rule({
    name = "opacity-90",
    match = { class = "^(google-chrome|brave-browser|org.telegram.desktop|jetbrains-datagrip)$" },
    opacity = "0.90 0.90",
})

hl.window_rule({
    name = "opacity-editors",
    match = { class = "^(code|antigravity)$" },
    opacity = "0.95 0.80",
})

hl.window_rule({
    name = "opacity-ghostty",
    match = { class = "^(com.mitchellh.ghostty)$" },
    opacity = "0.90 0.75",
})

hl.window_rule({
    name = "opacity-80-apps",
    match = { class = "^(code-oss|code-url-handler|code-insiders-url-handler|qt5ct|qt6ct|org.kde.ark|com.obsproject.Studio|Alacritty|blueman-manager|[Ss]team|steamwebhelper|discord|Spotify|WebCord|vesktop|yad|org.gnome.Evince|evince)$" },
    opacity = "0.80 0.80",
})

hl.window_rule({
    name = "opacity-80-portals",
    match = { class = "^(org.kde.polkit-kde-authentication-agent-1|polkit-gnome-authentication-agent-1|org.freedesktop.impl.portal.desktop.gtk|org.freedesktop.impl.portal.desktop.hyprland)$" },
    opacity = "0.80 0.80",
})

----------------------------------------------------------------------------- FLOTANTES
hl.window_rule({
    name = "float-dialogs",
    match = { class = "^(vlc|1password|blueman-manager|qt5ct|qt6ct|org.kde.ark|yad|org.kde.polkit-kde-authentication-agent-1)$" },
    float = true,
})

hl.window_rule({
    name = "float-firefox-pip",
    match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },
    float = true,
})

hl.window_rule({
    name = "float-firefox-library",
    match = { class = "^(firefox)$", title = "^(Library)$" },
    float = true,
})

hl.window_rule({
    name = "float-portal-gtk",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
    center = true,
})

-- OpenLogi y todas sus ventanas hijas (dialogos, popups) comparten app_id
hl.window_rule({
    name = "float-openlogi",
    match = { class = [[^(org\.openlogi\..*)$]] },
    float = true,
    center = true,
})

----------------------------------------------------------------------------- FLOTANTES CON TAMANO
hl.window_rule({
    name = "float-calculator",
    match = { class = "^(org.gnome.Calculator|gnome-calculator)$" },
    opacity = "0.80 0.80",
    float = true,
    center = true,
    size = "360 500",
})

hl.window_rule({
    name = "float-loupe",
    match = { class = "^(org.gnome.Loupe)$" },
    opacity = "0.90 0.90",
    float = true,
    center = true,
    size = "1200 800",
})

hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    opacity = "0.80 0.80",
    float = true,
    size = "920 450",
})

hl.window_rule({
    name = "float-nautilus",
    match = { class = "^(org.gnome.Nautilus)$" },
    opacity = "0.80 0.80",
    float = true,
    center = true,
})

----------------------------------------------------------------------------- MISC
hl.window_rule({
    name = "noblur-sin-clase",
    match = { class = "^()$", title = "^()$" },
    no_blur = true,
})


-- █░░ ▄▀█ █▄█ █▀▀ █▀█   █▀█ █░█ █░░ █▀▀ █▀
-- █▄▄ █▀█ ░█░ ██▄ █▀▄   █▀▄ █▄█ █▄▄ ██▄ ▄█

-- noctalia se blurea solo via ext-background-effect-v1, no lleva layer_rule.
hl.layer_rule({
    name = "blur-rofi",
    match = { namespace = "^(rofi)$" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "blur-notifications",
    match = { namespace = "^(notifications)$" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "blur-logout",
    match = { namespace = "^(logout_dialog)$" },
    blur = true,
})
