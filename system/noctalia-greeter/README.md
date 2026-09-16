# noctalia-greeter — DESACTIVADO a proposito

Funciona, esta probado, y **no hay que activarlo** mientras se use RDP.

## Por que

El acceso remoto a esta maquina es **GNOME Remote Login**: el modo `--system`
de `gnome-remote-desktop`. Ese modo esta construido encima de GDM — cuando
llega una conexion, le pide a GDM que cree la sesion remota por D-Bus:

    org.gnome.DisplayManager.RemoteDisplay -> CreateRemoteDisplay

(verificable con `strings /usr/libexec/gnome-remote-desktop-daemon | grep GDM`)

Sin GDM el servicio arranca igual y queda `active (running)`, pero **nunca abre
el puerto 3389**, porque no tiene a quien delegar la sesion. El sintoma es
`ss -ltnp | grep 3389` vacio, sin un solo error en el journal.

## Por que no hay forma de tener los dos

- Solo un display manager puede ser `display-manager.service`.
- GDM siempre intenta crear un display local en `seat0`
  (`GdmLocalDisplayFactory`). No hay opcion en `/etc/gdm/custom.conf` para
  desactivarlo; solo se lo saltea si logind reporta que el seat no tiene
  gráficos, lo que romperia greetd tambien.
- `xrdp` no es alternativa: su backend `xorgxrdp` necesita una sesion X11, y
  GNOME 49 (Fedora 43) es solo Wayland — `/usr/share/xsessions/` esta vacio.

## Que se pierde y que no

Con GDM se elige **Hyprland** en la lista de sesiones al entrar fisicamente.
El escritorio es identico: Hyprland, Noctalia como shell, los mismos keybinds.
Lo unico que se pierde es la pantalla de login de Noctalia.

## Si algun dia se deja de usar RDP

    sudo ./install.sh          # reinstala greetd + noctalia-greeter
    sudo systemctl disable gdm && sudo systemctl enable greetd

Rollback, desde una TTY (Ctrl+Alt+F3) si algo sale mal:

    sudo systemctl disable greetd && sudo systemctl enable gdm && sudo reboot
