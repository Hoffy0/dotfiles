#!/usr/bin/env bash
# Bloqueo estilo GNOME: copia el wallpaper actual de Noctalia y lanza hyprlock

pidof hyprlock >/dev/null && exit 0

# Sin hyprlock instalado, usar el bloqueo de Noctalia
if ! command -v hyprlock >/dev/null; then
    exec qs -c noctalia-shell ipc call lockScreen lock
fi

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
BG="$CACHE/hyprlock/bg"
mkdir -p "$CACHE/hyprlock"

wall=$(python3 -c "
import json, sys
d = json.load(open('$CACHE/noctalia/wallpapers.json'))
print(d['wallpapers']['DP-1']['dark'])
" 2>/dev/null)

[ -f "$wall" ] && ln -sf "$wall" "$BG"

exec hyprlock "$@"
