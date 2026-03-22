#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/menu_select.sh"

todo_file="${WAYBAR_TODO_FILE:-$HOME/.config/waybar/todo.txt}"
mkdir -p "$(dirname "$todo_file")"
touch "$todo_file"

pick_task_line() {
  local mode="${1:-toggle}" prompt choice
  local -a labels line_numbers
  labels=()
  line_numbers=()

  while IFS='|' read -r line_no mark title; do
    [[ -z "$line_no" ]] && continue
    if [[ "$mark" == "x" ]]; then
      labels+=("☑ $title")
    else
      labels+=("☐ $title")
    fi
    line_numbers+=("$line_no")
  done < <(
    awk '
      match($0, /^[[:space:]]*-[[:space:]]*\[([ xX])\][[:space:]]*(.+)$/, m) {
        mark=tolower(m[1]);
        print NR "|" mark "|" m[2];
      }
      /^[[:space:]]*#/ {next}
      /^[[:space:]]*$/ {next}
      !match($0, /^[[:space:]]*-[[:space:]]*\[[ xX]\]/) {
        print NR "| |" $0;
      }
    ' "$todo_file"
  )

  if [[ "${#labels[@]}" -eq 0 ]]; then
    return 1
  fi

  prompt="TODO ${mode}"
  choice="$(menu_pick "$prompt" "${labels[@]}" "Back" || true)"
  [[ -z "$choice" || "$choice" == "Back" ]] && return 1

  local i
  for i in "${!labels[@]}"; do
    if [[ "${labels[$i]}" == "$choice" ]]; then
      printf '%s' "${line_numbers[$i]}"
      return 0
    fi
  done
  return 1
}

toggle_task() {
  local line_no="$1"
  python3 - "$todo_file" "$line_no" <<'PY'
import re
import sys

path = sys.argv[1]
line_no = int(sys.argv[2])
with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

idx = line_no - 1
if idx < 0 or idx >= len(lines):
    sys.exit(0)

line = lines[idx].rstrip("\n")
m = re.match(r"^(\s*-\s*\[)([ xX])(\]\s*.*)$", line)
if m:
    new_mark = "x" if m.group(2).strip().lower() != "x" else " "
    lines[idx] = f"{m.group(1)}{new_mark}{m.group(3)}\n"
else:
    lines[idx] = f"- [x] {line.strip()}\n"

with open(path, "w", encoding="utf-8") as f:
    f.writelines(lines)
PY
}

remove_task() {
  local line_no="$1"
  python3 - "$todo_file" "$line_no" <<'PY'
import sys

path = sys.argv[1]
line_no = int(sys.argv[2])
with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

idx = line_no - 1
if idx < 0 or idx >= len(lines):
    sys.exit(0)

del lines[idx]
with open(path, "w", encoding="utf-8") as f:
    f.writelines(lines)
PY
}

add_task() {
  local text
  text="$(menu_input "New TODO" || true)"
  [[ -z "${text// }" ]] && return 0
  printf -- "- [ ] %s\n" "$text" >> "$todo_file"
}

while true; do
  choice="$(menu_pick "TODO" \
    "Add task" \
    "Toggle task done/undone" \
    "Remove task" \
    "Open todo file" \
    "Close" || true)"

  case "$choice" in
    "Add task")
      add_task
      ;;
    "Toggle task done/undone")
      if line_no="$(pick_task_line "toggle")"; then
        toggle_task "$line_no"
      fi
      ;;
    "Remove task")
      if line_no="$(pick_task_line "remove")"; then
        remove_task "$line_no"
      fi
      ;;
    "Open todo file")
      xdg-open "$todo_file" >/dev/null 2>&1 || true
      ;;
    *)
      exit 0
      ;;
  esac
done
