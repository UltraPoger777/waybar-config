#!/usr/bin/env bash
set -euo pipefail

main() {
  local todo_file
  todo_file="${WAYBAR_TODO_FILE:-$HOME/.config/waybar/todo.txt}"
  if [[ ! -f "$todo_file" ]]; then
    todo_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/todo.txt"
  fi

  TODO_FILE="$todo_file" python3 - <<'PY'
import calendar
import datetime as dt
import json
import os
import re

todo_file = os.environ.get("TODO_FILE", "")
tasks = []

if todo_file and os.path.exists(todo_file):
    with open(todo_file, "r", encoding="utf-8") as f:
        for raw in f:
            line = raw.rstrip("\n")
            m = re.match(r"^\s*-\s*\[([ xX])\]\s*(.+)$", line)
            if m:
                done = m.group(1).lower() == "x"
                tasks.append((done, m.group(2).strip()))
            elif line.strip() and not line.lstrip().startswith("#"):
                tasks.append((False, line.strip()))

pending = [t for t in tasks if not t[0]]
done_count = len([t for t in tasks if t[0]])

now = dt.datetime.now()
time_text = now.strftime("%H:%M")
text = f"  {time_text}"
klass = "todo-active" if pending else "todo-done"

cal_lines = calendar.TextCalendar(firstweekday=0).formatmonth(now.year, now.month).splitlines()
todo_lines = ["TODO", "----"]
if not tasks:
    todo_lines.extend(["(empty)", "Click time to manage"])
else:
    for done, title in tasks[:8]:
        marker = "[x]" if done else "[ ]"
        todo_lines.append(f"{marker} {title}")
    if len(tasks) > 8:
        todo_lines.append(f"... +{len(tasks)-8} more")

left_width = max((len(line) for line in cal_lines), default=20) + 4
rows = max(len(cal_lines), len(todo_lines))
merged = []
for i in range(rows):
    cal_part = cal_lines[i] if i < len(cal_lines) else ""
    todo_part = todo_lines[i] if i < len(todo_lines) else ""
    merged.append(cal_part.ljust(left_width) + todo_part)

tooltip = "\n".join(merged)
tooltip += f"\n\nPending: {len(pending)} | Done: {done_count}"
tooltip += "\nLeft click: manage TODO"

print(json.dumps({"text": text, "class": klass, "tooltip": tooltip}, ensure_ascii=False))
PY
}

main
