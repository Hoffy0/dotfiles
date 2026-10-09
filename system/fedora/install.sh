#!/usr/bin/env bash
# Repos y paquetes de sistema para Fedora. Lo llama ../../install.sh,
# pero se puede correr solo. Idempotente.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FEDORA=$(rpm -E %fedora)

# Lista sin comentarios ni lineas vacias
list() { sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1"; }

echo "==> RPM Fusion..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA}.noarch.rpm"

echo "==> Terra..."
rpm -q terra-release >/dev/null 2>&1 || \
    sudo dnf install -y --nogpgcheck \
        --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA}" terra-release

echo "==> Microsoft (azure-cli)..."
rpm -q packages-microsoft-prod >/dev/null 2>&1 || \
    sudo dnf install -y https://packages.microsoft.com/config/rhel/10/packages-microsoft-prod.rpm

echo "==> COPR..."
sudo dnf install -y dnf5-plugins
while read -r copr; do
    sudo dnf copr enable -y "$copr"
done < <(list "$HERE/coprs.txt")

echo "==> Repos de terceros..."
sudo install -m 644 "$HERE"/repos/*.repo /etc/yum.repos.d/

echo "==> Paquetes..."
# --skip-unavailable: que un paquete renombrado no tumbe todo el resto
mapfile -t pkgs < <(list "$HERE/packages.txt")
sudo dnf install -y --skip-unavailable "${pkgs[@]}"

echo "==> Flatpaks..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
mapfile -t apps < <(list "$HERE/flatpaks.txt")
flatpak install -y flathub "${apps[@]}"

echo "==> Docker..."
sudo systemctl enable --now docker
getent group docker | grep -qw "$USER" || sudo usermod -aG docker "$USER"

echo "==> Fuente JetBrainsMono Nerd Font..."
fonts="$HOME/.local/share/fonts"
if ! fc-list | grep -qi 'JetBrainsMono Nerd'; then
    mkdir -p "$fonts"
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/f.tar.xz" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    tar -xf "$tmp/f.tar.xz" -C "$fonts" --wildcards '*.ttf'
    rm -rf "$tmp"
    fc-cache -f "$fonts"
fi
