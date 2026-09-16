#!/usr/bin/env bash
# Instala el helper root que apunta BootNext a Windows, mas la regla sudoers
# que deja usarlo sin password. Esto NO lo cubre stow: son archivos de root.
#
#   sudo ./system/reboot-to-windows/install.sh
#
# Lo usa ~/bin/reboot-to-windows.sh, que a su vez cuelga de la entrada
# "userspaceReboot" del sessionMenu de Noctalia (Super+X, tecla 8).
#
# Desinstalar:
#   sudo rm /usr/local/bin/set-bootnext-windows /etc/sudoers.d/reboot-to-windows
#
# Con --label ademas renombra el boton "Userspace Reboot" a "Reboot to Windows"
# parcheando las traducciones de /etc/xdg (deja .orig al lado).
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "error: correr con sudo." >&2; exit 1; }
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v efibootmgr >/dev/null || { echo "error: falta efibootmgr (dnf install efibootmgr)." >&2; exit 1; }

echo "==> Helper root"
# root:root 0755 es obligatorio: si el usuario pudiera editarlo, la regla
# NOPASSWD de abajo seria una escalada de privilegios directa.
install -m 0755 -o root -g root "$DIR/set-bootnext-windows" /usr/local/bin/set-bootnext-windows
restorecon /usr/local/bin/set-bootnext-windows 2>/dev/null || true

echo "==> Regla sudoers"
install -m 0440 -o root -g root "$DIR/sudoers" /etc/sudoers.d/reboot-to-windows
# visudo -c valida TODO /etc/sudoers.d; si el archivo nuevo esta mal, se borra
# antes de que rompa sudo por completo.
if ! visudo -c >/dev/null; then
  rm -f /etc/sudoers.d/reboot-to-windows
  echo "error: sudoers invalido, se revirtio." >&2
  exit 1
fi

# El label del boton lo saca Noctalia de sus JSON de traduccion, que son del
# paquete noctalia-shell-legacy. No hay forma de overridearlo desde el config del
# usuario, asi que se parchea in-place: opcional, y se pierde al actualizar el
# paquete (volver a correr este script lo re-aplica).
if [[ "${1:-}" == "--label" ]]; then
  echo "==> Label del boton"
  for f in /etc/xdg/quickshell/noctalia-shell/Assets/Translations/*.json; do
    [[ -f "$f.orig" ]] || cp -a "$f" "$f.orig"
    sed -i 's/"userspace-reboot": ".*"/"userspace-reboot": "Reboot to Windows"/' "$f"
  done
fi

echo "==> Verificacion"
efibootmgr | grep -q "Windows Boot Manager" \
  || echo "aviso: no hay entrada EFI 'Windows Boot Manager'; el helper va a fallar."

echo
echo "Listo. Probar sin reiniciar:"
echo "  sudo -n /usr/local/bin/set-bootnext-windows   # imprime el bootnum, ej 0009"
echo "  efibootmgr | head -3                          # tiene que aparecer BootNext"
echo "  sudo efibootmgr --delete-bootnext             # cancelar la prueba"
echo
echo "Para renombrar el boton del menu: sudo $0 --label"
