#!/usr/bin/env bash
set -euo pipefail

escape_json() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "$value"
}

main() {
  local wifi_state bt_state hotspot_state tooltip class

  if command -v nmcli >/dev/null 2>&1; then
    if [[ "$(nmcli radio wifi 2>/dev/null || true)" == "enabled" ]]; then
      wifi_state="ON"
    else
      wifi_state="OFF"
    fi
  else
    wifi_state="N/A"
  fi

  if command -v bluetoothctl >/dev/null 2>&1; then
    if [[ "$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print $2; exit}')" == "yes" ]]; then
      bt_state="ON"
    else
      bt_state="OFF"
    fi
  else
    bt_state="N/A"
  fi

  if command -v nmcli >/dev/null 2>&1; then
    if nmcli -t -f NAME,TYPE con show --active 2>/dev/null | awk -F: '$2=="wifi" && tolower($1) ~ /hotspot|ap/ {found=1} END{exit !found}'; then
      hotspot_state="ON"
    else
      hotspot_state="OFF"
    fi
  else
    hotspot_state="N/A"
  fi

  class="qs-off"
  [[ "$wifi_state" == "ON" || "$bt_state" == "ON" || "$hotspot_state" == "ON" ]] && class="qs-on"

  tooltip="Quick settings\nWi-Fi: ${wifi_state}\nBluetooth: ${bt_state}\nHotspot: ${hotspot_state}\n\nLeft click: open menu"
  printf '{"text":"󰒓","class":"%s","tooltip":"%s"}\n' \
    "$class" "$(escape_json "$tooltip")"
}

main
