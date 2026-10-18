
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../Themes"
import "../panels"

Item {
    id: root

    width: 40
    height: 40

    BtPanel {
        id: btPanel
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2

        color: mouse.containsMouse
            ? KuromiM.bg1
            : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                btPanel.opened = !btPanel.opened
            }
        }

        Text {
            anchors.centerIn: parent

            text: "󰂯"

            color: Bluetooth.defaultAdapter &&
                   Bluetooth.defaultAdapter.enabled
                ? KuromiM.purple1
                : KuromiM.whiteRose

            font.family: KuromiM.fontFamily
            font.pixelSize: 18
        }
    }
}
