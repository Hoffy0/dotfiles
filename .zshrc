# 1. SILENCIAR WARNINGS DE P10K
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# 2. FASTFETCH — debe ir antes del instant prompt para integrarse sin warnings
if [[ -o interactive ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        fastfetch --logo apple 2>/dev/null
    else
        fastfetch --logo ~/.config/fastfetch/logos/fedora.png --logo-type kitty 2>/dev/null
    fi
fi

# 3. POWERLEVEL10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 4. CONFIGURACIÓN OH-MY-ZSH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# 5. PATHS BASE
typeset -U path
path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.console-ninja/.bin
  $HOME/.pyenv/bin
  $HOME/.opencode/bin
  $path
)

# 6. CONFIGURACIÓN POR SISTEMA — antes de tools para que brew esté en PATH
_os=$(uname -s | tr '[:upper:]' '[:lower:]')
[[ -f ~/.zshrc.${_os} ]] && source ~/.zshrc.${_os}
unset _os

# 7. HERRAMIENTAS Y GESTORES
export PNPM_HOME="$HOME/.local/share/pnpm"
[[ -d "$PNPM_HOME" ]] && path=("$PNPM_HOME" $path)

if command -v mise >/dev/null; then
    eval "$(mise activate zsh)"
fi

if command -v fzf >/dev/null; then
    eval "$(fzf --zsh)"
    [[ -f ~/fzf-git.sh/fzf-git.sh ]] && source ~/fzf-git.sh/fzf-git.sh
fi

if command -v thefuck >/dev/null; then
    eval "$(thefuck --alias)"
    eval "$(thefuck --alias fk)"
fi

# 8. ALIASES Y HISTORIAL
alias zshconfig="nvim ~/.zshrc"
alias reload-zsh="source ~/.zshrc"
alias ls="eza --color=always --long --git --icons=always --no-time --no-user --no-permissions"

HISTFILE=$HOME/.zhistory
SAVEHIST=2000
HISTSIZE=2000
setopt share_history
setopt hist_ignore_dups
setopt hist_verify

# 9. P10K
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:/home/hoffy/.spicetify
export PATH=$PATH:$HOME/.spicetify
