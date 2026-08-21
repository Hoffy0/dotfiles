#!/usr/bin/env bash
# Audio output switcher — pactl + rofi

CURRENT=$(pactl get-default-sink)

get_icon() {
    case "$1" in
        *[Cc]orsair*|*[Hh][Ss]*|*[Hh]eadphone*|*[Hh]eadset*) echo "󰋋" ;;
        *[Bb]luetooth*) echo "󰥰" ;;
        *[Rr]azer*|*[Ll]eviathan*|*[Ss]peaker*) echo "󰓃" ;;
        *[Hh][Dd][Mm][Ii]*|*[Dd][Pp]-*) echo "󰡁" ;;
        *) echo "󰓃" ;;
    esac
}

declare -A SINK_MAP
ENTRIES=()

while IFS='|' read -r name desc; do
    icon=$(get_icon "$name $desc")
    marker=""; [[ "$name" == "$CURRENT" ]] && marker="  ✓"
    label="$icon   $desc$marker"
    SINK_MAP["$label"]="$name"
    ENTRIES+=("$label")
done < <(pactl -f json list sinks | python3 -c "
import json, sys
for s in json.load(sys.stdin):
    print(s['name'] + '|' + s['description'])
")

chosen=$(printf '%s\n' "${ENTRIES[@]}" | rofi -dmenu -i -p "󰋋  Audio Output")
[[ -z "$chosen" ]] && exit 0

target="${SINK_MAP[$chosen]}"
[[ -z "$target" ]] && exit 1

pactl set-default-sink "$target"

# Move all active streams to new sink
pactl list sink-inputs short | awk '{print $1}' | while read -r id; do
    pactl move-sink-input "$id" "$target"
done

desc=$(pactl -f json list sinks | python3 -c "
import json, sys
for s in json.load(sys.stdin):
    if s['name'] == '$target':
        print(s['description']); break
")
icon=$(get_icon "$target")
notify-send -u low "$icon  Audio" "Output: $desc"
