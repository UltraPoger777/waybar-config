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
  local player status title artist text tooltip class output

  if ! command -v playerctl >/dev/null 2>&1; then
    echo '{"text":"  Playerctl missing","class":"media-idle","tooltip":"Install playerctl to control media"}'
    exit 0
  fi

  player="$(playerctl -l 2>/dev/null | head -n 1 || true)"
  if [[ -z "$player" ]]; then
    echo '{"text":"  No media","class":"media-idle","tooltip":"Start Spotify or any MPRIS app"}'
    exit 0
  fi

  status="$(playerctl -p "$player" status 2>/dev/null || true)"
  title="$(playerctl -p "$player" metadata title 2>/dev/null || true)"
  artist="$(playerctl -p "$player" metadata artist 2>/dev/null || true)"

  if [[ -z "$title" && -z "$artist" ]]; then
    output="$player"
  elif [[ -n "$artist" && -n "$title" ]]; then
    output="$artist - $title"
  else
    output="${artist:-$title}"
  fi

  if [[ "${#output}" -gt 42 ]]; then
    output="${output:0:39}..."
  fi

  case "$status" in
    Playing)
      text="  $output"
      class="media-playing"
      ;;
    Paused)
      text="  $output"
      class="media-paused"
      ;;
    *)
      text="  $output"
      class="media-idle"
      ;;
  esac

  tooltip="$(escape_json "Player: $player\nStatus: $status\n\nLeft click: Play/Pause\nRight click: Next track")"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$(escape_json "$text")" "$class" "$tooltip"
}

main
