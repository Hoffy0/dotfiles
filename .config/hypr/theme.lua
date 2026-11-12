-- █▀▀ █░█ █▀█ █▀ █▀█ █▀█
-- █▄▄ █▄█ █▀▄ ▄█ █▄█ █▀▄

-- "exec" de hyprlang: corre al iniciar y en cada reload
local function apply_theme()
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")

-- █ █▀▀ █▀█ █▄░█   ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- █ █▄▄ █▄█ █░▀█   ░█░ █▀█ ██▄ █░▀░█ ██▄
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dracula'")
end
hl.on("hyprland.start", apply_theme)
hl.on("config.reloaded", apply_theme)


-- █▀ █▀█ █▀▀ █▀▀ █ ▄▀█ █░░
-- ▄█ █▀▀ ██▄ █▄▄ █ █▀█ █▄▄

hl.config({
    decoration = {
        dim_special = 0.3,
        blur = {
            special = true,
        },
    },
})

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 3,
        col = {
            active_border = { colors = { "rgb(b4befe)", "rgb(f5c2e7)" }, angle = 45 },
            inactive_border = "rgba(00000000)",
        },
        layout = "dwindle",
        resize_on_border = true,
    },
})

hl.config({
    decoration = {
        rounding = 10,

        -- Pista visual de foco: las reglas de windowrules.lua usan el mismo valor
        -- de opacidad para activo e inactivo, asi que sin esto no hay diferencia.
        dim_inactive = true,
        dim_strength = 0.1,

        shadow = {
            enabled = true,
            range = 10,
            render_power = 3,
            color = "rgba(00000055)",
        },

        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            popups = true,
            -- xray: las ventanas difuminan solo el wallpaper, no las ventanas de atras.
            xray = true,
        },
    },
})

-- Noctalia pide blur por su cuenta via ext-background-effect-v1 (BackgroundEffect.blurRegion),
-- por region y con esquinas redondeadas. Un layer_rule con blur encima difuminaria el rectangulo
-- completo del layer, margenes transparentes incluidos = doble blur y peor resultado.
