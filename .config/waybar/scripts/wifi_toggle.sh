#!/usr/bin/env bash
set -euo pipefail

if ! command -v nmcli >/dev/null 2>&1; then
  exit 0
fi

state="$(nmcli radio wifi 2>/dev/null || true)"
if [[ "$state" == "enabled" ]]; then
  nmcli radio wifi off >/dev/null 2>&1 || true
else
  nmcli radio wifi on >/dev/null 2>&1 || true
fi
