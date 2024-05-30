# Dotfiles

Este repositorio contiene mis configuraciones personales para varias aplicaciones y herramientas. Utilizo [GNU Stow](https://www.gnu.org/software/stow/) para gestionar y sincronizar estos archivos de configuración de manera eficiente.

## Contenido

El repositorio contiene las siguientes configuraciones:

- `.zshrc`: Configuración de Zsh con Oh My Zsh, plugins, alias y más.
- `.config/nvim/`: Configuración para Neovim.
  - `init.lua`: Archivo principal de configuración.
  - `lazy-lock.json`: Archivo de bloqueo para plugins.
  - `LICENSE`: Licencia del proyecto.
  - `lua/`: Archivos de configuración adicionales en Lua.
  - `.stylua.toml`: Archivo de configuración para Stylua.
- `.config/rofi/`: Configuración para Rofi.
  - `config.rasi`: Archivo de configuración para Rofi.
- `git/.gitconfig`: Configuración personalizada para Git.
- `.gitignore`: Archivos y carpetas a ignorar por Git.

## Requisitos

- [GNU Stow](https://www.gnu.org/software/stow/): Para gestionar los archivos de configuración.
- [Zsh](https://www.zsh.org/): Shell Zsh.
- [Oh My Zsh](https://ohmyz.sh/): Framework para gestionar la configuración de Zsh.
- [Neovim](https://neovim.io/): Editor de texto.
- [Rofi](https://github.com/davatorium/rofi): Lanzador de aplicaciones y más.

### Programas adicionales

- [fzf](https://github.com/junegunn/fzf): Un buscador de línea de comandos.
- [fd](https://github.com/sharkdp/fd): Una alternativa simple, rápida y fácil de usar a `find`.
- [fzf-git](https://github.com/junegunn/fzf-git.sh): Extensiones para usar `fzf` con Git.
- [bat](https://github.com/sharkdp/bat): Un clon de `cat` con resaltado de sintaxis y más.
- [delta](https://github.com/dandavison/delta): Un mejor pager para `git diff` y `git log`.
- [eza](https://github.com/eza-community/eza): Un reemplazo moderno para `ls`.
- [thefuck](https://github.com/nvbn/thefuck): Una herramienta para corregir errores en la línea de comandos.

## Instalación

1. Clona el repositorio en tu directorio home (o en cualquier otro lugar de tu preferencia):

    ```bash
    git clone https://github.com/tu-usuario/dotfiles.git ~/.dotfiles
    ```

2. Cambia al directorio del repositorio:

    ```bash
    cd ~/.dotfiles
    ```

3. Mueve los archivos en conflicto (si existen) para evitar conflictos:

    ```bash
    mv ~/.config/nvim ~/.config/nvim_backup
    mv ~/.config/rofi ~/.config/rofi_backup
    mv ~/.zshrc ~/.zshrc_backup
    mv ~/.gitconfig ~/.gitconfig_backup
    ```

4. Utiliza Stow para gestionar los dotfiles:

    ```bash
    stow .
    stow git
    ```

## Personalización

Puedes personalizar cualquiera de estos archivos según tus necesidades. Para cambiar un archivo de configuración, simplemente edítalo en el directorio correspondiente dentro de `~/dotfiles` y vuelve a aplicar `stow` si es necesario.

## Contribuciones

Si tienes sugerencias o mejoras, siéntete libre de abrir un issue o enviar un pull request. ¡Toda contribución es bienvenida!

## Referencias

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/)
- [Rofi](https://github.com/davatorium/rofi)
- [fzf](https://github.com/junegunn/fzf)
- [fd](https://github.com/sharkdp/fd)
- [fzf-git](https://github.com/junegunn/fzf-git.sh)
- [bat](https://github.com/sharkdp/bat)
- [delta](https://github.com/dandavison/delta)
- [eza](https://github.com/eza-community/eza)
- [thefuck](https://github.com/nvbn/thefuck)

