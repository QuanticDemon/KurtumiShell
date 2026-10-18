import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../Themes"
import "../panels"
Rectangle{
    
    color:"transparent"

    
    
    Rectangle{
        
        width:parent.width
        height:35
        radius:18
        color:"#3C383E"
        anchors.centerIn: parent  

        Row{
            
            
            anchors.centerIn: parent 
            spacing:10

            anchors.verticalCenter:parent.verticalCenter
            anchors.horizontalCenter:parent.horizontalCenter
            Repeater{
                model:Hyprland.workspaces
    
                delegate:Rectangle{
                    width:25
                    height:25
                    radius:10
                    scale:modelData.focused ? 1.2:1.0
                    color: "transparent"
                    Behavior on scale{
                        NumberAnimation{
                            duration:180 
                            easing.type:Easing.OutCubic
                        }
                    }
                    Behavior on color{
                        ColorAnimation{
                            duration:180 
                            easing.type:Easing.OutCubic
                        }
                    }
                    Text{
                        text:"󰄛"
                        anchors.centerIn:parent 
                        font.pixelSize:27
                        color:modelData.focused ? "#DAAFC6":"#FF5C9A"
                        font.family:KuromiM.fontFamily
                    }

                    MouseArea{
                        anchors.fill:parent
                        cursorShape:Qt.PointingHandCursor
                        onClicked:Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + "})")
                            
                        
                    }

                    
    
                    
                }
            }
        }
        
        
        
    }
}