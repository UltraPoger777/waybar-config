#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/menu_select.sh"

notify() {
  local msg="${1:-Done}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Waybar" "$msg"
  fi
}

toggle_wifi() {
  if ! command -v nmcli >/dev/null 2>&1; then
    notify "nmcli is not installed"
    return 0
  fi
  local state
  state="$(nmcli radio wifi 2>/dev/null || true)"
  if [[ "$state" == "enabled" ]]; then
    nmcli radio wifi off >/dev/null 2>&1 || true
    notify "Wi-Fi disabled"
  else
    nmcli radio wifi on >/dev/null 2>&1 || true
    notify "Wi-Fi enabled"
  fi
}

connect_wifi() {
  if ! command -v nmcli >/dev/null 2>&1; then
    notify "nmcli is not installed"
    return 0
  fi

  local choice selected_ssid selected_security password
  local -a items ssids securities
  items=()
  ssids=()
  securities=()

  while IFS='|' read -r ssid security signal; do
    [[ -z "$ssid" ]] && continue
    items+=("${ssid} (${signal}%)")
    ssids+=("$ssid")
    securities+=("${security:---}")
  done < <(
    nmcli -t -f SSID,SECURITY,SIGNAL dev wifi list --rescan yes 2>/dev/null \
      | awk -F: '{
          if ($1 != "") {
            sec = ($2 == "" ? "--" : $2);
            sig = ($3 == "" ? "?" : $3);
            print $1 "|" sec "|" sig;
          }
        }'
  )

  if [[ "${#items[@]}" -eq 0 ]]; then
    notify "No Wi-Fi networks found"
    return 0
  fi

  choice="$(menu_pick "Wi-Fi networks" "${items[@]}" "Back" || true)"
  [[ -z "$choice" || "$choice" == "Back" ]] && return 0

  local i
  for i in "${!items[@]}"; do
    if [[ "${items[$i]}" == "$choice" ]]; then
      selected_ssid="${ssids[$i]}"
      selected_security="${securities[$i]}"
      break
    fi
  done

  [[ -z "${selected_ssid:-}" ]] && return 0

  if [[ "$selected_security" == "--" ]]; then
    nmcli dev wifi connect "$selected_ssid" >/dev/null 2>&1 || true
  else
    password="$(menu_input "Password: $selected_ssid" || true)"
    [[ -z "$password" ]] && return 0
    nmcli dev wifi connect "$selected_ssid" password "$password" >/dev/null 2>&1 || true
  fi
  notify "Wi-Fi connect requested: $selected_ssid"
}

toggle_bluetooth() {
  if ! command -v bluetoothctl >/dev/null 2>&1; then
    notify "bluetoothctl is not installed"
    return 0
  fi
  local powered
  powered="$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print $2; exit}')"
  if [[ "$powered" == "yes" ]]; then
    bluetoothctl power off >/dev/null 2>&1 || true
    notify "Bluetooth disabled"
  else
    bluetoothctl power on >/dev/null 2>&1 || true
    notify "Bluetooth enabled"
  fi
}

connect_bluetooth() {
  if ! command -v bluetoothctl >/dev/null 2>&1; then
    notify "bluetoothctl is not installed"
    return 0
  fi

  local choice mac name
  local -a items macs
  items=()
  macs=()
  while read -r _ mac name; do
    [[ -z "$mac" || -z "$name" ]] && continue
    items+=("$name ($mac)")
    macs+=("$mac")
  done < <(bluetoothctl devices 2>/dev/null || true)

  if [[ "${#items[@]}" -eq 0 ]]; then
    notify "No Bluetooth devices found"
    return 0
  fi

  choice="$(menu_pick "Bluetooth devices" "${items[@]}" "Back" || true)"
  [[ -z "$choice" || "$choice" == "Back" ]] && return 0

  local i
  for i in "${!items[@]}"; do
    if [[ "${items[$i]}" == "$choice" ]]; then
      bluetoothctl connect "${macs[$i]}" >/dev/null 2>&1 || true
      notify "Bluetooth connect requested"
      return 0
    fi
  done
}

toggle_hotspot() {
  "$SCRIPT_DIR/hotspot_toggle.sh" || true
  notify "Hotspot toggled"
}

while true; do
  choice="$(menu_pick "Quick settings" \
    "Wi-Fi: Toggle" \
    "Wi-Fi: Connect..." \
    "Bluetooth: Toggle" \
    "Bluetooth: Connect..." \
    "Hotspot: Toggle" \
    "Open NetworkManager (nmtui)" \
    "Close" || true)"

  case "$choice" in
    "Wi-Fi: Toggle")
      toggle_wifi
      ;;
    "Wi-Fi: Connect...")
      connect_wifi
      ;;
    "Bluetooth: Toggle")
      toggle_bluetooth
      ;;
    "Bluetooth: Connect...")
      connect_bluetooth
      ;;
    "Hotspot: Toggle")
      toggle_hotspot
      ;;
    "Open NetworkManager (nmtui)")
      command -v nmtui >/dev/null 2>&1 && nmtui || true
      ;;
    *)
      exit 0
      ;;
  esac
done
