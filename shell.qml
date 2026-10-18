import QtQuick
import Quickshell
import "components"
import "panels"
import "hotspots"
ShellRoot{
    PanelWindow{
        id:main 
        anchors{
            top:true
            left:true 
            right:true 

            
        }
        
        implicitHeight:50
        color:"transparent"

        Bar{}
    }
    Left{}
    Bottom{}
    Calendar{
        
    }
    Pomodoro{}
}