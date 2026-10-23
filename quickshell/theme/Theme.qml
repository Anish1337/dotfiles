pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    // Minimal purple terminal console
    readonly property color bg: "#0a0a0c"
    readonly property color surface: "#121216"
    readonly property color surfaceHi: "#1a1a20"
    readonly property color purple: "#8b7bb8"
    readonly property color purpleDim: "#5c4f7a"
    readonly property color cyan: "#6ec6d4"
    readonly property color text: "#e6e6ef"
    readonly property color muted: "#8a8798"
    readonly property color danger: "#e8798a"
    readonly property color warn: "#c4b5fd"
    readonly property color ok: "#8a8798"
    readonly property color overlay: "#0a0a0ccc"

    readonly property real panelOpacity: 0.94
    readonly property int radius: 8
    readonly property int radiusSm: 5

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property int fontSm: 12
    readonly property int fontMd: 14
    readonly property int fontLg: 15
    readonly property int fontClock: 19

    readonly property int zoneHeight: 46
    readonly property int barMargin: 10
    readonly property int zoneGap: 10
    readonly property int zonePadX: 12
    readonly property int zonePadY: 8

    readonly property int controlWidth: 340
    readonly property int controlMaxH: 720

    property bool reducedMotion: false
    readonly property int animFast: reducedMotion ? 1 : 100
    readonly property int animMed: reducedMotion ? 1 : 180
    readonly property int animSlow: reducedMotion ? 1 : 280

    readonly property color panelFill: Qt.rgba(0.07, 0.07, 0.085, panelOpacity)
    readonly property color divider: Qt.rgba(0.545, 0.482, 0.72, 0.28)
}
