import QtQuick
import Quickshell
import "../Themes"

Item {
    id: root

    width: clockText.implicitWidth
    height: clockText.implicitHeight
    
    property string currentTime: Qt.formatDateTime(new Date(), "HH:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.currentTime = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        
        text: root.currentTime
        color: "white"
        font.family: KuromiM.fontFamily
        font.pixelSize: 35
        font.bold: false
        font.letterSpacing: 2
    }
}