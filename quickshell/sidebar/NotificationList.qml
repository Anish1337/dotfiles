import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.theme
import qs.services

ColumnLayout {
    id: root
    spacing: 6
    Layout.fillWidth: true

    property var items: []

    function refresh() {
        histProc.running = false;
        histProc.running = true;
    }

    Process {
        id: histProc
        command: ["dunstctl", "history"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    const rows = parsed?.data?.[0] ?? [];
                    const out = [];
                    for (let i = 0; i < Math.min(rows.length, 5); ++i) {
                        const row = rows[i];
                        out.push({
                            summary: row.summary?.data ?? "",
                            body: row.body?.data ?? "",
                            app: row.appname?.data ?? ""
                        });
                    }
                    root.items = out;
                } catch (e) {
                    root.items = [];
                }
            }
        }
    }

    Timer {
        interval: 4000
        running: ShellState.sidebarOpen
        repeat: true
        onTriggered: root.refresh()
    }

    Connections {
        target: ShellState
        function onSidebarOpenChanged() {
            if (ShellState.sidebarOpen)
                root.refresh();
        }
    }

    Text {
        visible: root.items.length === 0
        text: "no notifications"
        color: Theme.muted
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontMd
    }

    Repeater {
        model: root.items
        delegate: ColumnLayout {
            required property var modelData
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: modelData.app ? `${modelData.app}: ${modelData.summary}` : modelData.summary
                color: Theme.text
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontMd
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: (modelData.body || "").length > 0
                text: modelData.body
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSm
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }
}
