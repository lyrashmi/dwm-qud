import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core

pragma ComponentBehavior: Bound

// qmllint disable uncreatable-type
PanelWindow {
    id: root

    signal popupRequested(var panelWindow, string popupId)
    signal settingsSectionRequested(var panelWindow, string section)
    function updateCenterAnchorX() {
        const point = updateCenterIndicator.mapToGlobal(updateCenterIndicator.width / 2, 0);
        const screenX = root.screen && root.screen.x !== undefined ? root.screen.x : 0;
        return point.x - screenX;
    }

    function batteryIcon(percent, status) {
        if (status.toLowerCase() === "charging") {
            return "󰂄";
        }

        if (percent >= 90) return "󰁹";
        if (percent >= 80) return "󰂂";
        if (percent >= 70) return "󰂁";
        if (percent >= 60) return "󰂀";
        if (percent >= 50) return "󰁿";
        if (percent >= 40) return "󰁾";
        if (percent >= 30) return "󰁽";
        if (percent >= 20) return "󰁼";
        if (percent >= 10) return "󰁻";
        return "󰂎";
    }

    required property var state
    required property var clock
    required property var updateCenterModel
    required property var networkModel
    required property var controlsModel
    required property var bluetoothModel
    required property var controlCenterModel
    required property var panelSettingsModel
    required property var powerModel
    required property var powerMenuModel
    required property bool primaryPanel

    implicitHeight: Theme.barPanelHeight
    color: Theme.barBackground
    exclusiveZone: Theme.barPanelHeight
    aboveWindows: root.state.fullscreenMonitorIndexes.indexOf(
        root.state.screenIndex(root.screen)) === -1

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        id: island

        anchors.fill: parent
        anchors.leftMargin: Theme.panelEdgeMargin
        anchors.rightMargin: Theme.panelEdgeMargin
        anchors.topMargin: Theme.panelMargin
        anchors.bottomMargin: Theme.panelMargin
        opacity: 1.0
        color: "#0e1213"
        border.color: "transparent"
        border.width: 0
        radius: Theme.barRadius

        PillShadow { cornerRadius: island.radius }

        MouseArea {
            anchors.fill: parent
            onClicked: root.popupRequested(root, "")
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.barPanelGap
            anchors.rightMargin: Theme.barPanelGap
            spacing: Theme.barPanelGap

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width)
                    height: parent.height
                    spacing: Theme.barPanelGap

                    LogoButton {
                        id: logoButton
                        onActivated: {
                            root.popupRequested(root, "controlcenter");
                            root.controlCenterModel.toggle();
                        }
                    }

                    PanelPill {
                        panelScaled: true
                        visible: root.panelSettingsModel.widgetEnabled("workspaces")
                        Layout.preferredWidth: workspaceRow.implicitWidth + Theme.panelScaledSize(8)
                        Layout.preferredHeight: Theme.barPillHeight

                        RowLayout {
                            id: workspaceRow

                            anchors.centerIn: parent
                            spacing: Theme.panelScaledSize(1)

                            Repeater {
                                model: root.state.workspaceIndexes(root.screen)

                                delegate: WorkspaceButton {
                                    required property int modelData

                                    label: root.state.workspaceNames[modelData]
                                    workspaceIndex: modelData
                                    selected: modelData === root.state.currentWorkspaceForScreen(root.screen)
                                    occupied: root.state.workspaceOccupied(modelData)
                                    onClicked: root.state.switchWorkspaceForScreen(root.screen, modelData)
                                }
                            }
                        }
                    }

                    PanelPill {
                        panelScaled: true
                        Layout.preferredWidth: Math.min(activeTitle.implicitWidth + Theme.barPillHorizontalPadding * 2, Theme.panelScaledSize(260))
                        Layout.preferredHeight: Theme.barPillHeight
                        outlined: false

                        Item {
                            id: titleViewport

                            property real titleOffset: 0
                            readonly property real titleStartOffset: Math.min(
                                0, titleViewport.width - activeTitle.implicitWidth)

                            anchors.fill: parent
                            anchors.leftMargin: Theme.barPillHorizontalPadding
                            anchors.rightMargin: Theme.barPillHorizontalPadding
                            clip: true

                            UiText {
                                id: activeTitle

                                x: titleViewport.titleOffset
                                anchors.verticalCenter: parent.verticalCenter
                                width: Theme.reducedMotion ? titleViewport.width
                                    : Math.max(titleViewport.width, implicitWidth)
                                text: root.state.activeWindowTitle
                                color: "#009403"
                                elide: Theme.reducedMotion ? Text.ElideRight : Text.ElideNone
                                onTextChanged: {
                                    const shouldScroll = !Theme.reducedMotion
                                        && titleViewport.width > 0
                                        && implicitWidth > titleViewport.width;
                                    titleViewport.titleOffset = shouldScroll
                                        ? titleViewport.titleStartOffset : 0;
                                    if (shouldScroll) titleScroll.restart();
                                    else titleScroll.stop();
                                }
                            }

                            SequentialAnimation {
                                id: titleScroll

                                running: !Theme.reducedMotion && titleViewport.width > 0
                                    && activeTitle.implicitWidth > titleViewport.width

                                onRunningChanged: titleViewport.titleOffset = running
                                    ? titleViewport.titleStartOffset : 0

                                PropertyAction {
                                    target: titleViewport
                                    property: "titleOffset"
                                    value: titleViewport.titleStartOffset
                                }
                                PauseAnimation { duration: 800 }

                                NumberAnimation {
                                    target: titleViewport
                                    property: "titleOffset"
                                    to: 0
                                    duration: Math.min(6000, Math.max(1400,
                                        (activeTitle.implicitWidth - titleViewport.width) * 16))
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }
                    }

                }
            }

            PanelPill {
                panelScaled: true
                Layout.preferredWidth: clockLabel.implicitWidth + Theme.barPillHorizontalPadding * 2
                Layout.preferredHeight: Theme.barPillHeight
                outlined: false

                UiText {
                    id: clockLabel

                    anchors.centerIn: parent
                    text: root.clock.panelText
                    color: "#b1c9c3"
                    font.bold: true
                }
            }

            ShellButton {
                id: updateCenterIndicator
                outlined: false
                useCustomBackgroundColor: true
                customBackgroundColor: "#0e1213"
                objectName: "updateCenterIndicator"
                customLabelColor: true
                labelColor: "#40a4b9"
                visible: root.updateCenterModel.shouldShow()
                leadingIcon: "../assets/update-center/dwm-update-center.png"
                leadingIconSize: Theme.panelScaledSize(14)
                label: root.updateCenterModel.totalUpdates > 0
                    ? root.updateCenterModel.totalUpdates.toString() : ""
                panelScaled: true
                labelSpacing: Theme.panelScaledSize(4)
                accessibleDescription: root.updateCenterModel.totalUpdates > 0
                    ? root.updateCenterModel.totalUpdates.toString() + " updates available"
                    : "Updates are current"
                onActivated: root.popupRequested(root, "updatecenter")
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0

                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.barPanelGap

                    Item { Layout.fillWidth: true }

                    Repeater {
                        model: root.state.statusSegments

                        delegate: PanelPill {
                            panelScaled: true
                            required property string modelData
                            Layout.preferredWidth: statusLabel.implicitWidth + Theme.barPillHorizontalPadding * 2
                            Layout.preferredHeight: Theme.barPillHeight
                            outlined: true

                            UiText {
                                id: statusLabel
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: Theme.text
                            }
                        }
                    }

                    RunningAppsArea { desktopState: root.state }

                    Loader {
                        active: root.primaryPanel
                        sourceComponent: TrayArea {}
                    }

                    PanelPill {
                        panelScaled: true
                        id: keyboardPill
                        visible: root.panelSettingsModel.widgetEnabled("keyboard-layout")
                            && root.state.keyboardGroupCount > 1
                        Layout.preferredWidth: keyboardLabel.implicitWidth + Theme.barCompactWidgetHorizontalPadding * 2
                        Layout.preferredHeight: Theme.barCompactWidgetSize
                        hovered: keyboardMouse.containsMouse

                        UiText {
                            id: keyboardLabel
                            anchors.centerIn: parent
                            text: root.state.keyboardLabel(root.state.keyboardGroup)
                            color: Theme.textStrong
                            font.pixelSize: Theme.barFontSize
                        }

                        MouseArea {
                            id: keyboardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                            onClicked: function(mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    root.settingsSectionRequested(root, "input");
                                } else if (mouse.button === Qt.MiddleButton) {
                                    root.state.setKeyboardLayout(0);
                                } else {
                                    root.state.cycleKeyboardLayout(1);
                                }
                            }
                            onWheel: function(wheel) {
                                root.state.wheelKeyboardLayout(wheel.angleDelta.y);
                                wheel.accepted = true;
                            }
                        }
                    }

                    PanelPill {
                        panelScaled: true
                        id: batteryPill
                        visible: root.powerModel.batteryAvailable
                        Layout.preferredWidth: batteryRow.implicitWidth + Theme.barCompactWidgetHorizontalPadding * 2
                        Layout.preferredHeight: Theme.barCompactWidgetSize
                        hovered: batteryMouse.containsMouse

                        RowLayout {
                            id: batteryRow
                            anchors.centerIn: parent
                            spacing: Theme.barCompactSpacing

                            IconText {
                                text: root.batteryIcon(root.powerModel.batteryPercent, root.powerModel.batteryStatus)
                                color: Theme.textStrong
                                font.pixelSize: Theme.panelScaledFontSize(14 * 1.1, 8)
                            }

                            UiText {
                                text: root.powerModel.batteryPercent.toString() + "%"
                                color: Theme.textStrong
                                font.pixelSize: Theme.barFontSize
                            }
                        }

                        MouseArea {
                            id: batteryMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }

                    PanelPill {
                        panelScaled: true
                        visible: root.panelSettingsModel.widgetEnabled("bluetooth")
                        Layout.preferredWidth: bluetoothRow.implicitWidth + Theme.barCompactWidgetHorizontalPadding * 2
                        Layout.preferredHeight: Theme.barCompactWidgetSize
                        active: root.bluetoothModel.visible
                        hovered: bluetoothMouse.containsMouse

                        RowLayout {
                            id: bluetoothRow
                            anchors.centerIn: parent
                            spacing: Theme.barCompactSpacing

                            IconText {
                                text: "󰂯"
                                color: Theme.textStrong
                                font.pixelSize: Theme.panelScaledFontSize(14 * 0.9, 8)
                            }
                        }

                        MouseArea {
                            id: bluetoothMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.popupRequested(root, "bluetooth");
                                root.bluetoothModel.toggle();
                            }
                        }
                    }

                    PanelPill {
                        panelScaled: true
                        visible: root.panelSettingsModel.widgetEnabled("network")
                        Layout.preferredWidth: networkRow.implicitWidth + Theme.barNetworkWidgetHorizontalPadding * 2
                        Layout.preferredHeight: Theme.barCompactWidgetSize
                        active: root.networkModel.visible
                        hovered: networkMouse.containsMouse

                        RowLayout {
                            id: networkRow
                            anchors.centerIn: parent
                            spacing: Theme.barCompactSpacing

                            IconText {
                                text: root.networkModel.statusText.indexOf("offline") >= 0
                                    || root.networkModel.statusText.indexOf("unavailable") >= 0 ? "󰤭" : "󰤨"
                                color: Theme.textStrong
                                font.pixelSize: Theme.panelScaledFontSize(14 * 1.2, 8)
                            }
                        }

                        MouseArea {
                            id: networkMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.popupRequested(root, "network");
                                root.networkModel.toggle();
                            }
                        }
                    }

                    PanelPill {
                        panelScaled: true
                        visible: root.panelSettingsModel.widgetEnabled("volume")
                        Layout.preferredWidth: volumeRow.implicitWidth + Theme.barCompactWidgetHorizontalPadding * 2
                        Layout.preferredHeight: Theme.barCompactWidgetSize
                        active: root.controlsModel.visible
                        hovered: controlsMouse.containsMouse

                        RowLayout {
                            id: volumeRow
                            anchors.centerIn: parent
                            spacing: Theme.barCompactSpacing

                            IconText {
                                text: root.controlsModel.volumeMuted ? "󰝟" : "󰕾"
                                color: Theme.textStrong
                                font.pixelSize: Theme.panelScaledFontSize(14 * 1.5, 8)
                            }

                            UiText {
                                visible: root.controlsModel.volumeText !== "VOL unavailable"
                                text: root.controlsModel.volumePercent.toString() + "%"
                                color: Theme.textStrong
                                font.pixelSize: Theme.barFontSize
                            }
                        }

                        MouseArea {
                            id: controlsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.popupRequested(root, "controls");
                                root.controlsModel.toggle();
                            }
                            onWheel: function(wheel) {
                                if (wheel.angleDelta.y > 0) {
                                    root.controlsModel.volumeUp();
                                } else if (wheel.angleDelta.y < 0) {
                                    root.controlsModel.volumeDown();
                                }
                                wheel.accepted = true;
                            }
                        }
                    }

                    PanelPill {
                        panelScaled: true
                        visible: root.panelSettingsModel.widgetEnabled("power")
                        Layout.preferredWidth: Theme.barPillHeight
                        Layout.preferredHeight: Theme.barPillHeight
                        active: root.powerMenuModel.visible
                        hovered: powerMouse.containsMouse

                        IconText {
                            anchors.centerIn: parent
                            text: "󰐥"
                            color: Theme.textStrong
                            font.pixelSize: Theme.panelScaledFontSize(14 * 1.08, 8)
                        }

                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.popupRequested(root, "power");
                                root.powerMenuModel.toggle("panel");
                            }
                        }
                    }
                }
            }
        }
    }

    PanelTooltip {
        visible: logoButton.hovered
        anchorWindow: root
        anchorItem: logoButton
        label: "Control Center"
        anchorY: Theme.barPanelHeight
    }

    PanelTooltip {
        visible: root.powerModel.batteryAvailable && batteryMouse.containsMouse
        anchorWindow: root
        anchorItem: batteryPill
        label: root.powerModel.batteryPercent.toString() + "% - " + root.powerModel.batteryStatus
        anchorY: Theme.barPanelHeight
        rightAligned: true
    }

    PanelTooltip {
        visible: keyboardPill.visible && keyboardMouse.containsMouse
        anchorWindow: root
        anchorItem: keyboardMouse
        label: root.state.keyboardSummary() + " - click: next layout, right-click: input settings"
        anchorY: Theme.barPanelHeight
        rightAligned: true
    }

    PanelTooltip {
        visible: bluetoothMouse.containsMouse
        anchorWindow: root
        anchorItem: bluetoothMouse
        label: root.bluetoothModel.statusText
        anchorY: Theme.barPanelHeight
        rightAligned: true
    }

    PanelTooltip {
        visible: networkMouse.containsMouse
        anchorWindow: root
        anchorItem: networkMouse
        label: root.networkModel.statusText
        anchorY: Theme.barPanelHeight
        rightAligned: true
    }

    PanelTooltip {
        visible: controlsMouse.containsMouse
        anchorWindow: root
        anchorItem: controlsMouse
        label: root.controlsModel.volumeDisplayText
        anchorY: Theme.barPanelHeight
        rightAligned: true
    }

    PanelTooltip {
        visible: powerMouse.containsMouse
        anchorWindow: root
        anchorItem: powerMouse
        label: "Power"
        anchorY: Theme.barPanelHeight
        rightAligned: true
    }
}
