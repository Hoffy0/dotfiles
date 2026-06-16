# Cargado en TODOS los shells (interactivos y no-interactivos)
# Agrega shims de mise directamente — no depende de que mise esté en PATH
typeset -U path
path=("$HOME/.local/share/mise/shims" $path)
export PATH
