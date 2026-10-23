#!/usr/bin/env python3
"""High-level system status for Quickshell — real checks only, no decorative claims."""
from __future__ import annotations

import json
import os
import platform
import socket
import subprocess
from pathlib import Path

DISK_WARN_PCT = 90.0
DISK_CRIT_PCT = 95.0
MEM_WARN_PCT = 90.0
CPU_WARN_PCT = 95.0  # unused alone; used with cached stats if present
STATS_CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "quickshell-sysstats.json"


def run(cmd: list[str], timeout: float = 8.0) -> tuple[int, str]:
    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL, timeout=timeout)
        return 0, out
    except subprocess.CalledProcessError as e:
        return e.returncode, (e.output or "")
    except Exception:
        return 1, ""


def package_updates() -> int | None:
    """Return pending update count, or None if check unavailable."""
    # Prefer checkupdates (pacman-contrib) — safe, doesn't require root
    code, out = run(["checkupdates"], timeout=60.0)
    if code == 0 or out.strip():
        lines = [ln for ln in out.splitlines() if ln.strip()]
        return len(lines)
    # Fallback: pacman -Qu (uses local sync db; may be stale)
    code, out = run(["pacman", "-Qu"], timeout=20.0)
    if code in (0, 1):  # 1 = no upgrades
        lines = [ln for ln in out.splitlines() if ln.strip()]
        return len(lines)
    return None


def reboot_required() -> bool:
    """Arch-oriented: running kernel != installed linux package kernel."""
    running = platform.release()  # e.g. 7.2.11-arch1-1
    # If modules dir for running kernel missing, reboot is likely needed
    if not Path(f"/usr/lib/modules/{running}").is_dir():
        return True

    code, out = run(["pacman", "-Q", "linux"], timeout=5.0)
    if code != 0 or not out.strip():
        return False
    # "linux 7.2.11.arch1-1" -> normalize to uname-style
    pkg_ver = out.split()[1]
    normalized = pkg_ver.replace(".arch", "-arch").replace(".", "-", 2)
    # pacman: 7.2.11.arch1-1  uname: 7.2.11-arch1-1
    pkg_uname = pkg_ver
    if ".arch" in pkg_ver:
        head, rest = pkg_ver.split(".arch", 1)
        pkg_uname = f"{head}-arch{rest}"
    return running != pkg_uname and not running.startswith(head if ".arch" in pkg_ver else pkg_ver)


def network_state() -> dict:
    """Interface + basic reachability."""
    code, out = run(["ip", "-br", "link"], timeout=2.0)
    ifaces: list[tuple[str, str]] = []
    if code == 0:
        for line in out.splitlines():
            parts = line.split()
            if len(parts) < 2:
                continue
            name, state = parts[0], parts[1]
            if name == "lo" or name.startswith(("docker", "veth", "br-", "virbr", "tun", "wg")):
                continue
            ifaces.append((name, state))

    up = [(n, s) for n, s in ifaces if s == "UP"]
    kind = "NONE"
    iface = ""
    if up:
        for n, _ in up:
            if n.startswith(("en", "eth")):
                kind, iface = "ETH", n
                break
            if n.startswith("wl"):
                kind, iface = "WIFI", n
                break
        if kind == "NONE":
            kind, iface = "LINK", up[0][0]

    # Carrier-up but no default route => degraded
    has_route = False
    code, route = run(["ip", "route", "show", "default"], timeout=2.0)
    if code == 0 and route.strip():
        has_route = True

    # Light connectivity probe (non-blocking DNS to system resolver via UDP connect)
    online = False
    if has_route:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(1.0)
            sock.connect(("1.1.1.1", 53))
            sock.close()
            online = True
        except Exception:
            online = False

    if not up:
        label = "NET: DOWN"
        level = "down"
    elif not has_route:
        label = f"NET: {kind} DEGRADED"
        level = "degraded"
    elif not online:
        label = f"NET: {kind} DEGRADED"
        level = "degraded"
    else:
        label = f"NET: {kind} UP"
        level = "up"

    return {
        "net_label": label,
        "net_level": level,
        "net_kind": kind,
        "net_iface": iface,
    }


