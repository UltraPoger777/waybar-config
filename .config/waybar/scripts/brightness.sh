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
  local state_file percent icon level changed class_json previous tooltip
  state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-brightness.prev"

  percent="$(brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/, "", $NF); print $NF}' || true)"
  if [[ -z "$percent" ]]; then
    echo '{"text":"󰃠 N/A","class":"level-low","tooltip":"brightnessctl is not available"}'
    exit 0
  fi

  if (( percent < 35 )); then
    icon="󰃞"
    level="level-low"
  elif (( percent < 70 )); then
    icon="󰃟"
    level="level-medium"
  else
    icon="󰃠"
    level="level-high"
  fi

  changed="false"
  if [[ -f "$state_file" ]]; then
    previous="$(<"$state_file")"
    [[ "$previous" != "$percent" ]] && changed="true"
  fi
  printf '%s' "$percent" > "$state_file"

  class_json="\"class\":[\"$level\"]"
  if [[ "$changed" == "true" ]]; then
    class_json="\"class\":[\"$level\",\"changed\"]"
  fi

  tooltip="$(escape_json "Brightness: ${percent}%")"
  printf '{"text":"%s %s%%",%s,"tooltip":"%s"}\n' \
    "$icon" "$percent" "$class_json" "$tooltip"
}

main
