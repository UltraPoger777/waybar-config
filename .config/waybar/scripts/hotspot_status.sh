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
  local hotspot_name text class tooltip
  if ! command -v nmcli >/dev/null 2>&1; then
    echo '{"text":"󰖩 Hotspot","class":"qs-off","tooltip":"nmcli is not available"}'
    exit 0
  fi

  hotspot_name="$(
    nmcli -t -f NAME,TYPE con show --active 2>/dev/null \
      | awk -F: '$2=="wifi" && tolower($1) ~ /hotspot|ap/ {print $1; exit}'
  )"

  if [[ -n "$hotspot_name" ]]; then
    text="󰖩 Hotspot"
    class="qs-on"
    tooltip="Hotspot: ON\nConnection: ${hotspot_name}"
  else
    text="󰖪 Hotspot"
    class="qs-off"
    tooltip="Hotspot: OFF"
  fi

  tooltip="${tooltip}\nLeft click: toggle"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$(escape_json "$tooltip")"
}

main
