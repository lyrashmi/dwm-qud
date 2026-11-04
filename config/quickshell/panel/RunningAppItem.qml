import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.core

Rectangle {
    id: root

    required property var app
    required property bool active
    required property int appIndex
    signal focusRequested(string windowId)

    readonly property string assignedImage: {
        switch (app.appClass) {
        case "zen": return "zen.png";
        case "alacritty": return "alacritty.png";
        case "org.gnome.nautilus": return "nautilus.png";
        default: return "";
        }
    }

    Layout.preferredWidth: Theme.pillHeight
    Layout.preferredHeight: Theme.pillHeight
    radius: Theme.pillRadius
    clip: true

    color: active ? Theme.controlSelectedFill
        : appMouse.containsMouse ? Theme.controlHoverFill : Theme.transparent
    border.width: 0

    // Permanent image for recognised applications.
    Image {
        id: assignedBackground
        anchors.fill: parent
        z: 0

        source: root.assignedImage !== ""
            ? Qt.resolvedUrl("../assets/workspaces/running-apps/" + root.assignedImage)
            : ""

        visible: status === Image.Ready
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        mipmap: true
    }

    // Numbered fallback for applications without a permanent assignment.
    Image {
        anchors.fill: parent
        z: 0

        source: Qt.resolvedUrl(
            "../assets/workspaces/running-apps/app" + (root.appIndex + 1) + ".png"
        )

        visible: assignedBackground.status !== Image.Ready
            && status === Image.Ready

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        mipmap: true
    }

    IconImage {
        z: 1
        anchors.centerIn: parent
        width: Theme.trayIconSize
        height: Theme.trayIconSize
        source: Icons.launcherIcon(root.app.appClass)
    }

    // Selection and hover outline, drawn above the image and icon.
    Rectangle {
        anchors.fill: parent
        z: 2
        color: "transparent"
        radius: Theme.pillRadius

        border.color: active
            ? Theme.controlSelectedBorder
            : Theme.controlNormalBorder

        border.width: 0
    }

    MouseArea {
        id: appMouse
        z: 3
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.focusRequested(root.app.windowId)
    }
}
