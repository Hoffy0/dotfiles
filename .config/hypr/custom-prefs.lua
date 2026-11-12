-- █░█ █▀ █▀▀ █▀█   █▀█ █▀█ █▀▀ █▀▀ █▀
-- █▄█ ▄█ ██▄ █▀▄   █▀▀ █▀▄ ██▄ █▀░ ▄█

-- Set your personal hyprland configuration here

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
