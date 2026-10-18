import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../Themes"
PanelWindow{
    id:root 
    implicitHeight:600
    property var filteredApplications: {
        const apps = DesktopEntries.applications.values
        const query = searchBar.text.trim().toLowerCase()
    
        if (query.length === 0)
            return apps
    
        return apps.filter(app =>
            app.name.toLowerCase().includes(query)
        )
    }
    implicitWidth:500
    property bool opened:false 
    color:"transparent"
    visible:opened
    HyprlandFocusGrab{
        windows:[root]
        active:root.opened
        onCleared:root.opened = false
    }

    onOpenedChanged: {
        if (opened) {
            content.positionViewAtBeginning()
    
            Qt.callLater(() => {
                searchBar.forceActiveFocus()
            })
        } else {
            searchBar.focus = false
        }
    }

    Column{
        
        anchors.fill:parent
        Rectangle{
            id:kuromiImg
            width:parent.width
            height:60
            color:"transparent"
            anchors.margins:10
            

            RowLayout{
                anchors.fill:parent 

                Image{
                    Layout.preferredWidth:120
                    Layout.preferredHeight:80
                    source:"../assets/images/kuromiLauncher.jpg"
                }
            }
        }
        Rectangle{
            
            color:KuromiM.bg0
            width:parent.width
            height:parent.height - kuromiImg.height
            radius:18
    
            Column{
                anchors.fill:parent 
                anchors.margins:10
                spacing:10
                TextField{
                    id:searchBar
                    width:parent.width
                    height:40 
                    z:10
                    padding:10
                    placeholderText:"Search applications"
                    placeholderTextColor:"#FF5C9A"
                    color:"#FF5C9A"
                    font.family:KuromiM.fontFamily
                    font.bold:false 
                    font.pixelSize:20
                    Component.onCompleted: {
                            if (root.opened)
                                forceActiveFocus()
                        }
                    
                        onVisibleChanged: {
                            if (visible && root.opened)
                                forceActiveFocus()
                    }
                    onTextChanged:content.positionViewAtBeginning()
                    background:Rectangle{
                        color:KuromiM.whiteRose
                        radius:10
                    }

                    
                }
                
                ListView{
                    id:content
                    width:parent.width
                    height:parent.height - searchBar.height -parent.spacing
                    
                    model:root.filteredApplications
                    spacing:10
                    delegate:Rectangle{
                        width:ListView.view.width
                        height:60
                        color:mouse.containsMouse ? "#3C383E":"transparent"
                        border.width:1
                        border.color:KuromiM.whiteRose
                        radius:10

                        Behavior on color{
                            ColorAnimation{
                                duration:150 
                                easing.type:Easing.OutCubic
                            }
                        }
                        
                        
                        required property var modelData

                        RowLayout{
                            anchors.fill:parent 
                            spacing:20
                            Image{
                                Layout.preferredHeight:40 
                                Layout.preferredWidth:40
                                Layout.alignment:Qt.AlignVCenter
                                Layout.leftMargin:10
                                source:Quickshell.iconPath(modelData.icon)
                            }

                            Text{
                                text:modelData.name
                                Layout.alignment:Qt.AlignLeft
                                Layout.fillWidth:true
                                font.family:KuromiM.fontFamily
                                font.pixelSize:25
                                font.bold:false
                                color:KuromiM.whiteRose
                            }
                        }
                        MouseArea{
                            id:mouse
                            anchors.fill:parent 
                            hoverEnabled:true 
                            cursorShape:Qt.PointingHandCursor

                            onClicked:{
                                modelData.execute()
                                root.opened = false
                            }
                        }
                    }
                }
            }
        }
    }
    
}