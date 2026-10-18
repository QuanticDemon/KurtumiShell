import QtQuick
import QtQuick.Controls
import Quickshell
import "../panels"
PanelWindow{
    width:300
    height:2  
    anchors{
        bottom:true 
    }
    color:"transparent"
    exclusiveZone:0
    Rectangle{
        anchors.fill:parent
        color:"transparent"

        DeathNote{
            id:dn
        }
        HoverHandler{
            id:hover 
            
        }

        MouseArea{
            hoverEnabled:true 
            anchors.fill:parent 
            onEntered:{
                dn.opened = true
            }
            onExited:{
               
            }
        }
    }

    
    
}