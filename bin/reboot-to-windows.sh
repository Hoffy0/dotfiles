#!/usr/bin/env bash
# Reboot straight into Windows: set the UEFI BootNext variable, then reboot.
#
# BootNext is one-shot, so if anything goes wrong after this point the machine
# still comes back to the normal boot order (Fedora) on the boot after next.
#
# Requires system/reboot-to-windows/install.sh to have been run once.
set -euo pipefail

notify() {
  command -v notify-send >/dev/null 2>&1 && notify-send -u critical "Reboot to Windows" "$1"
  echo "$1" >&2
}

if ! sudo -n /usr/local/bin/set-bootnext-windows >/dev/null; then
  notify "Could not set BootNext. Run system/reboot-to-windows/install.sh."
  exit 1
fi

systemctl reboot || loginctl reboot
