#!/usr/bin/env bash
# Simple weather via wttr.in — outputs waybar JSON
set -euo pipefail

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-weather.json"
URL="https://wttr.in/?format=j1"

fetch() {
  # -k: wttr.in LE cert has been expiring; skip verify so the bar still updates
  curl -sfk --max-time 12 -A "waybar-weather" "$URL"
}

if ! raw="$(fetch)"; then
  if [[ -f "$CACHE" ]]; then
    cat "$CACHE"
  else
    printf '{"text":"󰖐  —","tooltip":"Weather unavailable"}\n'
  fi
  exit 0
fi

out="$(python3 - "$raw" <<'PY'
import json, sys
data = json.loads(sys.argv[1])
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
# rough icon map
icons = {
  113: "󰖙",  # sunny
  116: "󰖕",  # partly cloudy
  119: "󰖐",  # cloudy
  122: "󰖐",
  143: "󰖑",  # mist
  176: "󰖗",  # patchy rain
  179: "󰖘",
  182: "󰖖",
  185: "󰖖",
  200: "󰖓",
  227: "󰼶",
  230: "󰼶",
  248: "󰖑",
  260: "󰖑",
  263: "󰖗",
  266: "󰖗",
  281: "󰖖",
  284: "󰖖",
  293: "󰖗",
  296: "󰖗",
  299: "󰖖",
  302: "󰖖",
  305: "󰖖",
  308: "󰖖",
  311: "󰖖",
  314: "󰖖",
  317: "󰖒",
  320: "󰖒",
  323: "󰖘",
  326: "󰖘",
  329: "󰼶",
  332: "󰼶",
  335: "󰼶",
  338: "󰼶",
  350: "󰖒",
  353: "󰖗",
  356: "󰖖",
  359: "󰖖",
  362: "󰖒",
  365: "󰖒",
  368: "󰖘",
  371: "󰼶",
  374: "󰖒",
  377: "󰖒",
  386: "󰖓",
  389: "󰖓",
  392: "󰖓",
  395: "󰼶",
}
icon = icons.get(code, "󰖐")

text = f"{icon}  {temp}°C"
tooltip = f"{place}, {region}\n{desc}\nFeels like: {feels}°C\nHumidity: {humidity}%\nWind: {wind} km/h"
print(json.dumps({"text": text, "tooltip": tooltip}))
PY
)"

printf '%s\n' "$out" | tee "$CACHE"
