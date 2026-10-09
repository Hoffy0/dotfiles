#!/usr/bin/env bash
set -euo pipefail

OS=$(uname -s)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Instalando dotfiles en $OS..."

install_brew() {
    if ! command -v brew >/dev/null; then
        echo "==> Instalando Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Recien instalado no esta en el PATH de este proceso
    local b
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        [[ -x "$b" ]] && { eval "$("$b" shellenv)"; return; }
    done
}

clone_if_missing() {
    [[ -d "$2" ]] || git clone --depth=1 "$1" "$2"
}

install_omz() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "==> Instalando Oh My Zsh..."
        # Si no hay .zshrc el instalador deja una plantilla; backup_conflicts
        # la aparta antes de stow.
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"
    clone_if_missing https://github.com/junegunn/fzf-git.sh "$HOME/fzf-git.sh"
}

# Mueve a ~/.dotfiles-backup/<fecha>/ los archivos reales que stow no puede
# pisar (p.ej. el .zshrc de plantilla o el hyprland.conf autogenerado).
backup_conflicts() {
    local backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)" target
    while read -r target; do
        [[ -n "$target" ]] || continue
        echo "    backup: ~/$target"
        mkdir -p "$backup/$(dirname "$target")"
        mv "$HOME/$target" "$backup/$target"
    done < <(stow -n --restow -t "$HOME" . 2>&1 |
             sed -nE 's/.*over existing target (.+) since .*/\1/p')
}

if [[ "$OS" == "Darwin" ]]; then
    install_brew
    echo "==> Instalando paquetes..."
    brew bundle --file="$DOTFILES/Brewfile"
    brew bundle --file="$DOTFILES/Brewfile.mac"

elif [[ "$OS" == "Linux" ]]; then
    if command -v dnf >/dev/null; then
        sudo dnf install -y @development-tools procps-ng curl file git stow zsh
        "$DOTFILES/system/fedora/install.sh"
    fi
    install_brew
    echo "==> Instalando paquetes..."
    brew bundle --file="$DOTFILES/Brewfile"
fi

install_omz

echo "==> Aplicando symlinks con stow..."
cd "$DOTFILES"
backup_conflicts
stow --restow -t "$HOME" .

if command -v mise >/dev/null; then
    echo "==> Instalando herramientas de mise..."
    mise install
fi

zsh_path=$(grep -m1 '/zsh$' /etc/shells || true)
if [[ -n "$zsh_path" && "${SHELL:-}" != "$zsh_path" ]]; then
    echo "==> Cambiando shell a $zsh_path..."
    chsh -s "$zsh_path"
fi

echo ""
echo "✓ Listo. Reinicia la sesion para aplicar todos los cambios."
if [[ "$OS" == "Linux" ]]; then
    echo "  Pasos manuales de sistema: system/noctalia-greeter y system/reboot-to-windows"
fi
