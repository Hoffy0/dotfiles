#!/usr/bin/env bash
# Instalador de dotfiles. Dos formas de correrlo:
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/Hoffy0/dotfiles/main/install.sh)"
#   ~/.dotfiles/install.sh
#
# Desde curl no hay repo al lado: lo clona (o actualiza) en $DOTFILES_DIR y se
# re-ejecuta desde ahi. Variables opcionales:
#   DOTFILES_DIR     destino del clon      (default: ~/.dotfiles)
#   DOTFILES_REPO    URL del repo          (default: GitHub por HTTPS)
#   DOTFILES_BRANCH  rama                  (default: main)
#
# Todo va dentro de main(), que se llama en la ultima linea: si la descarga
# se corta a medias, bash no ejecuta un script truncado.
set -euo pipefail

OS=$(uname -s)
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/Hoffy0/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

# Si el script vive dentro de un clon, imprime su raiz.
repo_dir() {
    local src="${BASH_SOURCE[0]:-}" dir
    [[ -n "$src" && -f "$src" ]] || return 1
    dir="$(cd "$(dirname "$src")" && pwd)"
    [[ -d "$dir/.git" ]] && echo "$dir"
}

bootstrap() {
    local dest="${DOTFILES_DIR:-$HOME/.dotfiles}"

    if ! command -v git >/dev/null; then
        echo "==> Instalando git..."
        if [[ "$OS" == "Darwin" ]]; then
            xcode-select --install || true
            echo "Termina la instalacion de las Command Line Tools y vuelve a correr el comando." >&2
            exit 1
        fi
        sudo dnf install -y git
    fi

    if [[ -d "$dest/.git" ]]; then
        echo "==> Actualizando $dest..."
        git -C "$dest" pull --ff-only
    elif [[ -e "$dest" ]]; then
        echo "error: $dest existe y no es un repo git; muevelo o usa DOTFILES_DIR=..." >&2
        exit 1
    else
        echo "==> Clonando $DOTFILES_REPO en $dest..."
        git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$dest"
    fi

    # Con 'curl | bash' el stdin es el pipe: devolverle la terminal para que
    # sudo, chsh y compania puedan preguntar.
    if [[ ! -t 0 ]] && { : </dev/tty; } 2>/dev/null; then
        exec bash "$dest/install.sh" "$@" </dev/tty
    fi
    exec bash "$dest/install.sh" "$@"
}

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

main() {
    DOTFILES="$(repo_dir)" || bootstrap "$@"

    echo "==> Instalando dotfiles en $OS desde $DOTFILES..."

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
}

main "$@"
