import QtQuick
import QtQuick.Layouts
import qs.core

Rectangle {
    id: root

    required property string label
    required property bool selected
    required property bool occupied
    required property int workspaceIndex

    signal clicked()

    Layout.preferredWidth: Theme.workspaceButtonSize
    Layout.preferredHeight: Theme.workspaceButtonSize

    radius: 0
    clip: true

    color: root.occupied && workspaceBackground.status === Image.Ready
        ? "transparent"
        : selected ? Theme.controlSelectedFill
        : workspaceMouse.containsMouse ? Theme.controlHoverFill
        : Theme.transparent

    border.width: 0

    // Desktop background image.
    Image {
        id: workspaceBackground

        anchors.fill: parent

        source: Qt.resolvedUrl(
            "../assets/workspaces/desktop_bg"
            + (root.workspaceIndex + 1) + ".png"
        )

        visible: root.occupied && status === Image.Ready

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        mipmap: true
    }

    // Marks desktops that contain windows.
    Rectangle {
        visible: root.occupied
        x: Theme.scaledSize(3)
        y: Theme.scaledSize(3)
        width: Theme.scaledSize(4)
        height: width

        color: root.selected ? Theme.controlSelectedText
            : Theme.highContrast ? Theme.textStrong : Theme.accent
    }

    // Desktop number.
    Text {
        anchors.centerIn: parent

        visible: !(root.occupied && workspaceBackground.status === Image.Ready)

        text: root.label

        color: root.selected ? Theme.controlSelectedText
            : workspaceMouse.containsMouse ? Theme.controlHoverText
            : root.occupied ? Theme.textStrong : Theme.textMuted

        font.family: Theme.fontFamily
        font.pixelSize: Theme.panelFontSize
        font.bold: root.selected

        verticalAlignment: Text.AlignVCenter
    }

    // Selection and hover border, drawn above the image.
    Rectangle {
        anchors.fill: parent
        z: 2

        color: "transparent"
        radius: 0

        border.color: root.selected
            ? Theme.controlSelectedBorder
            : Theme.controlNormalBorder

        border.width: 0
    }

    MouseArea {
        id: workspaceMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
