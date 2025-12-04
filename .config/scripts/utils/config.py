from __future__ import annotations
import os, yaml, subprocess
from pathlib import Path

CFG_DIR  = Path(os.getenv("XDG_CONFIG_HOME", Path.home() / ".config")) / "meowarch"
CFG_FILE = CFG_DIR / "config.yaml"

DEFAULTS = {
    "current_theme": "default",
    "current_wallpaper": "",
    "wallpapers_dir": str(Path.home() / "Pictures" / "wallpapers"),  # <- tu ruta
    "allowed_extensions": [".png", ".jpg", ".jpeg", ".webp"],
    "picker": "rofi",  # rofi|wofi
    "swww": {"use": True, "transition": "any", "duration": 0.6, "fps": 60}
}

class Config:
    @staticmethod
    def _ensure():
        CFG_DIR.mkdir(parents=True, exist_ok=True)
        if not CFG_FILE.exists():
            with open(CFG_FILE, "w", encoding="utf-8") as f:
                yaml.safe_dump(DEFAULTS, f, sort_keys=False, allow_unicode=True)

    @staticmethod
    def _read() -> dict:
        Config._ensure()
        with open(CFG_FILE, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f) or {}
        merged = DEFAULTS.copy()
        merged.update(data or {})
        return merged

    @staticmethod
    def _write(obj: dict):
        Config._ensure()
        with open(CFG_FILE, "w", encoding="utf-8") as f:
            yaml.safe_dump(obj, f, sort_keys=False, allow_unicode=True)

    @staticmethod
    def get_current_wallpaper() -> str:
        return Config._read().get("current_wallpaper", "")

    @staticmethod
    def set_current_wallpaper(path: str):
        cfg = Config._read(); cfg["current_wallpaper"] = path; Config._write(cfg)

    @staticmethod
    def get_current_theme() -> str:
        return Config._read().get("current_theme", "default")

    @staticmethod
    def set_current_theme(name: str):
        cfg = Config._read(); cfg["current_theme"] = name; Config._write(cfg)

    @staticmethod
    def get_wallpapers_dir() -> Path:
        p = Path(Config._read().get("wallpapers_dir", DEFAULTS["wallpapers_dir"]))
        p.mkdir(parents=True, exist_ok=True)
        return p

    @staticmethod
    def get_allowed_exts() -> list[str]:
        return Config._read().get("allowed_extensions", DEFAULTS["allowed_extensions"])

    @staticmethod
    def get_picker() -> str:
        return Config._read().get("picker", "rofi")

    @staticmethod
    def swww_conf() -> dict:
        return Config._read().get("swww", DEFAULTS["swww"])

    @staticmethod
    def command_exists(cmd: str) -> bool:
        return subprocess.call(["bash", "-lc", f"type -p {cmd} >/dev/null 2>&1"]) == 0

