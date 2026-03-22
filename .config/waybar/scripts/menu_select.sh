#!/usr/bin/env bash
set -euo pipefail

menu_pick() {
  local prompt="${1:-Select}"
  shift || true

  if [[ "$#" -eq 0 ]]; then
    return 1
  fi

  if command -v wofi >/dev/null 2>&1; then
    printf '%s\n' "$@" | wofi --dmenu --prompt "$prompt"
    return $?
  fi

  if command -v rofi >/dev/null 2>&1; then
    printf '%s\n' "$@" | rofi -dmenu -p "$prompt"
    return $?
  fi

  if command -v fuzzel >/dev/null 2>&1; then
    printf '%s\n' "$@" | fuzzel --dmenu --prompt "$prompt"
    return $?
  fi

  return 127
}

menu_input() {
  local prompt="${1:-Input}"

  if command -v wofi >/dev/null 2>&1; then
    printf '\n' | wofi --dmenu --prompt "$prompt"
    return $?
  fi

  if command -v rofi >/dev/null 2>&1; then
    printf '\n' | rofi -dmenu -p "$prompt"
    return $?
  fi

  if command -v fuzzel >/dev/null 2>&1; then
    printf '\n' | fuzzel --dmenu --prompt "$prompt"
    return $?
  fi

  return 127
}
