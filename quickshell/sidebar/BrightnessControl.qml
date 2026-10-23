import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.theme
import qs.components

ColumnLayout {
    id: root
    spacing: 4
    Layout.fillWidth: true

    property int percent: 0
    property bool available: true

    function refresh() {
        brightProc.running = false;
        brightProc.running = true;
    }

    function setBrightness(pct) {
        const clamped = Math.max(1, Math.min(100, Math.round(pct)));
        Quickshell.execDetached(["brightnessctl", "set", `${clamped}%`]);
        root.percent = clamped;
    }

    Process {
        id: brightProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length >= 4) {
                    root.available = true;
                    root.percent = parseInt(parts[3], 10) || 0;
                } else {
                    root.available = false;
                }
            }
        }
        onExited: code => {
            if (code !== 0)
                root.available = false;
        }
    }

    visible: root.available

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: "BRIGHT"
            color: Theme.purple
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontMd
            font.bold: true
        }
        Item {
            Layout.fillWidth: true
        }
        Text {
            text: `${root.percent}%`
            color: Theme.text
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontMd
        }
    }

    SliderBar {
        Layout.fillWidth: true
        from: 1
        to: 100
        value: root.percent
        fillColor: Theme.cyan
        onMoved: root.setBrightness(value)
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
