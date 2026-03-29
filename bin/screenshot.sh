#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
OUT_DIR="${HOME}/Pictures/Screenshots"
STATE_FILE="/tmp/hypr_shot_state"
LAST_GEO_FILE="/tmp/hypr_shot_geo"
SOUND_PATH="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"
# Slurp con colores Dracula para la selección de área
SLURP_ARGS='-d -b 282a3666 -c bd93f9ff -s 00000000 -w 2'

mkdir -p "$OUT_DIR"

# Estados
SHOW_CURSOR=$(cat "$STATE_FILE" 2>/dev/null || echo "no")
CURSOR_ICON=$([[ "$SHOW_CURSOR" == "yes" ]] && echo "󰆲" || echo "󰆳")

# --- TEMA DRACULA PREMIUM ---
ROFI_THEME="
* {
    background-color: transparent;
    text-color: #f8f8f2;
    font: \"JetBrainsMono Nerd Font 10\";
}
window {
    location: south; anchor: south; y-offset: -30px;
    width: 580px; 
    border: 2px; border-radius: 20px; border-color: #bd93f9;
    background-color: #282a36;
}
mainbox { children: [ listview ]; }
listview {
    layout: horizontal;
    spacing: 15px;
    padding: 12px 18px;
    fixed-height: true;
}
element {
    padding: 10px 15px;
    border-radius: 12px;
    background-color: #44475a;
}
element selected {
    background-color: #6272a4;
    text-color: #50fa7b;
}
element-text { horizontal-align: 0.5; vertical-align: 0.5; cursor: pointer; }
"

MENU_OPTS="󰒅 Área\n󰖭 Vent\n󰹑 Full\n$CURSOR_ICON Cursor\n󰑐 Rep"

CHOICE=$(echo -e "$MENU_OPTS" | rofi -dmenu -config /dev/null -theme-str "$ROFI_THEME" -i)

case "$CHOICE" in
    *"Cursor"*)
        [[ "$SHOW_CURSOR" == "yes" ]] && echo "no" > "$STATE_FILE" || echo "yes" > "$STATE_FILE"
        exec "$0" 
        ;;
    *"Área"*)
        GEOMETRY=$(slurp $SLURP_ARGS) || exit 0
        echo "$GEOMETRY" > "$LAST_GEO_FILE"
        ;;
    *"Rep"*)
        GEOMETRY=$(cat "$LAST_GEO_FILE" 2>/dev/null || slurp $SLURP_ARGS)
        ;;
    *"Vent"*)
        GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        ;;
    *"Full"*)
        GEOMETRY=""
        ;;
    *) exit 0 ;;
esac

# --- FORMATO DE NOMBRE ESTILO GNOME ---
# Formato: Screenshot from 2025-12-18 12-01-54.png
TIMESTAMP=$(date +"%Y-%m-%d %H-%M-%S")
FILENAME="${OUT_DIR}/Screenshot From ${TIMESTAMP}.png"

# --- Ejecución ---
CURSOR_FLAG=$([[ "$(cat "$STATE_FILE" 2>/dev/null)" == "yes" ]] && echo "-p" || echo "")

if [ -z "$GEOMETRY" ]; then
    grim $CURSOR_FLAG "$FILENAME"
else
    grim $CURSOR_FLAG -g "$GEOMETRY" "$FILENAME"
fi

# Acciones finales
wl-copy < "$FILENAME"
paplay "$SOUND_PATH" 2>/dev/null || true
notify-send -a "Screenshot" -i "camera-photo-symbolic" "¡Capturado!" "Guardado como: Screenshot from ${TIMESTAMP}.png"