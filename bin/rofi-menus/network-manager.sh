#!/usr/bin/env bash

# Active connection (skip loopback)
ACTIVE=$(nmcli -t -f NAME,DEVICE connection show --active | grep -v ":lo$" | head -1)
CON_NAME=$(cut -d: -f1 <<< "$ACTIVE")

[[ -z "$CON_NAME" ]] && { notify-send -a "Red" "Sin conexión activa"; exit 1; }

CURRENT_IP=$(nmcli -g IP4.ADDRESS connection show "$CON_NAME" 2>/dev/null | head -1)
CURRENT_GW=$(nmcli -g IP4.GATEWAY connection show "$CON_NAME" 2>/dev/null)
CURRENT_DNS=$(nmcli -g IP4.DNS connection show "$CON_NAME" 2>/dev/null | paste -sd ',' -)
CURRENT_METHOD=$(nmcli -g ipv4.method connection show "$CON_NAME" 2>/dev/null)

[[ "$CURRENT_METHOD" == "auto" ]] && METHOD_LABEL="DHCP" || METHOD_LABEL="Manual"

choice=$(printf "󱘖  IP Manual\n󰑓  Cambiar a DHCP\n󰇢  Editar DNS\n  Reiniciar conexión" | \
    rofi -dmenu -p "󰈀  ${CON_NAME}  ·  ${METHOD_LABEL}  ·  ${CURRENT_IP:-sin IP}")

[[ -z "$choice" ]] && exit 0

reconnect() {
    nmcli connection up "$CON_NAME" || notify-send -a "Red" "Error al reconectar" "$CON_NAME"
}

case "$choice" in
    "󱘖  IP Manual")
        IP=$(echo "${CURRENT_IP:-192.168.1.100/24}" | rofi -dmenu -p "IP / Máscara  (ej: 192.168.1.100/24)" -lines 1)
        [[ -z "$IP" ]] && exit 0
        GW=$(echo "${CURRENT_GW:-192.168.1.1}" | rofi -dmenu -p "Gateway" -lines 1)
        [[ -z "$GW" ]] && exit 0
        DNS=$(echo "${CURRENT_DNS:-8.8.8.8,1.1.1.1}" | rofi -dmenu -p "DNS (separados por coma)" -lines 1)
        [[ -z "$DNS" ]] && exit 0
        nmcli connection modify "$CON_NAME" \
            ipv4.method manual \
            ipv4.addresses "$IP" \
            ipv4.gateway "$GW" \
            ipv4.dns "$DNS" \
            ipv4.ignore-auto-dns yes && reconnect && \
            notify-send -a "Red" "IP Manual configurada" "${IP}  ·  GW: ${GW}  ·  DNS: ${DNS}"
        ;;
    "󰑓  Cambiar a DHCP")
        nmcli connection modify "$CON_NAME" \
            ipv4.method auto \
            ipv4.addresses "" \
            ipv4.gateway "" \
            ipv4.dns "" \
            ipv4.ignore-auto-dns no && reconnect && \
            notify-send -a "Red" "Cambiado a DHCP" "$CON_NAME"
        ;;
    "󰇢  Editar DNS")
        DNS=$(echo "${CURRENT_DNS:-8.8.8.8,1.1.1.1}" | rofi -dmenu -p "DNS (separados por coma)" -lines 1)
        [[ -z "$DNS" ]] && exit 0
        nmcli connection modify "$CON_NAME" \
            ipv4.dns "$DNS" \
            ipv4.ignore-auto-dns yes && reconnect && \
            notify-send -a "Red" "DNS actualizado" "$DNS"
        ;;
    "  Reiniciar conexión")
        notify-send -a "Red" "Reiniciando..." "$CON_NAME"
        nmcli connection down "$CON_NAME" 2>/dev/null
        sleep 1
        nmcli connection up "$CON_NAME" && notify-send -a "Red" "Conexión reiniciada" "$CON_NAME"
        ;;
esac
