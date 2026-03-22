#!/usr/bin/env bash
set -euo pipefail

if ! command -v bluetoothctl >/dev/null 2>&1; then
  exit 0
fi

powered="$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print $2; exit}')"
if [[ "$powered" == "yes" ]]; then
  bluetoothctl power off >/dev/null 2>&1 || true
else
  bluetoothctl power on >/dev/null 2>&1 || true
fi
