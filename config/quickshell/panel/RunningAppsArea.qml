pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.core

RowLayout {
    id: root

    required property var desktopState
    spacing: Theme.barPanelGap

    Repeater {
        model: root.desktopState.runningApps

        delegate: RunningAppItem {
            required property var modelData
            required property int index
            app: modelData
            appIndex: index
            active: modelData.appClass === root.desktopState.activeWindowClass
            onFocusRequested: windowId => root.desktopState.focusWindow(windowId)
        }
    }
}