def disk_state(path: str = "/") -> dict:
    st = os.statvfs(path)
    total = st.f_frsize * st.f_blocks
    free = st.f_frsize * st.f_bavail
    used = total - free
    pct = (used / total * 100.0) if total else 0.0

    def fmt(n: int) -> str:
        gb = n / (1024**3)
        if gb >= 100:
            return f"{gb:.0f}G"
        return f"{gb:.0f}G" if gb >= 10 else f"{gb:.1f}G"

    level = "ok"
    if pct >= DISK_CRIT_PCT:
        level = "crit"
    elif pct >= DISK_WARN_PCT:
        level = "warn"

    return {
        "disk_pct": round(pct, 1),
        "disk_used": used,
        "disk_total": total,
        "disk_label": f"DISK: {fmt(used)} / {fmt(total)}",
        "disk_level": level,
    }


def service_enabled_but_down(unit: str) -> bool:
    """Only flag units that are enabled yet not active."""
    _, en = run(["systemctl", "is-enabled", unit], timeout=2.0)
    if en.strip() not in ("enabled", "enabled-runtime"):
        return False
    _, active = run(["systemctl", "is-active", unit], timeout=2.0)
    return active.strip() != "active"


def load_cached_vitals() -> dict:
    try:
        return json.loads(STATS_CACHE.read_text(encoding="utf-8"))
    except Exception:
        return {}


def overall_status(pkg_count: int | None, reboot: bool, net: dict, disk: dict, vitals: dict) -> dict:
    issues: list[str] = []

    if reboot:
        issues.append("reboot")
    if pkg_count is not None and pkg_count > 0:
        issues.append("updates")
    if net["net_level"] == "down":
        issues.append("network-down")
    elif net["net_level"] == "degraded":
        issues.append("network-degraded")
    if disk["disk_level"] in ("warn", "crit"):
        issues.append("disk")

    mem = float(vitals.get("mem", 0) or 0)
    if mem >= MEM_WARN_PCT:
        issues.append("memory")

    for unit in ("NetworkManager.service", "systemd-networkd.service", "systemd-resolved.service"):
        if service_enabled_but_down(unit):
            issues.append(f"service:{unit}")

    if reboot:
        status = "STATUS: REBOOT REQUIRED"
        level = "crit"
    elif net["net_level"] == "down":
        status = "STATUS: NETWORK DOWN"
        level = "crit"
    elif disk["disk_level"] == "crit":
        status = "STATUS: DISK CRITICAL"
        level = "crit"
    elif pkg_count is not None and pkg_count > 0:
        status = "STATUS: UPDATES AVAILABLE"
        level = "warn"
    elif net["net_level"] == "degraded" or disk["disk_level"] == "warn" or mem >= MEM_WARN_PCT:
        status = "STATUS: DEGRADED"
        level = "warn"
    else:
        status = "STATUS: HEALTHY"
        level = "ok"

    if pkg_count is None:
        pkg_label = "PKG: UNKNOWN"
    elif pkg_count == 0:
        pkg_label = "PKG: CURRENT"
    else:
        pkg_label = f"PKG: {pkg_count} UPDATES"

    return {
        "status": status,
        "status_level": level,
        "pkg_count": pkg_count,
        "pkg_label": pkg_label,
        "reboot_required": reboot,
        "issues": issues,
    }


def main() -> None:
    pkg = package_updates()
    reboot = reboot_required()
    net = network_state()
    disk = disk_state("/")
    vitals = load_cached_vitals()
    overall = overall_status(pkg, reboot, net, disk, vitals)

    payload = {
        **overall,
        **net,
        **disk,
    }
    print(json.dumps(payload), flush=True)


if __name__ == "__main__":
    main()
