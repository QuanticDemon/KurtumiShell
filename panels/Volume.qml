import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../services"
import "../Themes"

PanelWindow {
    id: root

    implicitWidth: 320
    implicitHeight: 100
    exclusiveZone:0
    property bool opened: false

    anchors{
        top:true
    }
    margins{
        top:20
    }
    property real actualVol: Audio.volume

    color: "transparent"
    visible: opened

    Rectangle{
        anchors.fill:parent 
        color:KuromiM.bg0
        radius:10

        RowLayout{
            anchors.fill:parent 
            spacing:5
            Text{
                text:Math.round(root.actualVol * 100)
                Layout.fillWidth:true 
                horizontalAlignment:Text.AlignHCenter
                color:"white"
            }
            Rectangle {
                Layout.alignment:Qt.AlignCenter
                Layout.preferredWidth: 220
                Layout.preferredHeight: 8
                radius: height / 2
                color: "gray"
        
                Rectangle {
                    width: parent.width * root.actualVol
                    height: parent.height
                    radius: parent.radius
                    color: KuromiM.purple1
        
                    Behavior on width {
                        NumberAnimation {
                            duration: 120
                        }
                    }
                }
            }
            Text{
                text:"100"
                Layout.fillWidth:true 
                horizontalAlignment:Text.AlignHCenter
                color:"white"
            }
        }
        
        
    }
    
}