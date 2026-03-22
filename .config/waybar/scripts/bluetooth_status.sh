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
  local powered text class tooltip
  if ! command -v bluetoothctl >/dev/null 2>&1; then
    echo '{"text":"󰂲 BT","class":"qs-off","tooltip":"bluetoothctl is not available"}'
    exit 0
  fi

  powered="$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print $2; exit}')"
  if [[ "$powered" == "yes" ]]; then
    text="󰂯 BT"
    class="qs-on"
    tooltip="Bluetooth: ON"
  else
    text="󰂲 BT"
    class="qs-off"
    tooltip="Bluetooth: OFF"
  fi

  tooltip="${tooltip}\nLeft click: toggle"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$(escape_json "$tooltip")"
}

main
