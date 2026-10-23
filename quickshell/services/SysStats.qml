pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpu: 0
    property real mem: 0
    property real disk: 0
    property var gpu: null
    property var gpuTemp: null
    property string net: "…"
    property int uptime: 0
    property real memUsed: 0
    property real memTotal: 0
    property real diskUsed: 0
    property real diskTotal: 0

    readonly property string uptimeText: {
        const s = uptime;
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        if (h > 24) {
            const d = Math.floor(h / 24);
            return `${d}d ${h % 24}h`;
        }
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    function formatBytes(n) {
        if (!n || n <= 0)
            return "0B";
        const units = ["B", "KB", "MB", "GB", "TB"];
        let v = n;
        let i = 0;
        while (v >= 1024 && i < units.length - 1) {
            v /= 1024;
            i++;
        }
        return `${v.toFixed(i === 0 ? 0 : 1)}${units[i]}`;
    }

    function refresh() {
        proc.running = false;
        proc.running = true;
    }

    Process {
        id: proc
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/scripts/sysstats.py"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim();
                if (!raw.length)
                    return;
                try {
                    const d = JSON.parse(raw);
                    root.cpu = d.cpu ?? 0;
                    root.mem = d.mem ?? 0;
                    root.disk = d.disk ?? 0;
                    root.gpu = d.gpu;
                    root.gpuTemp = d.gpu_temp;
                    root.net = d.net ?? "OFFLINE";
                    root.uptime = d.uptime ?? 0;
                    root.memUsed = d.mem_used ?? 0;
                    root.memTotal = d.mem_total ?? 0;
                    root.diskUsed = d.disk_used ?? 0;
                    root.diskTotal = d.disk_total ?? 0;
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
