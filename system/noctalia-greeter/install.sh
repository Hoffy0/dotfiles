#!/usr/bin/env bash
# Reemplaza GDM por noctalia-greeter (greetd). Fedora + SELinux enforcing.
# Esto NO lo cubre stow: son archivos de root y estado de systemd/SELinux.
#
#   sudo ./system/noctalia-greeter/install.sh
#
# Rollback si al reiniciar no hay login grafico: Ctrl+Alt+F3 y
#   sudo systemctl disable greetd && sudo systemctl enable gdm && sudo reboot
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "error: correr con sudo." >&2; exit 1; }
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE=/var/lib/noctalia-greeter

echo "==> Repo COPR"
dnf copr enable -y lionheartp/Hyprland

echo "==> Paquetes"
# Shell + su runtime quickshell. Las variantes '-legacy' son las que van con
# Hyprland 0.56 / Qt 6.10 de Fedora 43; noctalia-shell-v5 es la rama nueva.
dnf install -y noctalia-shell-legacy noctalia-qs-legacy
dnf install -y noctalia-greeter greetd greetd-selinux

echo "==> Config de greetd"
[[ -f /etc/greetd/config.toml ]] && cp -an /etc/greetd/config.toml /etc/greetd/config.toml.orig
install -m 0644 -o root -g root "$DIR/greetd-config.toml" /etc/greetd/config.toml
restorecon /etc/greetd/config.toml

echo "==> Estado del greeter"
install -d -m 0750 -o greetd -g greetd "$STATE"
install -m 0640 -o greetd -g greetd "$DIR/greeter.toml" "$STATE/greeter.toml"

# El greeter corre en el dominio xdm_t y escribe su sync.toml aca. Sin esta
# etiqueta el directorio queda como var_lib_t generico y SELinux lo bloquea.
echo "==> Etiqueta SELinux"
semanage fcontext -a -t xdm_var_lib_t "${STATE}(/.*)?" 2>/dev/null || true
restorecon -R "$STATE"

# NO se aplica el parche PAM de upstream (setup_greetd_pam.sh): en Fedora,
# /etc/pam.d/greetd ya incluye system-auth, que trae pam_systemd.so como
# 'optional'. El script agregaria un duplicado 'required', convirtiendo un
# fallo de pam_systemd en un login roto.

echo "==> Cambio de display manager (gdm queda instalado, solo deshabilitado)"
systemctl disable gdm
systemctl enable greetd

echo
echo "Listo. Verificar antes de reiniciar:"
echo "  systemctl is-enabled gdm greetd   # -> disabled / enabled"
echo "  noctalia-greeter sessions         # tiene que listar Hyprland"
