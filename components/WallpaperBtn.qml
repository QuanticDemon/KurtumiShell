import QtQuick
import QtQuick.Controls
import Quickshell
import "../Themes"
import "../panels"
Item{
    width:40
    height:40

    Wallpapers{
        id:wall
    }

    Rectangle{
        anchors.fill:parent 

        color:mouse.containsMouse ? KuromiM.bg1:"transparent"
        radius:height/2 

        MouseArea{
            anchors.fill:parent 
            id:mouse
            hoverEnabled:true 
            cursorShape:Qt.PointingHandCursor
            onClicked:{
                wall.opened = !wall.opened
            }
        }
        Text{
            anchors.centerIn:parent 
            text:""
            color:KuromiM.purple1
            font.family:KuromiM.fontFamily
            
        }
    }
}