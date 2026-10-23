import QtQuick
import qs.theme

Row {
    id: root

    property string key: ""
    property string value: ""
    property color valueColor: Theme.text
    property int keyWidth: 0

    spacing: 6

    Text {
        width: root.keyWidth > 0 ? root.keyWidth : implicitWidth
        text: root.key.endsWith(":") ? root.key : `${root.key}:`
        color: Theme.purple
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontMd
        font.bold: true
    }

    Text {
        text: root.value
        color: root.valueColor
        font.family: Theme.fontMono
        font.pixelSize: Theme.fontMd
    }
}
