//@ pragma UseQApplication
//@ pragma IconTheme Adwaita
import Quickshell
import Quickshell.Io
import QtQuick
import qs.sidebar
import qs.widgets
import qs.services

ShellRoot {
    IpcHandler {
        target: "shell"

        function toggleLauncher() {
            ShellState.toggleLauncher();
        }

        function toggleSidebar() {
            ShellState.toggleSidebar();
        }

        function togglePowerMenu() {
            ShellState.togglePowerMenu();
        }

        function closeAll() {
            ShellState.closeOverlays();
        }
    }

    Variants {
        model: Quickshell.screens

        Sidebar {
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        PowerMenu {
            modelData: modelData
        }
    }
}
