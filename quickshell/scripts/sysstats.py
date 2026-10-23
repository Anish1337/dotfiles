#!/usr/bin/env python3
"""Emit JSON system vitals for Quickshell (fast poll)."""
from __future__ import annotations

import json
import os
import subprocess
import time
from pathlib import Path

CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "quickshell-sysstats.json"


def read_cpu() -> tuple[int, int]:
    with open("/proc/stat", encoding="utf-8") as f:
        parts = f.readline().split()
    values = list(map(int, parts[1:]))
    total = sum(values)
    idle = values[3] + (values[4] if len(values) > 4 else 0)
    return total, idle


def cpu_percent(prev: dict | None) -> float:
    total, idle = read_cpu()
    if not prev or "cpu_total" not in prev:
        return 0.0
    dt = total - prev["cpu_total"]
    di = idle - prev["cpu_idle"]
    if dt <= 0:
        return 0.0
    return max(0.0, min(100.0, (1.0 - di / dt) * 100.0))


def mem_percent() -> tuple[float, int, int]:
    info: dict[str, int] = {}
    with open("/proc/meminfo", encoding="utf-8") as f:
        for line in f:
            key, val = line.split(":")
            info[key] = int(val.strip().split()[0]) * 1024
    total = info.get("MemTotal", 1)
    available = info.get("MemAvailable", info.get("MemFree", 0))
    used = total - available
    return used / total * 100.0, used, total


def disk_percent(path: str = "/") -> tuple[float, int, int]:
    st = os.statvfs(path)
    total = st.f_frsize * st.f_blocks
    free = st.f_frsize * st.f_bavail
    used = total - free
    pct = used / total * 100.0 if total else 0.0
    return pct, used, total


def gpu_stats() -> tuple[float | None, float | None]:
    try:
        out = subprocess.check_output(
            [
                "nvidia-smi",
                "--query-gpu=utilization.gpu,temperature.gpu",
                "--format=csv,noheader,nounits",
            ],
            text=True,
            timeout=1.5,
        ).strip()
        if not out:
            return None, None
        util, temp = out.split(",")[0:2]
        return float(util.strip()), float(temp.strip())
    except Exception:
        return None, None


def network_brief() -> str:
    try:
        out = subprocess.check_output(["ip", "-br", "link"], text=True, timeout=1)
    except Exception:
        return "DOWN"
    up = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 2:
            continue
        name, state = parts[0], parts[1]
        if name == "lo" or name.startswith(("docker", "veth", "br-", "virbr")):
            continue
        if state == "UP":
            up.append(name)
    if not up:
        return "DOWN"
    for name in up:
        if name.startswith(("en", "eth")):
            return "ETH"
        if name.startswith("wl"):
            return "WIFI"
    return "LINK"


def uptime_seconds() -> int:
    with open("/proc/uptime", encoding="utf-8") as f:
        return int(float(f.read().split()[0]))


def load_prev() -> dict:
    try:
        return json.loads(CACHE.read_text(encoding="utf-8"))
    except Exception:
        return {}


def main() -> None:
    prev = load_prev()
    cpu = cpu_percent(prev)
    if "cpu_total" not in prev:
        time.sleep(0.12)
        total, idle = read_cpu()
        prev = {"cpu_total": total, "cpu_idle": idle}
        cpu = cpu_percent(prev)

    total, idle = read_cpu()
    mem_pct, mem_used, mem_total = mem_percent()
    disk_pct, disk_used, disk_total = disk_percent("/")
    gpu_util, gpu_temp = gpu_stats()

    payload = {
        "cpu": round(cpu, 1),
        "mem": round(mem_pct, 1),
        "mem_used": mem_used,
        "mem_total": mem_total,
        "disk": round(disk_pct, 1),
        "disk_used": disk_used,
        "disk_total": disk_total,
        "gpu": gpu_util,
        "gpu_temp": gpu_temp,
        "net": network_brief(),
        "uptime": uptime_seconds(),
        "cpu_total": total,
        "cpu_idle": idle,
    }
    CACHE.write_text(json.dumps(payload), encoding="utf-8")
    public = {k: v for k, v in payload.items() if k not in ("cpu_total", "cpu_idle")}
    print(json.dumps(public), flush=True)


if __name__ == "__main__":
    main()
