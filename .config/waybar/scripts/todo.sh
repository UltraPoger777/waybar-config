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
  local todo_file default_file repo_fallback pending completed shown line task text tooltip class
  pending=0
  completed=0
  shown=0
  tooltip=""

  default_file="$HOME/.config/waybar/todo.txt"
  repo_fallback="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/todo.txt"
  todo_file="${WAYBAR_TODO_FILE:-$default_file}"
  if [[ ! -f "$todo_file" && -f "$repo_fallback" ]]; then
    todo_file="$repo_fallback"
  fi

  if [[ ! -f "$todo_file" ]]; then
    printf '{"text":"󰄱 0","class":"todo-empty","tooltip":"%s"}\n' \
      "$(escape_json "No todo file found.\nLeft click to create/open: $default_file")"
    exit 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[[[:space:]]\][[:space:]]*(.+)$ ]]; then
      task="${BASH_REMATCH[1]}"
      pending=$((pending + 1))
      if (( shown < 8 )); then
        tooltip+="- ${task}"$'\n'
        shown=$((shown + 1))
      fi
    elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[[xX]\][[:space:]]*(.+)$ ]]; then
      completed=$((completed + 1))
    elif [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
      continue
    else
      pending=$((pending + 1))
      if (( shown < 8 )); then
        tooltip+="- ${line}"$'\n'
        shown=$((shown + 1))
      fi
    fi
  done < "$todo_file"

  text="󰄱 ${pending}"
  if (( pending > 0 )); then
    class="todo-active"
    tooltip="Pending: ${pending}\nDone: ${completed}\n\n${tooltip}\nLeft click: open todo file"
  else
    class="todo-done"
    tooltip="All tasks complete (${completed} done)\nLeft click: open todo file"
  fi

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$(escape_json "$tooltip")"
}

main
