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
  local weather_text condition icon class tooltip

  weather_text="$(curl -sf --max-time 6 "https://wttr.in/?format=%t+%C" || true)"
  tooltip="$(curl -sf --max-time 6 "https://wttr.in/?format=%l:+%c+%t+%h+%w" || true)"

  if [[ -z "${weather_text}" ]]; then
    echo '{"text":"󰼯 N/A","class":"weather-error","tooltip":"Не удалось получить погоду"}'
    exit 0
  fi

  condition="$(printf '%s' "$weather_text" | awk -F' ' '{for (i=2;i<=NF;i++) printf("%s%s", $i, (i==NF ? "" : " "))}')"
  condition="${condition,,}"

  icon="󰼯"
  class="weather-default"

  case "$condition" in
    *sun*|*clear*)
      icon="󰖙"
      class="weather-clear"
      ;;
    *cloud*|*overcast*)
      icon="󰖐"
      class="weather-cloudy"
      ;;
    *rain*|*drizzle*)
      icon="󰖗"
      class="weather-rain"
      ;;
    *snow*|*blizzard*|*sleet*)
      icon="󰖘"
      class="weather-snow"
      ;;
    *thunder*|*storm*)
      icon="󰙾"
      class="weather-storm"
      ;;
    *fog*|*mist*|*haze*)
      icon="󰖑"
      class="weather-fog"
      ;;
  esac

  weather_text="$(escape_json "$weather_text")"
  tooltip="$(escape_json "${tooltip:-$weather_text}")"

  printf '{"text":"%s %s","class":"%s","tooltip":"%s"}\n' \
    "$icon" "$weather_text" "$class" "$tooltip"
}

main
