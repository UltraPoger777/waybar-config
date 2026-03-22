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
  local todo_file pending shown line task inline_text tooltip
  local -a tasks
  pending=0
  shown=0
  tasks=()

  todo_file="${WAYBAR_TODO_FILE:-$HOME/.config/waybar/todo.txt}"
  if [[ ! -f "$todo_file" ]]; then
    todo_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/todo.txt"
  fi

  if [[ ! -f "$todo_file" ]]; then
    echo '{"text":"󰄱 no tasks","class":"todo-empty","tooltip":"No todo file found"}'
    exit 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[[[:space:]]\][[:space:]]*(.+)$ ]]; then
      task="${BASH_REMATCH[1]}"
      pending=$((pending + 1))
      if (( shown < 3 )); then
        tasks+=("$task")
        shown=$((shown + 1))
      fi
    fi
  done < "$todo_file"

  if (( pending == 0 )); then
    inline_text="󰄱 done"
    tooltip="Todo: all tasks complete"
    printf '{"text":"%s","class":"todo-done","tooltip":"%s"}\n' \
      "$inline_text" "$(escape_json "$tooltip")"
    exit 0
  fi

  inline_text="󰄱 ${tasks[0]}"
  if (( ${#inline_text} > 34 )); then
    inline_text="${inline_text:0:31}..."
  fi
  if (( pending > 1 )); then
    inline_text="${inline_text} +$((pending - 1))"
  fi

  tooltip="Pending: ${pending}\n\n"
  for task in "${tasks[@]}"; do
    tooltip+="- ${task}\n"
  done
  tooltip+="\nLeft click: open todo file"

  printf '{"text":"%s","class":"todo-active","tooltip":"%s"}\n' \
    "$(escape_json "$inline_text")" "$(escape_json "$tooltip")"
}

main
