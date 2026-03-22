#!/usr/bin/env bash
set -euo pipefail

main() {
  local weather_json
  weather_json="$(curl -sf --max-time 8 "https://wttr.in/?format=j1&lang=en" || true)"
  if [[ -z "${weather_json}" ]]; then
    echo '{"text":"󰼯 N/A","class":"weather-error","tooltip":"Failed to fetch weather"}'
    exit 0
  fi

  WEATHER_JSON="$weather_json" python3 - <<'PY'
import datetime
import json
import os
import sys


def safe_get(path, default=""):
    cur = data
    try:
        for key in path:
            cur = cur[key]
        return cur
    except Exception:
        return default


try:
    data = json.loads(os.environ["WEATHER_JSON"])
except Exception:
    print('{"text":"󰼯 N/A","class":"weather-error","tooltip":"Failed to parse weather data"}')
    sys.exit(0)

temp = safe_get(["current_condition", 0, "temp_C"], "?")
desc = safe_get(["current_condition", 0, "weatherDesc", 0, "value"], "Unknown")
location = safe_get(["nearest_area", 0, "areaName", 0, "value"], "Unknown")
condition = str(desc).lower()

icon = "󰼯"
klass = "weather-default"
if any(token in condition for token in ("sun", "clear")):
    icon = "󰖙"
    klass = "weather-clear"
elif any(token in condition for token in ("cloud", "overcast")):
    icon = "󰖐"
    klass = "weather-cloudy"
elif any(token in condition for token in ("rain", "drizzle")):
    icon = "󰖗"
    klass = "weather-rain"
elif any(token in condition for token in ("snow", "blizzard", "sleet")):
    icon = "󰖘"
    klass = "weather-snow"
elif any(token in condition for token in ("thunder", "storm")):
    icon = "󰙾"
    klass = "weather-storm"
elif any(token in condition for token in ("fog", "mist", "haze")):
    icon = "󰖑"
    klass = "weather-fog"

forecast_lines = []
for day in safe_get(["weather"], [])[:3]:
    date_s = day.get("date", "")
    min_t = day.get("mintempC", "?")
    max_t = day.get("maxtempC", "?")
    hourly = day.get("hourly", [])
    midday = hourly[len(hourly) // 2] if hourly else {}
    day_desc = (midday.get("weatherDesc") or [{"value": "Unknown"}])[0].get("value", "Unknown")
    try:
        day_name = datetime.datetime.strptime(date_s, "%Y-%m-%d").strftime("%a")
    except Exception:
        day_name = date_s
    forecast_lines.append(f"{day_name}: {min_t}..{max_t}°C, {day_desc}")

tooltip = f"{location}: {temp}°C, {desc}"
if forecast_lines:
    tooltip += "\n\n3-day forecast:\n" + "\n".join(forecast_lines)

out = {
    "text": f"{icon} {temp}°C {desc}",
    "class": klass,
    "tooltip": tooltip,
}
print(json.dumps(out, ensure_ascii=False))
PY
}

main
