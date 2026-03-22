#!/usr/bin/env bash
set -euo pipefail

json_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r/\\r/g' -e ':a;N;$!ba;s/\n/\\n/g'
}

emit() {
  local text class tooltip
  text="$1"
  class="$2"
  tooltip="$3"

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$class")" \
    "$(json_escape "$tooltip")"
}

if ! command -v nvidia-smi >/dev/null 2>&1; then
  emit "󰤮 NVIDIA N/A" "missing" "nvidia-smi not found"
  exit 0
fi

query="$(nvidia-smi \
  --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw,power.limit \
  --format=csv,noheader,nounits 2>/dev/null | head -n 1 || true)"

if [[ -z "${query}" ]]; then
  emit "󰤮 NVIDIA off" "off" "dGPU is unavailable (likely powered down)"
  exit 0
fi

IFS=',' read -r name util temp mem_used mem_total power_draw power_limit <<<"${query}"

trim() {
  local value="${1:-}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

name="$(trim "${name}")"
util="$(trim "${util}")"
temp="$(trim "${temp}")"
mem_used="$(trim "${mem_used}")"
mem_total="$(trim "${mem_total}")"
power_draw="$(trim "${power_draw}")"
power_limit="$(trim "${power_limit}")"

if [[ "${util}" == "[N/A]" || -z "${util}" ]]; then util=0; fi
if [[ "${temp}" == "[N/A]" || -z "${temp}" ]]; then temp=0; fi
if [[ "${mem_used}" == "[N/A]" || -z "${mem_used}" ]]; then mem_used=0; fi
if [[ "${mem_total}" == "[N/A]" || -z "${mem_total}" || "${mem_total}" == "0" ]]; then mem_total=1; fi
if [[ "${power_draw}" == "[N/A]" || -z "${power_draw}" ]]; then power_draw=0; fi
if [[ "${power_limit}" == "[N/A]" || -z "${power_limit}" || "${power_limit}" == "0" ]]; then power_limit=1; fi

mem_pct=$((mem_used * 100 / mem_total))
class="normal"

if (( temp >= 80 )); then
  class="critical"
elif (( temp >= 72 )); then
  class="warning"
elif (( util <= 5 )); then
  class="idle"
fi

text="󰢮 ${util}% ${temp}°C"
tooltip="${name}\nGPU: ${util}%\nTemp: ${temp}°C\nVRAM: ${mem_used}/${mem_total} MiB (${mem_pct}%)\nPower: ${power_draw}/${power_limit} W"

emit "${text}" "${class}" "${tooltip}"
