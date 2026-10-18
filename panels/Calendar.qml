import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../Themes"

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
    }
    margins { top: 180; left: 160 }

    implicitWidth: 300
    implicitHeight: 280
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "calendar"
    exclusionMode: ExclusionMode.Ignore

    property date now: new Date()
    readonly property var loc: Qt.locale("uk_UA")

    Timer {
        interval: 60 * 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: KuromiM.whiteRose
        

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            
            ClippingRectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                radius: 10
                color: KuromiM.bg1

                Image {
                    source: "../assets/images/kuromih.png"
                    width: 100
                    height: 100
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true

                    anchors.top: parent.top
                    anchors.topMargin: -20  
                    anchors.right: parent.right
                    anchors.rightMargin: -8 
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    spacing: 0

                    Text {
                        text: root.now.getFullYear()
                        color: "white"
                        opacity: 0.8
                        height: 10
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 18
                    }

                    Text {
                        readonly property string monthName: root.loc.standaloneMonthName(root.now.getMonth())
                        text: monthName.charAt(0).toUpperCase() + monthName.slice(1)
                        color: "white"
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 24
                    }
                }
            }

            
            DayOfWeekRow {
                Layout.fillWidth: true
                locale: root.loc

                delegate: Text {
                    required property var model

                    text: model.shortName.toUpperCase()
                    horizontalAlignment: Text.AlignHCenter
                    color: "#3C383E"
                    opacity: 0.55
                    font.family: KuromiM.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }
            }

          
            MonthGrid {
                id: calendar

                Layout.fillWidth: true
                Layout.fillHeight: true

                month: root.now.getMonth()
                year: root.now.getFullYear()
                locale: root.loc
                spacing: 0

                delegate: Item {
                    id: cell

                    required property var model

                    readonly property bool inMonth: model.month === calendar.month
                    readonly property bool isToday: inMonth && model.day === root.now.getDate()

                    Rectangle {
                        visible: cell.isToday
                        anchors.centerIn: parent
                        width: Math.min(cell.width, cell.height) - 2
                        height: width
                        radius: 10
                        color: "#CA9EE6"
                    }

                    Text {
                        visible: cell.inMonth
                        anchors.centerIn: parent
                        text: cell.model.day
                        color: cell.isToday ? "#1E1C1F" : "#3C383E"
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 14
                        font.bold: cell.isToday
                    }
                }
            }
        }
    }
}