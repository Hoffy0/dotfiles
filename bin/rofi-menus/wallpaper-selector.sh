#!/usr/bin/env bash

# ┏━━━┳━━┳━┓┏━┳━━━┳┓╋╋┏━━┳━┓┏━┓
# ┗┓┏┓┣┫┣┫┃┗┛┃┃┏━━┫┃╋╋┗┫┣┻┓┗┛┏┛
# ╋┃┃┃┃┃┃┃┏┓┏┓┃┗━━┫┃╋╋╋┃┃╋┗┓┏┛
# ╋┃┃┃┃┃┃┃┃┃┃┃┃┏━━┫┃╋┏┓┃┃╋┏┛┗┓
# ┏┛┗┛┣┫┣┫┃┃┃┃┃┃╋╋┃┗━┛┣┫┣┳┛┏┓┗┓
# ┗━━━┻━━┻┛┗┛┗┻┛╋╋┗━━━┻━━┻━┛┗━┛
# The program was created by DIMFLIX (FINAL FIX)

# --- CONFIGURACIÓN ---
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/mewline/thumbs"
RANDOM_ICON="${DATA_HOME}/meowrch/assets/random.png"
ROFI_THEME="$HOME/.config/rofi/selecting.rasi"
MAX_THREADS=$(nproc 2>/dev/null || echo 4)
RADIUS=15

# Rutas de carpetas
NORMAL_DIRS=("/home/hoffy/Pictures/wallpapers")
SECRET_DIR="/home/hoffy/Pictures/wallpapers/.hidden"

# --- LÓGICA DE CARPETAS ---
if [[ "$1" == "--top-secret" ]]; then
    WALLPAPERS_DIRS=("$SECRET_DIR")
    CACHE_MAPPING="$CACHE_DIR/secret_mapping.json"
    shift
else
    WALLPAPERS_DIRS=("${NORMAL_DIRS[@]}")
    CACHE_MAPPING="$CACHE_DIR/cache_mapping.json"
fi

LOCK_FILE="$CACHE_DIR/cache.lock"
mkdir -p "$CACHE_DIR"
touch "$CACHE_MAPPING"

# --- FUNCIONES ORIGINALES (SIN TOCAR SINTAXIS) ---

lock() {
    exec 9>"$LOCK_FILE" || exit 1
    flock -w 30 9 || { echo "Failed to acquire lock"; exit 1; }
}

unlock() {
    [[ -e /proc/self/fd/9 ]] && flock -u 9
    exec 9>&-
    rm -f "$LOCK_FILE"
}

get_hash() {
    realpath "$1" | tr -d '\n' | md5sum | awk '{print $1}'
}

safe_jq() {
    local operation="$1"
    local tmp_file="${CACHE_MAPPING}.tmp"
    lock
    if [[ ! -s "$CACHE_MAPPING" ]] || ! jq empty "$CACHE_MAPPING" >/dev/null 2>&1; then
        echo "{}" > "$CACHE_MAPPING"
    fi

    case "$operation" in
        "clean")
            local hashes_json="["
            for h in "${!existing_hashes[@]}"; do hashes_json+="\"$h\","; done
            hashes_json="${hashes_json%,}]"
            jq --argjson hashes "$hashes_json" 'with_entries(select((.value != "") and (.key as $k | $hashes | index($k) != null)))' "$CACHE_MAPPING" > "$tmp_file"
            ;;
    esac

    if jq -e . "$tmp_file" >/dev/null 2>&1; then mv "$tmp_file" "$CACHE_MAPPING"; else rm -f "$tmp_file"; fi
    unlock
}

validate_cache() {
    declare -A existing_hashes
    while IFS= read -r -d $'\0' f; do
        h=$(get_hash "$f")
        existing_hashes["${h}.png"]=1
    done < <(find -L "${WALLPAPERS_DIRS[@]}" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 2>/dev/null)
    safe_jq "clean"
}

generate_rounded_thumbnail() {
    local input="$1" output="$2"
    magick convert "$input" -resize "500x500^" -gravity center -extent 500x500 -format "png" \
        \( +clone -alpha extract \( -size 500x500 xc:black -draw "fill white roundrectangle 0,0 500,500 $RADIUS,$RADIUS" \) \
        -compose multiply -composite \) -alpha off -compose copyopacity -composite "$output"
}

