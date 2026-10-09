# Dotfiles

Configuración personal para **Fedora 43 + Hyprland + Noctalia** (equipo principal, NVIDIA, monitor 4K) y **macOS** (solo shell y apps). Los archivos se enlazan al `$HOME` con [GNU Stow](https://www.gnu.org/software/stow/).

## Instalación

```bash
git clone https://github.com/Hoffy0/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

`install.sh` es idempotente: se puede volver a correr sin romper nada. Pide `sudo` para los pasos de sistema.

### Qué hace en Fedora

1. Instala las dependencias de Homebrew (`@development-tools procps-ng curl file git`), además de `stow` y `zsh`.
2. Corre `system/fedora/install.sh`:
   - Activa RPM Fusion (free + nonfree), Terra y el repo de Microsoft.
   - Activa los COPR de `system/fedora/coprs.txt`.
   - Copia los repos de terceros de `system/fedora/repos/` a `/etc/yum.repos.d/` (Chrome, Brave, VS Code, 1Password, Docker, Tailscale, Twingate, Lens, Beekeeper, Antigravity).
   - Instala `system/fedora/packages.txt` (driver NVIDIA, Hyprland, Noctalia, utilidades del escritorio y apps).
   - Instala los flatpaks de `system/fedora/flatpaks.txt`.
   - Habilita Docker y agrega el usuario al grupo `docker`.
   - Descarga JetBrainsMono Nerd Font en `~/.local/share/fonts`.
3. Instala Homebrew y el `Brewfile`.
4. Instala Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, powerlevel10k y `~/fzf-git.sh`.
5. Mueve a `~/.dotfiles-backup/<fecha>/` los archivos reales que chocan con stow (por ejemplo, la plantilla de `.zshrc` de Oh My Zsh o el `hyprland.conf` que genera Hyprland), y después corre `stow --restow`.
6. Corre `mise install` (Node y `@nestjs/cli`, ver `.config/mise/config.toml`).
7. Cambia el shell de login a zsh.

### Qué hace en macOS

Instala Homebrew, `Brewfile` y `Brewfile.mac` (incluye la fuente y las apps como cask). Después hace los pasos 4 a 7.

## Pasos manuales

Esto **no** lo cubre `install.sh`.

### Antes de formatear

- [ ] `git push`: que no queden commits sin subir.
- [ ] Respaldar `~/.gnupg`: tiene llaves privadas.
- [ ] Respaldar `~/Pictures/wallpapers`: Noctalia y `wallpaper-selector.sh` leen de ahí.
- [ ] Respaldar `~/.face`: el avatar de Noctalia.
- [ ] Respaldar `~/.ssh/config` y `~/.ssh/known_hosts`. Las llaves viven en 1Password (agente SSH), no hace falta copiarlas.
- [ ] Respaldar los proyectos de `~/Dev` que no estén en un remoto.
- [ ] Windows comparte disco y partición EFI con Fedora (`nvme0n1`). Si se reemplaza ese disco, Windows también se pierde.

### Después de `install.sh`

1. **Reiniciar.** El módulo NVIDIA (`akmod-nvidia`) se compila en el primer arranque. Con Secure Boot activo hay que enrolar la llave MOK (`sudo mokutil --import /etc/pki/akmods/certs/public_key.der`) y confirmarla al reiniciar.
2. **Iniciar sesión en Hyprland** desde GDM. Noctalia lo arranca el `exec-once` de `hyprland.conf` vía `noctalia-shell.service`; no hay que habilitar nada.
3. **Paquetes sin repo**, instalados desde un `.rpm` descargado:
   - `webex`: https://www.webex.com/downloads.html
   - `genoffice`
4. **Reboot a Windows** (botón del session menu de Noctalia, `Super+X`):
   ```bash
   sudo ./system/reboot-to-windows/install.sh --label
   ```
   El sudoers tiene el usuario `hoffy` escrito a mano; si cambia el usuario, hay que editar `system/reboot-to-windows/sudoers`.
   El alias `reboot-windows` de `.zshrc.linux` usa la entrada EFI `0005` fija. Después de reinstalar, revisarla con `efibootmgr`. El script `bin/reboot-to-windows.sh` no tiene ese problema: busca la entrada por nombre.
5. **Grupo docker**: cerrar sesión y volver a entrar para usar `docker` sin sudo.
6. **Logins**: `gh auth login`, 1Password (activar el agente SSH en Ajustes → Desarrollador), Tailscale (`sudo tailscale up`), Twingate y `az login`.
7. **Remote del repo a SSH**: el clon inicial es por HTTPS porque el agente SSH de 1Password todavía no existe. Una vez activado (paso 6), cambiar el remote para poder hacer push:
   ```bash
   ssh -T git@github.com    # tiene que responder "Hi Hoffy0!"
   git -C ~/.dotfiles remote set-url origin git@github.com:Hoffy0/dotfiles.git
   ```
8. **VS Code**: activar Settings Sync para recuperar las extensiones y la configuración.
9. **Neovim**: abrir `nvim` una vez para que lazy.nvim instale los plugins. `lazy-lock.json` no se versiona.

### No activar: noctalia-greeter

`system/noctalia-greeter/` reemplaza GDM por greetd, pero **está desactivado a propósito**: GNOME Remote Login (RDP) depende de GDM. Ver `system/noctalia-greeter/README.md`.

## Estructura

```
.
├── install.sh                 # instalador (no se enlaza)
├── Brewfile                   # CLI cross-platform
├── Brewfile.mac               # casks y fuente, solo macOS
├── .zshenv                    # shims de mise para shells no interactivos
├── .zshrc                     # Oh My Zsh + p10k + fzf + thefuck + aliases
├── .zshrc.linux / .darwin     # se cargan según el SO
├── .p10k.zsh                  # prompt powerlevel10k
├── .gitconfig                 # delta como pager, diff3
├── bin/                       # scripts → ~/bin
├── .config/
│   ├── hypr/                  # Hyprland 0.56 (keybindings, windowrules, nvidia, monitores)
│   ├── noctalia/              # shell: barra, launcher, notificaciones, OSD, lock
│   ├── systemd/user/          # noctalia-shell.service
│   ├── ghostty/               # terminal
│   ├── nvim/                  # NvChad
│   ├── rofi/                  # menús de bin/rofi-menus
│   ├── mise/                  # versiones de Node y CLIs globales
│   ├── fastfetch/ thefuck/
│   └── waybar/ swaync/        # en desuso (reemplazados por Noctalia), se conservan
└── system/                    # archivos de root, no se enlazan
    ├── fedora/                # repos, COPR, paquetes, flatpaks + su install.sh
    ├── noctalia-greeter/      # greetd (desactivado, ver arriba)
    └── reboot-to-windows/     # helper BootNext + sudoers
```

`.stow-local-ignore` excluye del enlace `install.sh`, `Brewfile*`, `README*`, `system/` y `.claude/`.

## Específico de este equipo

Todo esto es intencional, pero hay que ajustarlo en otro hardware:

- `.config/hypr/monitors.conf`: `DP-5` en 3840x2160@60, escala 1.5.
- `.config/hypr/nvidia.conf`: se carga siempre. Sin GPU NVIDIA, quitar el `source` de `hyprland.conf`. Es obligatorio `QT_QPA_PLATFORM`; sin él Noctalia arranca pero no dibuja.
- Rutas con `/home/hoffy`: `.config/noctalia/settings.json` (wallpapers y avatar), `bin/rofi-menus/wallpaper-selector.sh` y `system/reboot-to-windows/sudoers`.
- `.config/noctalia/settings.json`: Noctalia lo reescribe completo al cambiar algo desde la UI, así que hay que esperar diffs grandes.

## Atajos principales

| Atajo | Acción |
|---|---|
| `Super+Enter` | Ghostty |
| `Super+D` | Launcher (Noctalia) |
| `Super+V` | Historial del portapapeles |
| `Super+X` | Menú de sesión |
| `Super+L` | Bloquear |
| `Super+A` | Cambiar salida de audio (rofi) |
| `Super+O` | Centro de control |
| `Super+W` | Wallpaper |
| `Print` | Captura de área |
| `Super+Q` | Cerrar ventana |

Lista completa en `.config/hypr/keybindings.conf`.
