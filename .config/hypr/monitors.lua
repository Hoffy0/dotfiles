-- █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
-- █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█

-- ptah: DP-1 (DDI TC2 de la UHD 770).
-- En el equipo principal era DP-5 + HDMI-A-3.
hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "0x0", scale = 1.5 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = "DP-1" })

