import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.theme
import qs.components
import qs.services

PanelWindow {
    id: panel

    required property var modelData
    screen: modelData

    readonly property bool onFocused: !Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === screen.name
    readonly property bool shown: ShellState.powerMenuOpen && onFocused

    color: panel.shown ? Theme.overlay : "transparent"
    visible: shown || colorAnim.running
    focusable: shown
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Behavior on color {
        ColorAnimation {
            id: colorAnim
            duration: Theme.animMed
        }
    }

    HyprlandFocusGrab {
        active: panel.shown
        windows: [panel]
        onCleared: ShellState.powerMenuOpen = false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.powerMenuOpen = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: 280
        height: col.implicitHeight + 32
        radius: Theme.radius
        color: Theme.panelFill
        opacity: panel.shown ? 1 : 0
        scale: panel.shown ? 1 : 0.97

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animMed
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.animMed
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 6

            Text {
                text: "session"
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSm
            }

            Repeater {
                model: [{
                        "label": "logout",
                        "cmd": ["hyprctl", "dispatch", "exit"]
                    }, {
                        "label": "reboot",
                        "cmd": ["systemctl", "reboot"]
                    }, {
                        "label": "shutdown",
                        "cmd": ["systemctl", "poweroff"]
                    }]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 36
                    radius: Theme.radiusSm
                    color: ma.containsMouse ? Theme.surfaceHi : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: Theme.text
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontMd
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ShellState.powerMenuOpen = false;
                            Quickshell.execDetached(modelData.cmd);
                        }
                    }
                }
            }

            IconButton {
                Layout.alignment: Qt.AlignHCenter
                text: "cancel"
                onClicked: ShellState.powerMenuOpen = false
            }
        }
    }
}
