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
  local state_file output volume muted percent icon level changed class tooltip previous
  state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-volume.prev"

  output="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  if [[ -z "$output" ]]; then
    echo '{"text":"󰕿 N/A","class":"level-low","tooltip":"wpctl недоступен"}'
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
  if [[ -f "$state_file" ]]; then
    previous="$(<"$state_file")"
    [[ "$previous" != "$percent:$muted" ]] && changed="true"
  fi
  printf '%s' "$percent:$muted" > "$state_file"

  class="$level"
  if [[ "$changed" == "true" ]]; then
    class="$class changed"
  fi

  tooltip="Громкость: ${percent}%"
  [[ "$muted" == "true" ]] && tooltip="${tooltip} (mute)"
  tooltip="$(escape_json "$tooltip")"

  printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
    "$icon" "$percent" "$class" "$tooltip"
}

main
