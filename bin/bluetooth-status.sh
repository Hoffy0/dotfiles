#!/usr/bin/env bash
# Dynamic bluetooth status for waybar

connected=$(bluetoothctl devices Connected 2>/dev/null)

if [[ -z "$connected" ]]; then
    echo '{"text":"<span color=\"#4c566a\">󰂲  </span>","tooltip":"Bluetooth: sin dispositivos","class":"disconnected"}'
    exit 0
fi

name=$(echo "$connected" | head -1 | cut -d' ' -f3-)
mac=$(echo "$connected" | head -1 | awk '{print $2}')

battery=$(bluetoothctl info "$mac" 2>/dev/null | grep -i "Battery Percentage" | grep -oP '\d+' | head -1)
battery_text=""
[[ -n "$battery" ]] && battery_text=" · ${battery}%"

echo "{\"text\":\"<span color=\\\"#89b4fa\\\">󰂯  ${name}${battery_text}</span>\",\"tooltip\":\"${name}${battery_text}\",\"class\":\"connected\"}"
