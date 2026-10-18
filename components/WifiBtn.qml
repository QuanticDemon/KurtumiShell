
import QtQuick
import QtQuick.Controls
import Quickshell
import "../Themes"
import "../panels"
import "../services"

Item {
    id: root

    width: 40
    height: 40

    NetPanel {
        id: netPanel
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
                netPanel.opened = !netPanel.opened
            }
        }

        Text {
            anchors.centerIn: parent

            text: ""
            color: Wifi.connexion
                ? KuromiM.purple1
                : KuromiM.whiteRose

            font.family: KuromiM.fontFamily
            font.pixelSize: 14
        }

       
        ToolTip.delay: 500
    }
}
