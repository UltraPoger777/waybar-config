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
  local state_file output volume muted percent icon level changed class_json tooltip previous direction bar
  state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-volume.prev"

  output="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  if [[ -z "$output" ]]; then
    echo '{"text":"󰕿 N/A","class":"level-low","tooltip":"wpctl is not available"}'
    exit 0
  fi

  muted="false"
  [[ "$output" == *"[MUTED]"* ]] && muted="true"

  volume="$(printf '%s' "$output" | awk '{print $2}')"
  percent="$(awk -v v="${volume:-0}" 'BEGIN { printf "%d", (v * 100) + 0.5 }')"

  if [[ "$muted" == "true" ]]; then
    icon="󰖁"
    level="muted"
  elif (( percent < 35 )); then
    icon="󰕿"
    level="level-low"
  elif (( percent < 70 )); then
    icon="󰖀"
    level="level-medium"
  else
    icon="󰕾"
    level="level-high"
  fi

  changed="false"
  direction="steady"
  if [[ -f "$state_file" ]]; then
    previous="$(<"$state_file")"
    if [[ "$previous" != "$percent:$muted" ]]; then
      changed="true"
      if [[ "$previous" =~ ^([0-9]+): ]]; then
        if (( percent > ${BASH_REMATCH[1]} )); then
          direction="up"
        elif (( percent < ${BASH_REMATCH[1]} )); then
          direction="down"
        fi
      fi
    fi
  fi
  printf '%s' "$percent:$muted" > "$state_file"

  class_json="\"class\":[\"$level\"]"
  if [[ "$changed" == "true" ]]; then
    class_json="\"class\":[\"$level\",\"changed\",\"changed-$direction\"]"
  fi

  bar="$(build_bar "$percent")"
  tooltip="Volume: ${percent}%"
  [[ "$muted" == "true" ]] && tooltip="${tooltip} (mute)"
  tooltip="$(escape_json "$tooltip")"

  printf '{"text":"%s %s%% %s",%s,"tooltip":"%s"}\n' \
    "$icon" "$percent" "$bar" "$class_json" "$tooltip"
}

main
