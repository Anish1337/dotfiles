import QtQuick
import QtQuick.Controls
import qs.theme

Slider {
    id: root

    property color fillColor: Theme.purple

    from: 0
    to: 1
    implicitHeight: 22

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: root.availableWidth
        height: implicitHeight
        radius: 2
        color: Theme.surfaceHi

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: root.fillColor
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 12
        height: 12
        radius: 6
        color: Theme.text
        opacity: root.pressed || root.hovered ? 1 : 0.85
    }
}
