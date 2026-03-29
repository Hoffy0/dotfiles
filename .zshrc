# 0 Refresh cache
# (Comentado para evitar el error 'no matches found' al abrir la terminal)
rm -rf ~/.cache/p10k-instant-prompt-*

# 1. SILENCIAR WARNINGS (Debe ser la línea 1)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# 2. POWERLEVEL10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 3. CONFIGURACIÓN OH-MY-ZSH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# 4. PATHS (Agnóstico Fedora/Mac)
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/.config/scripts
  $HOME/.console-ninja/.bin
  $HOME/.pyenv/bin
  $HOME/.opencode/bin
  $path
)

# 5. CONFIGURACIÓN POR SISTEMA
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$HOME/.spicetify:$PATH"
else
    # Linux (Fedora)
    [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    path=(/home/linuxbrew/.linuxbrew/bin/ninja $path)
    alias reboot-windows='sudo efibootmgr -n 0005 && sudo reboot'
    
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        alias code='env OZONE_PLATFORM=wayland code --ozone-platform=wayland --enable-features=WaylandWindowDecorations'
    fi
    
    explorer() {
        local path="${1:-.}"
        /usr/bin/nautilus "$path" >/dev/null 2>&1 & disown
    }
fi

# 6. HERRAMIENTAS Y GESTORES
export PNPM_HOME="$HOME/.local/share/pnpm"
[[ -d "$PNPM_HOME" ]] && path=("$PNPM_HOME" $path)

# Activar Mise (Reemplazo de NVM y Pyenv)
if command -v mise >/dev/null; then
    eval "$(mise activate zsh)"
fi

# Carga de FZF y TheFuck
if command -v fzf >/dev/null; then
    eval "$(fzf --zsh)"
    source ~/fzf-git.sh/fzf-git.sh 2>/dev/null
fi

if command -v thefuck >/dev/null; then
    eval $(thefuck --alias)
    eval $(thefuck --alias fk)
fi

# 7. ALIASES Y HISTORIAL
alias zshconfig="nvim ~/.zshrc"
alias reload-zsh="source ~/.zshrc"
alias ls="eza --color=always --long --git --icons=always --no-time --no-user --no-permissions"

HISTFILE=$HOME/.zhistory
SAVEHIST=2000
HISTSIZE=2000
setopt share_history 
setopt hist_ignore_dups
setopt hist_verify

# 8. FINALIZACIÓN (P10k y Fastfetch)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Solo ejecutar fastfetch al final y silenciar errores de renderizado
if [[ -o interactive ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        fastfetch --logo apple 2>/dev/null
    else
        fastfetch --logo ~/.config/fastfetch/logos/fedora.png --logo-type kitty 2>/dev/null
    fi
fi
export PATH=$PATH:$HOME/.spicetify

# Added by Antigravity
export PATH="/Users/hoffy/.antigravity/antigravity/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/hoffy/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
