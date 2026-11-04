import QtQuick
import qs.core

Rectangle {
    id: root

    default property alias content: body.data
    property alias contentItem: body
    property int margin: Theme.popupPadding
    property color borderColor: Theme.popupBorder
    property real borderWidth: 3

    opacity: 1.0
    color: Theme.popupBackground
    border.color: root.borderColor
    border.width: root.borderWidth
    radius: Theme.popupRadius

    PillShadow { cornerRadius: root.radius }

    Item {
        id: body

        anchors.fill: parent
        anchors.margins: root.margin
    }
}
