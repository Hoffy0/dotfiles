#!/usr/bin/env bash
set -euo pipefail

OS=$(uname -s)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Instalando dotfiles en $OS..."

install_brew() {
    if ! command -v brew >/dev/null; then
        echo "==> Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

install_omz() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "==> Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    [[ ! -d "$custom/plugins/zsh-autosuggestions" ]] && \
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
    [[ ! -d "$custom/plugins/zsh-syntax-highlighting" ]] && \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting"
    [[ ! -d "$custom/themes/powerlevel10k" ]] && \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"
}

if [[ "$OS" == "Darwin" ]]; then
    install_brew
    echo "==> Instalando paquetes..."
    brew bundle --file="$DOTFILES/Brewfile"
    brew bundle --file="$DOTFILES/Brewfile.mac"

elif [[ "$OS" == "Linux" ]]; then
    if ! command -v stow >/dev/null; then
        echo "==> Instalando stow..."
        sudo dnf install -y stow
    fi
    install_brew
    echo "==> Instalando paquetes..."
    brew bundle --file="$DOTFILES/Brewfile"
fi

install_omz

echo "==> Aplicando symlinks con stow..."
cd "$DOTFILES"
stow --restow --ignore='.DS_Store' .

echo ""
echo "✓ Listo. Reinicia la terminal para aplicar todos los cambios."