generate_thumbnails() {
    validate_cache
    declare -A file_hashes
    declare -a files
    while IFS= read -r -d $'\0' f; do
        [[ -z "$f" || ! -e "$f" ]] && continue
        h=$(get_hash "$f")
        if [[ ! -v file_hashes[$h] ]]; then
            file_hashes[$h]=1
            thumb="$CACHE_DIR/$h.png"
            [[ ! -f "$thumb" || "$f" -nt "$thumb" ]] && files+=("$f")
        fi
    done < <(find -L "${WALLPAPERS_DIRS[@]}" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 2>/dev/null)

    ((${#files[@]})) && notify-send -a "Wallpaper Selector" "⏳ Generating ${#files[@]} previews..."
    
    tmp_json_dir=$(mktemp -d -p "$CACHE_DIR" thumbs_json.XXXXXX)
    trap 'rm -rf "$tmp_json_dir"' EXIT

    export -f generate_rounded_thumbnail get_hash
    export CACHE_DIR tmp_json_dir RADIUS

    # --- BLOQUE CRÍTICO: SINTAXIS ORIGINAL RESTAURADA ---
    printf "%s\0" "${files[@]}" | xargs -0 -P "$MAX_THREADS" -I{} bash -c '
        f="$1"
        [[ -z "$f" || ! -f "$f" ]] && exit 0
        h=$(get_hash "$f")
        thumb="$CACHE_DIR/$h.png"
        path=$(realpath -- "$f") || exit 0
        if ! generate_rounded_thumbnail "$f" "$thumb" 2>/dev/null; then
            magick convert "$f" -resize "500x500^" -gravity center -extent 500x500 "$thumb" 2>/dev/null
        fi
        jq -n --arg h "$h.png" --arg p "$path" '"'"'if ($p == "" or $h == "") then empty else {($h): $p} end'"'"' > "$tmp_json_dir/${h}.json"
    ' _ {}

    lock
    {
        tmp_file=$(mktemp -p "$CACHE_DIR" cache_mapping.XXXXXX)
        if [[ $(find "$tmp_json_dir" -name "*.json" | wc -l) -gt 0 ]]; then
            jq -n 'reduce (inputs | select(. != null)) as $i ({}; . * $i)' "$tmp_json_dir"/*.json > "$tmp_file"
            jq -s '.[0] * .[1]' "$CACHE_MAPPING" "$tmp_file" > "$tmp_file.merged"
            mv "$tmp_file.merged" "$CACHE_MAPPING"
        fi
        rm -f "$tmp_file"
    } 2>/dev/null
    unlock
}

generate_rofi_list() {
    echo -en "Random Wallpaper\x00icon\x1f$RANDOM_ICON\n"
    jq -r 'to_entries[] | "\(.value)=\(.key)"' "$CACHE_MAPPING" | while IFS='=' read -r p h; do
        [[ -f "$CACHE_DIR/$h" ]] && echo -en "$(basename "$p")\x00icon\x1f$CACHE_DIR/$h\n"
    done
}

main() {
    command -v magick >/dev/null || exit 1
    generate_thumbnails

    if [[ "$1" == "--random" ]]; then
        readarray -t walls < <(jq -r '.[]' "$CACHE_MAPPING")
        wall="${walls[RANDOM % ${#walls[@]}]}"
    else
        selected=$(generate_rofi_list | rofi -dmenu -i -p "Wallpaper" -theme "$ROFI_THEME")
        [[ -z "$selected" ]] && exit 0
        if [[ "$selected" == "Random Wallpaper" ]]; then
            readarray -t walls < <(jq -r '.[]' "$CACHE_MAPPING")
            wall="${walls[RANDOM % ${#walls[@]}]}"
        else
            wall=$(jq -r --arg n "$selected" 'to_entries[] | .value as $path | select(($path | split("/")[-1]) == $n) | $path' "$CACHE_MAPPING" | head -n1)
        fi
    fi

    if [[ -f "$wall" ]]; then
        # Noctalia gestiona el wallpaper (swww-daemon ya no corre).
        # El "" final = todos los monitores. Noctalia acepta rutas fuera de su
        # directorio escaneado, por eso .hidden funciona sin exponerlo en su picker.
        ( qs -c noctalia-shell ipc call wallpaper set "$wall" "" & )
        exit 0
    fi
}

trap 'unlock; exit' INT TERM EXIT
main "$@"