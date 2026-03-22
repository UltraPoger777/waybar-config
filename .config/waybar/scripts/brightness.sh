#!/usr/bin/env bash
set -euo pipefail

escape_json() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "$value"
}

build_bar() {
  local percent="${1:-0}" segments=10 filled i bar=""
  (( percent < 0 )) && percent=0
  (( percent > 100 )) && percent=100
  filled=$(( (percent + 5) / 10 ))
  for ((i = 1; i <= segments; i++)); do
    if (( i <= filled )); then
      bar+="█"
    else
      bar+="░"
    fi
  done
  printf '%s' "$bar"
}

main() {
  local state_file percent icon level changed class_json previous tooltip direction bar
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
  direction="steady"
  if [[ -f "$state_file" ]]; then
    previous="$(<"$state_file")"
    if [[ "$previous" != "$percent" ]]; then
      changed="true"
      if [[ "$previous" =~ ^[0-9]+$ ]]; then
        if (( percent > previous )); then
          direction="up"
        elif (( percent < previous )); then
          direction="down"
        fi
      fi
    fi
  fi
  printf '%s' "$percent" > "$state_file"

  class_json="\"class\":[\"$level\"]"
  if [[ "$changed" == "true" ]]; then
    class_json="\"class\":[\"$level\",\"changed\",\"changed-$direction\"]"
  fi

  bar="$(build_bar "$percent")"
  tooltip="$(escape_json "Brightness: ${percent}%")"
  printf '{"text":"%s %s%% %s",%s,"tooltip":"%s"}\n' \
    "$icon" "$percent" "$bar" "$class_json" "$tooltip"
}

main
