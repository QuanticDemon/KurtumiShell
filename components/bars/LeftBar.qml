import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../Themes"
import "../../components"
import "../../panels"

Item {
    id: root
    width: parent.width
    height: parent.height

    PowerPanel { id: powerPanel }
    Launcher { id: launcher }

    Island {
        anchors.fill: parent
        fill: KuromiM.bg0
        flareLeft: 0       
        flareRight: 20     
        radiusLeft: 0      
        radiusRight: 20

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.leftMargin: 10
                radius: height / 2
                color: mouse.containsMouse ? "#3C383E" : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                Image {
                    anchors.fill: parent
                    source: "../../assets/icons/kuromi-skull.svg"
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launcher.opened = !launcher.opened
                }
            }

            Workspaces {
                Layout.preferredWidth: 200
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }
        }
    }
}