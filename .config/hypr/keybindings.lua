-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
-- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█

local mainMod = "SUPER"
local subMod  = mainMod .. " + SHIFT"
local term    = "ghostty"
local file    = "nautilus"
local binPath = "~/bin"
local noct    = "qs -c noctalia-shell ipc call"

local function bind(keys, dispatcher, opts) hl.bind(keys, dispatcher, opts) end
local function exec(cmd) return hl.dsp.exec_cmd(cmd) end

-- bindl / bindel / binde
local locked     = { locked = true }
local lockedRep  = { locked = true, repeating = true }
local repeating  = { repeating = true }

--==> SYSTEM BINDS
bind(mainMod .. " + Return", exec(term))                                                    --==> Terminal
bind(mainMod .. " + E", exec(file))                                                         --==> File Manager
bind("CTRL + SHIFT + Escape", exec(term .. " -e btop"))                                     --==> System monitor (Btop)
bind(mainMod .. " + W", exec(noct .. " wallpaper toggle"))
bind(subMod .. " + W", exec("bash " .. binPath .. "/rofi-menus/wallpaper-selector.sh --top-secret"))
bind("Print", exec("~/bin/screenshot.sh -m area -A"))                                       --==> Screenshot
bind(mainMod .. " + P", exec("pavucontrol"))                                                --==> Pavucontrol
bind(mainMod .. " + A", exec("bash " .. binPath .. "/rofi-menus/audio-switcher.sh"))        --==> Audio device switcher
bind(mainMod .. " + V", exec(noct .. " launcher clipboard"))                                --==> Historial de portapapeles
bind(mainMod .. " + D", exec(noct .. " launcher toggle"))                                   --==> App launcher
bind(mainMod .. " + code:60", exec(noct .. " launcher emoji"))                              --==> Emoji picker
bind(mainMod .. " + X", exec(noct .. " sessionMenu toggle"))                                --==> Session menu
bind(mainMod .. " + L", exec(noct .. " lockScreen lock"))                                   --==> Lock screen
bind(mainMod .. " + C", exec("hyprpicker -a"))                                              --==> Color Picker
bind(mainMod .. " + B", exec(noct .. " bar toggle"))
bind(mainMod .. " + N", exec(noct .. " notifications toggleHistory"))                       --==> Historial de notificaciones

--------------------------------------------------------------------------------------------- Noctalia
bind(mainMod .. " + Tab", exec(noct .. " launcher windows"))                                --==> Window switcher
bind(mainMod .. " + O", exec(noct .. " controlCenter toggle"))                              --==> Control center
bind(subMod .. " + D", exec(noct .. " darkMode toggle"))                                    --==> Alternar claro/oscuro
bind(subMod .. " + N", exec(noct .. " nightLight toggle"))                                  --==> Alternar night light
bind(mainMod .. " + ALT + I", exec(noct .. " idleInhibitor toggle"))                        --==> Inhibir suspension (gaming/streams)

--==> USER APPS
bind(subMod .. " + C", exec("code"))                                                        --==> Visual Studio Code
bind(subMod .. " + G", exec("google-chrome"))                                               --==> Google Chrome
bind(subMod .. " + T", exec("telegram-desktop"))                                            --==> Telegram
bind(subMod .. " + O", exec("obs"))                                                         --==> OBS

--==> SYSTEM CONTROLS
-------------------------------------------------------------------------------------------------- VOLUME
bind("XF86AudioRaiseVolume", exec(noct .. " volume increase"), lockedRep)
bind("XF86AudioLowerVolume", exec(noct .. " volume decrease"), lockedRep)
bind("XF86AudioMute",        exec(noct .. " volume muteOutput"), locked)
bind("XF86AudioMicMute",     exec(noct .. " volume muteInput"), locked)
-------------------------------------------------------------------------------------------------- PLAYER
bind("XF86AudioPlay",  exec(noct .. " media playPause"), locked)
bind("XF86AudioPause", exec(noct .. " media playPause"), locked)
bind("XF86AudioNext",  exec(noct .. " media next"), locked)
bind("XF86AudioPrev",  exec(noct .. " media previous"), locked)
bind("XF86AudioStop",  exec(noct .. " media stop"), locked)
-------------------------------------------------------------------------------------------------- BRIGHTNESS
bind("XF86MonBrightnessUp",   exec(noct .. " brightness increase"), lockedRep)
bind("XF86MonBrightnessDown", exec(noct .. " brightness decrease"), lockedRep)

--==> HYPRLAND
--------------------------------------------------------------------------------------------- Session actions
bind(mainMod .. " + Delete", hl.dsp.exit())                                                 --==> Kill hyprland session
bind("CTRL + SHIFT + R", hl.dsp.reload_config())                                           --==> Reload hyprland session
--------------------------------------------------------------------------------------------- Window actions
bind(mainMod .. " + Q", hl.dsp.window.close())                                              --==> close focused window
bind(mainMod .. " + Space", hl.dsp.window.float())                                          --==> toggle floating
bind("ALT + Return", hl.dsp.window.fullscreen({ mode = "fullscreen" }))                     --==> toggle fullscreen
--------------------------------------------------------------------------------------------- Move/Change window focus
bind(mainMod .. " + Right", hl.dsp.focus({ direction = "r" }))
bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "l" }))
bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "u" }))
bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "d" }))
bind("ALT + Tab",           hl.dsp.focus({ direction = "d" }))
--------------------------------------------------------------------------------------------- Workspaces
for i = 1, 10 do
    local key = tostring(i % 10) -- 0 = workspace 10
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))                              --==> Switch to workspace
    bind(subMod .. " + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))          --==> Move to workspace
end
bind(mainMod .. " + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }))                    --==> Next workspace
bind(mainMod .. " + CTRL + Left",  hl.dsp.focus({ workspace = "r-1" }))                    --==> Prev workspace
bind(mainMod .. " + CTRL + Down",  hl.dsp.focus({ workspace = "empty" }))                  --==> First empty workspace
bind(mainMod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+10" }))                   --==> Scroll workspaces forward
bind(mainMod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-10" }))                   --==> Scroll workspaces back
--------------------------------------------------------------------------------------------- Resize windows
bind(subMod .. " + Right", hl.dsp.window.resize({ x = 30,  y = 0,   relative = true }), repeating)
bind(subMod .. " + Left",  hl.dsp.window.resize({ x = -30, y = 0,   relative = true }), repeating)
bind(subMod .. " + Up",    hl.dsp.window.resize({ x = 0,   y = -30, relative = true }), repeating)
bind(subMod .. " + Down",  hl.dsp.window.resize({ x = 0,   y = 30,  relative = true }), repeating)
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })                  --==> Resize with the mouse
--------------------------------------------------------------------------------------------- Move focused window around the current workspace
bind(subMod .. " + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
bind(subMod .. " + CTRL + Left",  hl.dsp.window.move({ direction = "l" }))
bind(subMod .. " + CTRL + Up",    hl.dsp.window.move({ direction = "u" }))
bind(subMod .. " + CTRL + Down",  hl.dsp.window.move({ direction = "d" }))
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })                    --==> Move with the mouse
--------------------------------------------------------------------------------------------- Special workspace
-- En el .conf eran dos binds sobre la misma tecla; ambos se disparaban en orden.
bind(mainMod .. " + ALT + S", function()
    hl.dispatch(hl.dsp.window.move({ workspace = "special", follow = false }))
    hl.dispatch(hl.dsp.window.move({ workspace = "previous", follow = true }))
end)
bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("special"))                        --==> Open special workspace

