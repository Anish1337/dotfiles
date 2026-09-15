#!/usr/bin/env bash
# Simple weather via wttr.in — outputs waybar JSON
set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE="$CACHE_DIR/waybar-weather.json"
URL="https://wttr.in/?format=j1"
mkdir -p "$CACHE_DIR"

raw="$(curl -sf --max-time 8 "$URL" || true)"

if [[ -z "$raw" ]]; then
  if [[ -f "$CACHE" ]]; then
    cat "$CACHE"
  else
    printf '{"text":"󰖐  —","tooltip":"Weather unavailable"}\n'
  fi
  exit 0
fi

printf '%s' "$raw" | python3 -c '
import json, sys
data = json.load(sys.stdin)
cur = data["current_condition"][0]
area = data["nearest_area"][0]
temp = cur["temp_C"]
feels = cur["FeelsLikeC"]
desc = cur["weatherDesc"][0]["value"]
humidity = cur["humidity"]
wind = cur["windspeedKmph"]
place = area["areaName"][0]["value"]
region = area["region"][0]["value"]

code = int(cur["weatherCode"])
icons = {
  113: "󰖙", 116: "󰖕", 119: "󰖐", 122: "󰖐", 143: "󰖑",
  176: "󰖗", 179: "󰖘", 182: "󰖖", 185: "󰖖", 200: "󰖓",
  227: "󰼶", 230: "󰼶", 248: "󰖑", 260: "󰖑", 263: "󰖗",
  266: "󰖗", 281: "󰖖", 284: "󰖖", 293: "󰖗", 296: "󰖗",
  299: "󰖖", 302: "󰖖", 305: "󰖖", 308: "󰖖", 311: "󰖖",
  314: "󰖖", 317: "󰖒", 320: "󰖒", 323: "󰖘", 326: "󰖘",
  329: "󰼶", 332: "󰼶", 335: "󰼶", 338: "󰼶", 350: "󰖒",
  353: "󰖗", 356: "󰖖", 359: "󰖖", 362: "󰖒", 365: "󰖒",
  368: "󰖘", 371: "󰼶", 374: "󰖒", 377: "󰖒", 386: "󰖓",
  389: "󰖓", 392: "󰖓", 395: "󰼶",
}
icon = icons.get(code, "󰖐")
out = {
  "text": f"{icon}  {temp}°C",
  "tooltip": f"{place}, {region}\n{desc}\nFeels like: {feels}°C\nHumidity: {humidity}%\nWind: {wind} km/h",
}
print(json.dumps(out))
' | tee "$CACHE"
