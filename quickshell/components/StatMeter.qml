import QtQuick
import QtQuick.Layouts
import qs.theme

ColumnLayout {
    id: root

    property string title: ""
    property real value: 0
    property string suffix: "%"
    property string detail: ""
    property color barColor: Theme.purple

    spacing: 4
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: root.title
            color: Theme.purple
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontMd
            font.bold: true
        }
        Item {
            Layout.fillWidth: true
        }
        Text {
            text: `${Math.round(root.value)}${root.suffix}`
            color: Theme.text
            font.family: Theme.fontMono
            font.pixelSize: Theme.fontMd
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 3
        radius: 1
        color: Theme.surfaceHi

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(0, parent.width * Math.min(1, Math.max(0, root.value / 100)))
            radius: 1
            color: root.barColor
            Behavior on width {
                NumberAnimation {
                    duration: Theme.animMed
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Text {
        visible: root.detail.length > 0
        Layout.fillWidth: true
        text: root.detail
        color: Theme.muted
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontSm
        elide: Text.ElideRight
    }
}
