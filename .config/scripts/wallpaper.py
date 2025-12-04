#!/usr/bin/env python3
from __future__ import annotations
import json, os, random, subprocess, sys
from argparse import ArgumentParser, RawTextHelpFormatter
from pathlib import Path

# === Rutas pedidas ===
SCRIPTS_DIR = Path(os.getenv("XDG_CONFIG_HOME", Path.home() / ".config")) / "scripts"
CFG_FILE    = SCRIPTS_DIR / "wallpaper.json"   # <- nada de ~/.config/meowarcfh
WALL_DIR    = Path.home() / "Pictures" / "wallpapers"

DEFAULTS = {
    "current_wallpaper": "",
    "wallpapers_dir": str(WALL_DIR),
    "allowed_extensions": [".png", ".jpg", ".jpeg", ".webp"],
    "picker": "rofi",            # rofi | wofi
    "use_swww": True,            # si swww no está, cae a hyprpaper
    "sww_tr_type": "any",
    "sww_tr_duration": 0.6,
    "sww_tr_fps": 60
}

def _ensure_dirs():
    SCRIPTS_DIR.mkdir(parents=True, exist_ok=True)
    WALL_DIR.mkdir(parents=True, exist_ok=True)

def _read_cfg() -> dict:
    _ensure_dirs()
    if not CFG_FILE.exists():
        CFG_FILE.write_text(json.dumps(DEFAULTS, indent=2), encoding="utf-8")
        return DEFAULTS.copy()
    try:
        data = json.loads(CFG_FILE.read_text(encoding="utf-8") or "{}")
    except Exception:
        data = {}
    merged = DEFAULTS.copy(); merged.update(data or {})
    return merged

def _write_cfg(obj: dict):
    _ensure_dirs()
    CFG_FILE.write_text(json.dumps(obj, indent=2), encoding="utf-8")

def _notify(title: str, body: str):
    try: subprocess.Popen(["notify-send", title, body])
    except Exception: pass

def _cmd_exists(cmd: str) -> bool:
    return subprocess.call(["bash","-lc", f"type -p {cmd} >/dev/null 2>&1"]) == 0

# ==== backends ====
def _ensure_swww_daemon():
    # Si ya está corriendo, listo
    if subprocess.call(["bash","-lc","swww query >/dev/null 2>&1"]) == 0:
        return
    # Arranca el daemon (sin namespaces)
    subprocess.call(["bash","-lc","pgrep -x swww-daemon >/dev/null 2>&1 || (swww-daemon & disown)"])
    subprocess.call(["bash","-lc","sleep 0.2"])


def _swww_img(path: str, cfg: dict):
    tr  = cfg.get("sww_tr_type", "any")
    dur = float(cfg.get("sww_tr_duration", 0.6))
    fps = int(cfg.get("sww_tr_fps", 60))
    # Aplica al fondo (daemon ya corriendo)
    subprocess.call([
        "bash","-lc",
        f'swww img "{path}" --transition-type "{tr}" --transition-fps {fps} --transition-duration {dur}'
    ])

def _hyprpaper_img(path: str):
    out = subprocess.run(["bash","-lc","hyprctl monitors -j"], capture_output=True, text=True)
    mons = []
    if out.returncode == 0 and out.stdout.strip():
        try:
            import json as _json
            mons = [m.get("name") for m in _json.loads(out.stdout)]
        except Exception:
            mons = []
    cfg_path = Path(os.getenv("XDG_CONFIG_HOME", str(Path.home()/".config"))) / "hypr" / "hyprpaper.conf"
    cfg_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [f"preload = {path}"] + [f"wallpaper = {m}, {path}" for m in mons or []]
    cfg_path.write_text("\n".join(lines)+"\n", encoding="utf-8")
    subprocess.call(["bash","-lc","killall hyprpaper >/dev/null 2>&1 || true"])
    subprocess.call(["bash","-lc","hyprpaper & disown"])

def _apply_wallpaper(path: str, cfg: dict):
    if bool(cfg.get("use_swww", True)) and _cmd_exists("swww"):
        _ensure_swww_daemon()
        _swww_img(path, cfg)
    elif _cmd_exists("hyprpaper"):
        _hyprpaper_img(path)
    else:
        _notify("Wallpaper", "Instala swww o hyprpaper")
        sys.exit("No hay backend (swww/hyprpaper).")

