
import QtQuick
import QtQuick.Controls
import Quickshell
import "../services"
import "../Themes"
import "../panels"
Item {
    id: root

    width: 40
    height: 40

    Volume{
        id:vol
    }
    Rectangle {
        anchors.fill: parent

        color: mouse.containsMouse ? KuromiM.bg1 : "transparent"
        radius: height / 2

        Timer {
            id: closeTimer
            interval: 1000
            onTriggered: vol.opened = false
        }
        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onDoubleClicked: {
                Audio.muteAudio()
            }

            onWheel: function(wheel) {
                if (wheel.angleDelta.y === 0)
                    return

                Audio.changeVol(
                    wheel.angleDelta.y > 0
                        ? 0.01
                        : -0.01
                )

                
                vol.opened = true
                closeTimer.restart()
            }
        }

        Text {
            anchors.centerIn: parent
            text: "󰕾"
            color: KuromiM.purple1
            font.family: KuromiM.fontFamily
            font.pixelSize:17
        }
    }
}
