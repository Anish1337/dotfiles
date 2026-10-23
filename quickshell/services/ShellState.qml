pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool sidebarOpen: false
    property bool powerMenuOpen: false

    function closeOverlays() {
        sidebarOpen = false;
        powerMenuOpen = false;
    }

    function toggleLauncher() {
        closeOverlays();
        // qs cwd is its config dir; start apps from $HOME instead
        Quickshell.execDetached({
            command: ["fuzzel"],
            workingDirectory: Quickshell.env("HOME")
        });
    }

    function toggleSidebar() {
        const next = !sidebarOpen;
        powerMenuOpen = false;
        sidebarOpen = next;
    }

    function togglePowerMenu() {
        const next = !powerMenuOpen;
        sidebarOpen = false;
        powerMenuOpen = next;
    }
}
