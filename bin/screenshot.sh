#!/usr/bin/env bash
set -euo pipefail

# === Config por defecto ===
OUT_DIR="${HOME}/Pictures/Screenshots"
MODE="area"          # full | area | active
ANNOTATE="no"        # yes | no
COPY="yes"           # yes | no
SOUND="no"           # yes | no (requiere paplay + tema de sonidos)

usage() {
  cat <<EOF
Uso: ${0##*/} [-m full|area|active] [-o DIR] [-A] [-C] [-S]
  -m  Modo de captura (por defecto: area)
  -o  Directorio de salida (por defecto: ${OUT_DIR})
  -A  Abrir en swappy para anotar
  -C  Copiar al portapapeles (wl-copy)
  -S  Reproducir sonido (paplay)
  -h  Ayuda
Ejemplos:
  ${0##*/} -m full
  ${0##*/} -m active -A
  ${0##*/} -m area -o ~/shots
EOF
}

while getopts ":m:o:ACSh" opt; do
  case "$opt" in
    m) MODE="$OPTARG" ;;
    o) OUT_DIR="$OPTARG" ;;
    A) ANNOTATE="yes" ;;
    C) COPY="yes" ;;
    S) SOUND="yes" ;;
    h) usage; exit 0 ;;
    \?) echo "Opción inválida: -$OPTARG" >&2; usage; exit 1 ;;
  esac
done

ts() { date +"%Y-%m-%d_%H-%M-%S"; }

ensure_dir() {
  mkdir -p "$OUT_DIR"
}

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Screenshot" "$1" "${2:-}"
  fi
}

ding() {
  if [ "$SOUND" = "yes" ] && command -v paplay >/dev/null 2>&1; then
    paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga 2>/dev/null || true
  fi
}

copy_clip() {
  if [ "$COPY" = "yes" ] && command -v wl-copy >/dev/null 2>&1; then
    wl-copy < "$1" || true
  fi
}

annotate_swappy() {
  if [ "$ANNOTATE" = "yes" ] && command -v swappy >/dev/null 2>&1; then
    # swappy puede sobrescribir o exportar; acá sobrescribe el mismo archivo
    SWAPPY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swappy"
    mkdir -p "$SWAPPY_CONFIG_DIR"
    swappy -f "$1" -o "$1"
  fi
}

shoot_with_grimblast() {
  local mode="$1" outfile="$2"
  # grimblast: save/copy/copyarea/etc. Usamos save y luego copiamos si hace falta.
  case "$mode" in
    full)   grimblast save screen "$outfile" ;;
    area)   grimblast save area  "$outfile" ;;
    active) grimblast save active "$outfile" ;;
    *) echo "Modo no soportado por grimblast: $mode" >&2; exit 2 ;;
  esac
}

shoot_fallback() {
  # Sin grimblast: full y area con grim+slurp
  local mode="$1" outfile="$2"
  case "$mode" in
    full)
      grim "$outfile"
      ;;
    area)
      local geo
      geo="$(slurp -d -b 00000077 -c FFFFFFDD -s FFFFFFAA)"
      grim -g "$geo" "$outfile"
      ;;
    active)
      echo "Modo 'active' requiere grimblast. Instálalo (hyprland-contrib)." >&2
      exit 3
      ;;
    *)
      echo "Modo no soportado: $mode" >&2; exit 2 ;;
  esac
}

main() {
  ensure_dir
  local file="${OUT_DIR}/Screenshot_$(ts).png"

  if command -v grimblast >/dev/null 2>&1; then
    shoot_with_grimblast "$MODE" "$file"
  else
    # Chequeos mínimos
    command -v grim >/dev/null 2>&1 || { echo "Falta 'grim'"; exit 1; }
    if [ "$MODE" = "area" ]; then
      command -v slurp >/dev/null 2>&1 || { echo "Falta 'slurp'"; exit 1; }
    fi
    shoot_fallback "$MODE" "$file"
  fi

  annotate_swappy "$file"
  copy_clip "$file"
  ding
  notify "Captura guardada" "$file"
  echo "$file"
}

main "$@"
