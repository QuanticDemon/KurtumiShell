import QtQuick
import QtQuick.Controls
import Quickshell
import "../panels"
PanelWindow{
    width:3
    height:600 
    anchors{
        left:true 
    }
    color:"transparent"
    exclusiveZone:0
    Rectangle{
        anchors.fill:parent
        color:"transparent"

        ControlPanel{
            id:controlPanel
        }
        HoverHandler{
            id:hover 
            
        }

        MouseArea{
            hoverEnabled:true 
            anchors.fill:parent 
            onEntered:{
                controlPanel.opened = !controlPanel.opened
            }
            onExited:{
               controlPanel.opened = !controlPanel.opened
            }
        }
    }

    
    
}