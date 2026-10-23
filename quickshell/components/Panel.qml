import QtQuick
import qs.theme

Rectangle {
    id: root
    radius: Theme.radius
    color: Theme.panelFill

    default property alias content: host.data

    Item {
        id: host
        anchors.fill: parent
        anchors.leftMargin: Theme.zonePadX
        anchors.rightMargin: Theme.zonePadX
        anchors.topMargin: Theme.zonePadY
        anchors.bottomMargin: Theme.zonePadY
    }
}
