#!/usr/bin/env bash
# Usage: screenshot.sh [full|region|window]
set -euo pipefail

mode="${1:-full}"
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

case "$mode" in
  full)
    grim -t png "$file"
    ;;
  region)
    geom="$(slurp)" || exit 1
    grim -g "$geom" -t png "$file"
    ;;
  window)
    geom="$(hyprctl activewindow -j | python3 -c "import json,sys; w=json.load(sys.stdin); print(f\"{w['at'][0]},{w['at'][1]} {w['size'][0]}x{w['size'][1]}\")")"
    grim -g "$geom" -t png "$file"
    ;;
  *)
    echo "usage: $0 [full|region|window]" >&2
    exit 2
    ;;
esac

wl-copy < "$file"
notify-send -a Screenshot "Screenshot saved" "$(basename "$file")" 2>/dev/null || true
