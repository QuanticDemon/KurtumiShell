import QtQuick
import QtQuick.Layouts
import "../../Themes"
import "../../components"
import "../../panels"
Item {
    id: root
    width: parent.width
    height: parent.height

    PowerPanel { id: powerPanel }

    Island {
        anchors.fill: parent
        fill: KuromiM.bg0
        flareLeft: 20
        flareRight: 0        
        radiusLeft: 20
        radiusRight:0

        RowLayout {
            anchors.fill: parent
            spacing: 8

            Item { Layout.fillWidth: true }

          
            WallpaperBtn{
                
            }

            Rectangle{
                Layout.preferredHeight: 30
                Layout.preferredWidth: 1
            }
            AudioBtn{
                
            }
            Rectangle{
                Layout.preferredHeight: 30
                Layout.preferredWidth: 1
            }
            WifiBtn{}
            Rectangle{
                Layout.preferredHeight: 30
                Layout.preferredWidth: 1
            }
            BtBtn{}
            Rectangle{
                Layout.preferredHeight: 30
                Layout.preferredWidth: 1
            }
            BatteryBtn {}
            Rectangle{
                Layout.preferredHeight: 30
                Layout.preferredWidth: 1
            }

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.rightMargin: 5
                color: hoverPowerOff.hovered ? "#3c383e" : "transparent"
                radius: height / 2

                HoverHandler { id: hoverPowerOff }
                MouseArea {
                    anchors.fill: parent
                    onClicked: powerPanel.opened = !powerPanel.opened
                }
                Behavior on color {
                    ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
                Text {
                    text: "⏻"
                    font.family: KuromiM.fontFamily
                    color: "white"
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}