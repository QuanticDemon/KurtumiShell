import QtQuick
import Quickshell
import "bars"
Rectangle{
    anchors.fill:parent 
    
    color:"transparent"
    
  
    radius:10


    Row{
        anchors.fill:parent 

        Item{
            width:300
            height:parent.height
            anchors.left:parent.left 

            LeftBar{
                
            }
        }
        CenterBar{
            
        }
        Item{
            width:350
            height:parent.height
            anchors.right:parent.right
            
            RightBar{
            
            }
        }
    }
    
}