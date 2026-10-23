pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string status: "STATUS: …"
    property string statusLevel: "ok"
    property string pkgLabel: "PKG: …"
    property var pkgCount: null
    property bool rebootRequired: false
    property string netLabel: "NET: …"
    property string netLevel: "up"
    property string diskLabel: "DISK: …"
    property string diskLevel: "ok"
    property var issues: []

    readonly property bool healthy: statusLevel === "ok"
    readonly property color statusColor: {
        if (statusLevel === "crit")
            return "#fb7185";
        if (statusLevel === "warn")
            return "#c4b5fd";
        return "#a3a3b5";
    }

    function refresh() {
        proc.running = false;
        proc.running = true;
    }

    Process {
        id: proc
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/scripts/sysstatus.py"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim();
                if (!raw.length)
                    return;
                try {
                    const d = JSON.parse(raw);
                    root.status = d.status ?? "STATUS: UNKNOWN";
                    root.statusLevel = d.status_level ?? "ok";
                    root.pkgLabel = d.pkg_label ?? "PKG: UNKNOWN";
                    root.pkgCount = d.pkg_count;
                    root.rebootRequired = !!d.reboot_required;
                    root.netLabel = d.net_label ?? "NET: UNKNOWN";
                    root.netLevel = d.net_level ?? "up";
                    root.diskLabel = d.disk_label ?? "DISK: …";
                    root.diskLevel = d.disk_level ?? "ok";
                    root.issues = d.issues ?? [];
                } catch (e) {}
            }
        }
    }

    // Package checks can be slow; poll gently
    Timer {
        interval: 120000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
