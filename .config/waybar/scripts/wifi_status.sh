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
  local state ssid text class tooltip
  if ! command -v nmcli >/dev/null 2>&1; then
    echo '{"text":"󰤮 Wi-Fi","class":"qs-off","tooltip":"nmcli is not available"}'
    exit 0
  fi

  state="$(nmcli radio wifi 2>/dev/null || true)"
  if [[ "$state" == "enabled" ]]; then
    ssid="$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')"
    text="󰤨 Wi-Fi"
    class="qs-on"
    tooltip="Wi-Fi: ON"
    [[ -n "$ssid" ]] && tooltip="${tooltip}\nSSID: ${ssid}"
  else
    text="󰤮 Wi-Fi"
    class="qs-off"
    tooltip="Wi-Fi: OFF"
  fi

  tooltip="${tooltip}\nLeft click: toggle"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$(escape_json "$tooltip")"
}

main
