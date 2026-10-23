import QtQuick
import qs.theme

Item {
    id: root

    property string text: ""
    property bool active: false
    property int size: 28

    signal clicked()

    implicitWidth: Math.max(size, label.implicitWidth + 10)
    implicitHeight: size

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color: {
            if (root.active)
                return Qt.rgba(0.545, 0.482, 0.72, 0.28);
            if (ma.containsMouse)
                return Qt.rgba(0.545, 0.482, 0.72, 0.14);
            return "transparent";
        }
        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.active ? Theme.cyan : (ma.containsMouse ? Theme.text : Theme.muted)
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontLg
        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
