import QtQuick
import QtQuick.Layouts
import qs.core

PanelPill {
    id: root

    signal activated

    panelScaled: true

    Layout.preferredWidth: Theme.barPillHeight
    Layout.preferredHeight: Theme.barPillHeight
    hovered: logoMouse.containsMouse

    Image {
        id: logoImage

        anchors.centerIn: parent
        width: Theme.panelScaledSize(24)
        height: Theme.panelScaledSize(25.2)
        source: Qt.resolvedUrl("../assets/ctt_logo.png")
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true
    }

    UiText {
        anchors.centerIn: parent
        visible: logoImage.status === Image.Error
        text: "CTT"
        color: Theme.accent
        font.pixelSize: Theme.barTinyFontSize
        font.bold: true
    }

    MouseArea {
        id: logoMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
