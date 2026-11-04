#!/usr/bin/env bash
# Bateria de un periferico Logitech para un CustomButton de Noctalia (parseJson).
# Uso: logi-battery.sh <modelo> <icono>   ej: logi-battery.sh "G502 X" mouse
#
# Busca por modelo en UPower y no por ruta: el kernel numera hidpp_battery_N
# con un contador que sube en cada reconexion, asi que la ruta no es estable.

model="$1"
icon="${2:-battery}"

dev=$(upower -e | while read -r path; do
    upower -i "$path" | grep -q "model:.*$model" && echo "$path" && break
done)

if [[ -z "$dev" ]]; then
    # Apagado o desconectado: texto vacio oculta el widget
    echo '{"text": ""}'
    exit 0
fi

info=$(upower -i "$dev")
pct=$(awk '/percentage:/ {gsub("%", "", $2); print int($2)}' <<<"$info")
state=$(awk '/state:/ {print $2}' <<<"$info")
name=$(awk -F': *' '/model:/ {print $2}' <<<"$info")

# Con el G515 UPower reporta "unknown" mientras carga; OpenLogi si lo sabe
if [[ "$state" == "unknown" ]] && command -v openlogi >/dev/null; then
    openlogi api devices 2>/dev/null | grep -q "\"name\":\"[^\"]*$model[^}]*\"status\":\"charging\"" && state="charging"
fi

text="${pct}%"
color="none"
[[ "$state" == "charging" ]] && icon="battery-charging"
(( pct <= 20 )) && [[ "$state" != "charging" ]] && color="error"

printf '{"text": "%s", "icon": "%s", "tooltip": "%s: %s%% (%s)", "color": "%s"}\n' \
    "$text" "$icon" "$name" "$pct" "$state" "$color"
