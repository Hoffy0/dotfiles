-- Igual que portal_fix.conf: NO se carga desde hyprland.lua.
-- Para activarlo, agregar require("portal_fix") en hyprland.lua.
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user mask xdg-desktop-portal-gnome.service")
    hl.exec_cmd("systemctl --user mask xdg-desktop-portal-gnome.socket")
    hl.exec_cmd("systemctl --user restart xdg-desktop-portal")
end)
