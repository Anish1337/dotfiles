import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs.theme
import qs.components
import qs.services

PanelWindow {
    id: panel

    required property var modelData
    screen: modelData

    readonly property bool onFocused: !Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === screen.name
    readonly property bool shown: ShellState.sidebarOpen && onFocused

    color: "transparent"
    visible: shown || slideAnim.running || fadeAnim.running
    focusable: shown
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    implicitWidth: Theme.controlWidth + Theme.barMargin + 16

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: Theme.barMargin + 8
        right: Theme.barMargin
        bottom: Theme.barMargin
    }

    HyprlandFocusGrab {
        active: panel.shown
        windows: [panel]
        onCleared: {
            if (ShellState.sidebarOpen)
                ShellState.sidebarOpen = false;
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    MouseArea {
        anchors.fill: parent
        enabled: panel.shown
        onClicked: ShellState.sidebarOpen = false
    }

    Item {
        id: slide
        anchors.top: parent.top
        anchors.right: parent.right
        width: Theme.controlWidth
        height: Math.min(Theme.controlMaxH, parent.height)
        x: panel.shown ? 0 : Theme.controlWidth + 24
        opacity: panel.shown ? 1 : 0

        Behavior on x {
            NumberAnimation {
                id: slideAnim
                duration: Theme.animSlow
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                id: fadeAnim
                duration: Theme.animMed
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.panelFill
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "system"
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSm
                }
                Item {
                    Layout.fillWidth: true
                }
                IconButton {
                    text: "x"
                    size: 24
                    onClicked: ShellState.sidebarOpen = false
                }
            }

            // Real status block
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: SysStatus.status
                    color: SysStatus.statusColor
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontLg
                    font.bold: true
                }
                Text {
                    text: SysStatus.pkgLabel
                    color: (SysStatus.pkgCount ?? 0) > 0 ? Theme.warn : Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontMd
                }
                Text {
                    text: SysStatus.netLabel
                    color: SysStatus.netLevel === "up" ? Theme.text : Theme.warn
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontMd
                }
                Text {
                    text: SysStatus.diskLabel
                    color: SysStatus.diskLevel === "ok" ? Theme.muted : Theme.warn
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontMd
                }
                Text {
                    visible: SysStatus.rebootRequired
                    text: "REBOOT REQUIRED"
                    color: Theme.danger
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontMd
                    font.bold: true
                }
                Text {
                    text: `up ${SysStats.uptimeText}`
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSm
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.divider
            }

            Flickable {
                id: flick
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: stack.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: stack
                    width: flick.width
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "AUDIO"
                                color: Theme.purple
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontMd
                                font.bold: true
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            Text {
                                text: panel.sink?.audio?.muted ? "MUTE" : `${Math.round((panel.sink?.audio?.volume ?? 0) * 100)}%`
                                color: panel.sink?.audio?.muted ? Theme.danger : Theme.text
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontMd
                            }
                        }

                        SliderBar {
                            Layout.fillWidth: true
                            from: 0
                            to: 1
                            value: panel.sink?.audio?.volume ?? 0
                            onMoved: {
                                if (panel.sink?.audio)
                                    panel.sink.audio.volume = value;
                            }
                        }
                    }

                    BrightnessControl {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.divider
                    }

                    StatMeter {
                        title: "CPU"
                        value: SysStats.cpu
                    }
                    StatMeter {
                        title: "RAM"
                        value: SysStats.mem
                        detail: `${SysStats.formatBytes(SysStats.memUsed)} / ${SysStats.formatBytes(SysStats.memTotal)}`
                    }
                    StatMeter {
                        visible: SysStats.gpu !== null && SysStats.gpu !== undefined
                        title: "GPU"
                        value: SysStats.gpu ?? 0
                        detail: SysStats.gpuTemp !== null ? `${Math.round(SysStats.gpuTemp)}°C` : ""
                        barColor: Theme.cyan
                    }
                    StatMeter {
                        title: "DISK"
                        value: SysStats.disk
                        detail: SysStatus.diskLabel.replace("DISK: ", "")
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: !!panel.player
                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Theme.divider
                        }

                        Text {
                            text: "MEDIA"
                            color: Theme.purple
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontMd
                            font.bold: true
                        }
                        Text {
                            Layout.fillWidth: true
                            text: panel.player?.trackTitle || ""
                            color: Theme.text
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontMd
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: panel.player?.trackArtist || ""
                            color: Theme.muted
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fontSm
                            elide: Text.ElideRight
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8
                            IconButton {
                                text: "⏮"
                                onClicked: panel.player?.previous()
                            }
                            IconButton {
                                text: panel.player?.isPlaying ? "⏸" : "▶"
                                active: !!panel.player?.isPlaying
                                onClicked: panel.player?.togglePlaying()
                            }
                            IconButton {
                                text: "⏭"
                                onClicked: panel.player?.next()
                            }
                        }
                    }

                    ExpandSection {
                        id: notifSection
                        title: "NOTIFICATIONS"
                        badge: notifSection.count > 0 ? `${notifSection.count}` : ""
                        property int count: 0

                        NotificationList {
                            id: notifList
                            onItemsChanged: notifSection.count = items.length
                            Component.onCompleted: notifSection.count = items.length
                        }
                    }

                    ExpandSection {
                        title: "CALENDAR"

                        CalendarStrip {
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                IconButton {
                    Layout.fillWidth: true
                    text: "reboot"
                    onClicked: Quickshell.execDetached(["systemctl", "reboot"])
                }
                IconButton {
                    Layout.fillWidth: true
                    text: "off"
                    onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
                }
            }
        }
    }
}
