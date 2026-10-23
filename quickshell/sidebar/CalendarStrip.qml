import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme

ColumnLayout {
    spacing: 6
    Layout.fillWidth: true

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(clock.date, "MMMM yyyy").toLowerCase()
        color: Theme.text
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontMd
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        rowSpacing: 2
        columnSpacing: 2

        Repeater {
            model: ["s", "m", "t", "w", "t", "f", "s"]
            Text {
                required property string modelData
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                color: Theme.purple
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSm
            }
        }

        Repeater {
            model: {
                const d = clock.date;
                const year = d.getFullYear();
                const month = d.getMonth();
                const first = new Date(year, month, 1);
                const startPad = first.getDay();
                const daysInMonth = new Date(year, month + 1, 0).getDate();
                const cells = [];
                for (let i = 0; i < startPad; ++i)
                    cells.push({
                        day: 0,
                        current: false
                    });
                const today = d.getDate();
                for (let day = 1; day <= daysInMonth; ++day)
                    cells.push({
                        day: day,
                        current: day === today
                    });
                return cells;
            }

            Item {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                visible: modelData.day > 0

                Text {
                    anchors.centerIn: parent
                    text: modelData.day > 0 ? modelData.day : ""
                    color: modelData.current ? Theme.cyan : Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontMd
                    font.bold: modelData.current
                }

                Rectangle {
                    visible: modelData.current
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: 10
                    height: 2
                    color: Theme.cyan
                }
            }
        }
    }
}
