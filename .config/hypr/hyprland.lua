-- █░█ █▄█ █▀█ █▀█ █░░ ▄▀█ █▄░█ █▀▄
-- █▀█ ░█░ █▀▀ █▀▄ █▄▄ █▀█ █░▀█ █▄▀

-- Hyprland >= 0.57 solo lee Lua (hyprlang se elimino). Cada .lua traduce
-- 1:1 su .conf; los .conf quedan para Hyprland <= 0.56.
-- API: https://wiki.hypr.land/configuring/ y /usr/share/hypr/stubs/hl.meta.lua


-- █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█
-- █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█

-- See https://wiki.hypr.land/configuring/core/autostart/

-- exec-once
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    -- Sin uwsm nadie activa graphical-session.target, y xdg-desktop-portal lo
    -- exige (Requisite=). Sin portal las apps no ven el modo oscuro.
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("lxpolkit")
    -- Via systemd para que se reinicie solo si muere (ver
    -- .config/systemd/user/noctalia-shell.service). reset-failed limpia el estado
    -- si en la sesion anterior systemd se rindio por el rate limit.
    hl.exec_cmd("bash -c 'systemctl --user reset-failed noctalia-shell.service 2>/dev/null; systemctl --user restart noctalia-shell.service'")
end)


-- █▀▀ █▄░█ █░█
-- ██▄ █░▀█ ▀▄▀

-- See https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-- █ █▄░█ █▀█ █░█ ▀█▀
-- █ █░▀█ █▀▀ █▄█ ░█░

-- See https://wiki.hypr.land/configuring/core/config-options/

hl.config({
    input = {
        kb_layout = "es",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,

        touchpad = {
            natural_scroll = false,
        },

        sensitivity = 0,
        force_no_accel = true,
    },
})

hl.device({
    name = "epic mouse V1",
    sensitivity = 0,
})

-- Logitech G515 TKL (ANSI, sin ñ): US internacional, AltGr+n = ñ
-- El G515 se expone como varios dispositivos y el tipeo entra por -2;
-- device no acepta regex, asi que va un bloque por nombre.
for _, name in ipairs({
    "logitech-g515-ls-tkl",
    "logitech-g515-ls-tkl-2",
    "logitech-g515-ls-tkl-system-control",
    "logitech-g515-ls-tkl-consumer-control",
}) do
    hl.device({ name = name, kb_layout = "us", kb_variant = "altgr-intl" })
end


-- █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀ █▀
-- █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░ ▄█

-- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/configuring/layouts/master-layout/

hl.config({
    master = {
        new_status = "master",
    },
})


-- █▀▄▀█ █ █▀ █▀▀
-- █░▀░█ █ ▄█ █▄▄

hl.config({
    misc = {
        vrr = 0,
        -- Da el foco a la app que lo pide (dialogos, links desde otra app)
        -- en vez de solo marcarla como urgente.
        focus_on_activate = true,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
})

-- Ajustes para la UHD 770 (GT1) en passthrough: triple buffer cuando no alcanza
-- el frame, y sin el shader de color management (monitor SDR).
hl.config({
    render = {
        new_render_scheduling = true,
        cm_enabled = false,
    },
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})


-- █▀ █▀█ █░█ █▀█ █▀▀ █▀▀
-- ▄█ █▄█ █▄█ █▀▄ █▄▄ ██▄

require("animations")
require("keybindings")
require("windowrules")
require("theme")
-- ptah: sin NVIDIA (nvidia.conf no aplica); QT_QPA_PLATFORM sigue siendo obligatorio para Noctalia
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
require("monitors")
require("custom-prefs")