# ==== ops ====
def _gather_wallpapers(cfg: dict) -> list[str]:
    base = Path(cfg.get("wallpapers_dir", str(WALL_DIR)))
    exts = set(e.lower() for e in cfg.get("allowed_extensions", DEFAULTS["allowed_extensions"]))
    files = []
    if base.exists():
        for p in sorted(base.rglob("*")):
            if p.is_file() and p.suffix.lower() in exts:
                files.append(str(p))
    return files

def set_wallpaper(path: str):
    cfg = _read_cfg()
    p = Path(path).expanduser().resolve()
    if not p.exists():
        _notify("Wallpaper", "Ruta no existe")
        sys.exit("El archivo no existe.")
    _apply_wallpaper(str(p), cfg)
    cfg["current_wallpaper"] = str(p); _write_cfg(cfg)
    _notify("Wallpaper aplicado", p.name)

def set_current_wallpaper():
    cfg = _read_cfg()
    cur = cfg.get("current_wallpaper", "")
    if not cur:
        _notify("Wallpaper", "No hay wallpaper guardado")
        sys.exit("No hay current_wallpaper en config.")
    _apply_wallpaper(cur, cfg)
    _notify("Wallpaper reaplicado", Path(cur).name)

def set_random_wallpaper():
    cfg = _read_cfg()
    pool = _gather_wallpapers(cfg)
    if not pool:
        _notify("Wallpaper", "Carpeta vacía")
        sys.exit("No se encontraron wallpapers en la carpeta configurada.")
    choice = random.choice(pool)
    _apply_wallpaper(choice, cfg)
    cfg["current_wallpaper"] = choice; _write_cfg(cfg)
    _notify("Wallpaper aleatorio", Path(choice).name)

def select_wallpaper():
    cfg = _read_cfg()
    pool = _gather_wallpapers(cfg)
    if not pool:
        _notify("Wallpaper", "Carpeta vacía")
        sys.exit("No se encontraron wallpapers en la carpeta configurada.")
    pretty = [str(Path(x).name) for x in pool]
    joined = "\n".join(pretty)

    sel = None
    if cfg.get("picker","rofi") == "rofi" and _cmd_exists("rofi"):
        out = subprocess.run(['bash','-lc', f'printf "%s\n" "{joined}" | rofi -dmenu -i -p "Seleccionar wallpaper"'],
                             capture_output=True, text=True)
        sel = out.stdout.strip()
    elif _cmd_exists("wofi"):
        out = subprocess.run(['bash','-lc', f'printf "%s\n" "{joined}" | wofi --dmenu -p "Seleccionar wallpaper"'],
                             capture_output=True, text=True)
        sel = out.stdout.strip()
    else:
        print("Seleccionar wallpaper")
        for i, it in enumerate(pretty): print(f"[{i}] {it}")
        try: sel = pretty[int(input("Índice: "))]
        except Exception: sel = None

    if not sel: return
    chosen = pool[pretty.index(sel)]
    _apply_wallpaper(chosen, cfg)
    cfg["current_wallpaper"] = chosen; _write_cfg(cfg)
    _notify("Wallpaper aplicado", Path(chosen).name)

# ==== CLI ====
def main():
    parser = ArgumentParser(
        description="Minimal wallpaper switcher (meowarch-style, sin temas)",
        formatter_class=RawTextHelpFormatter
    )
    g = parser.add_argument_group("Acciones")
    g.add_argument("--action", required=True, choices=[
        "get", "set-wallpaper", "set-random-wallpaper",
        "select-wallpaper", "set-current-wallpaper"
    ])
    g2 = parser.add_argument_group("Parámetros")
    g2.add_argument("--parameter", help='Para "get": current-wallpaper')
    g2.add_argument("--path", help='Ruta del wallpaper para "set-wallpaper"')

    args = parser.parse_args()

    if args.action == "get":
        if args.parameter == "current-wallpaper":
            print(_read_cfg().get("current_wallpaper",""))
        else:
            print("Parámetro get no soportado. Usa: current-wallpaper", file=sys.stderr); sys.exit(1)
    elif args.action == "set-wallpaper":
        if args.path: set_wallpaper(args.path)
        else:         set_current_wallpaper()
    elif args.action == "set-current-wallpaper":
        set_current_wallpaper()
    elif args.action == "set-random-wallpaper":
        set_random_wallpaper()
    elif args.action == "select-wallpaper":
        select_wallpaper()

if __name__ == "__main__":
    main()
