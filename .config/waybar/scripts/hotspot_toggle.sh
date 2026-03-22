#!/usr/bin/env bash
set -euo pipefail

if ! command -v nmcli >/dev/null 2>&1; then
  exit 0
fi

active_hotspot="$(
  nmcli -t -f NAME,TYPE con show --active 2>/dev/null \
    | awk -F: '$2=="wifi" && tolower($1) ~ /hotspot|ap/ {print $1; exit}'
)"

if [[ -n "$active_hotspot" ]]; then
  nmcli connection down "$active_hotspot" >/dev/null 2>&1 || true
  exit 0
fi

wifi_device="$(
  nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null \
    | awk -F: '$2=="wifi" && $3!="unavailable" {print $1; exit}'
)"

if [[ -z "$wifi_device" ]]; then
  exit 0
fi

ssid="${HOTSPOT_SSID:-WaybarHotspot}"
password="${HOTSPOT_PASSWORD:-12345678}"
nmcli device wifi hotspot ifname "$wifi_device" con-name "Hotspot" ssid "$ssid" password "$password" >/dev/null 2>&1 || true
