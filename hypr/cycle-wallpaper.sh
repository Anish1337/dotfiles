#!/usr/bin/env bash
# Cycle wallpapers in ~/github/dots/wallpapers on all monitors.
set -euo pipefail

WALL_DIR="${HOME}/github/dots/wallpapers"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hypr-wallpaper-index"
CONF="${HOME}/.config/hypr/hyprpaper.conf"

mapfile -t walls < <(
  find "$WALL_DIR" -maxdepth 1 -type f \( \
    -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
  \) | sort
)

if [[ ${#walls[@]} -eq 0 ]]; then
  notify-send -a Wallpaper "No wallpapers found" "$WALL_DIR" 2>/dev/null || true
  exit 1
fi

idx=0
if [[ -f "$STATE_FILE" ]]; then
  idx="$(<"$STATE_FILE")"
fi
# Advance; wrap around. Invalid/empty state starts at 0.
if ! [[ "$idx" =~ ^[0-9]+$ ]]; then
  idx=0
else
  idx=$(( (idx + 1) % ${#walls[@]} ))
fi
echo "$idx" >"$STATE_FILE"

wall="${walls[$idx]}"
name="$(basename "$wall")"

mapfile -t monitors < <(
  hyprctl monitors -j | python3 -c "import json,sys; [print(m['name']) for m in json.load(sys.stdin)]"
)

{
  echo "splash = false"
  echo
  for mon in "${monitors[@]}"; do
    hyprctl hyprpaper wallpaper "${mon},${wall},cover" >/dev/null
    cat <<EOF
wallpaper {
    monitor = ${mon}
    path = ${wall}
    fit_mode = cover
}

EOF
  done
} >"$CONF"

notify-send -a Wallpaper "Wallpaper" "$name" 2>/dev/null || true
