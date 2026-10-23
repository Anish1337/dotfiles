import QtQuick
import QtQuick.Layouts
import qs.theme

ColumnLayout {
    id: root

    property string title: ""
    property string badge: ""
    property bool expanded: false

    default property alias contentData: body.data

    spacing: 0
    Layout.fillWidth: true

    Item {
        Layout.fillWidth: true
        height: 28

        RowLayout {
            anchors.fill: parent
            spacing: 8

            Text {
                text: root.expanded ? "▾" : "▸"
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontMd
            }
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
                visible: root.badge.length > 0
                text: root.badge
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSm
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    ColumnLayout {
        id: body
        Layout.fillWidth: true
        Layout.topMargin: root.expanded ? 8 : 0
        spacing: 8
        visible: root.expanded
    }
}
