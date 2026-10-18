
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../Themes"

PanelWindow {
    id: root

    implicitWidth: 180
    implicitHeight: 200

    color: "transparent"
    exclusiveZone: 0

    property bool opened: false
    property bool closing: false

    visible: opened || closing

    function runAction(action) {
        let command = []

        switch (action) {
        case "Power Off":
            command = ["systemctl", "poweroff"]
            break

        case "Suspend":
            command = ["systemctl", "suspend"]
            break

        case "Reboot":
            command = ["systemctl", "reboot"]
            break

        case "Lock":
            command = ["hyprlock"]
            break

        case "Log Out":
            command = ["hyprctl", "dispatch", "exit"]
            break

        default:
            return
        }

        root.closing = true
        root.opened = false

        Quickshell.execDetached({
            command: command
        })
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.opened

        onCleared: root.opened = false
    }

    anchors {
        right: true
        top: true
    }

    Rectangle {
        id: content

        width: parent.width
        height: parent.height

        color: KuromiM.bg0
        radius: 10

        y: root.opened ? 0 : -root.height

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic

                onRunningChanged: {
                    if (!running && !root.opened)
                        root.closing = false
                }
            }
        }

        Column {
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: [
                    "Power Off",
                    "Suspend",
                    "Reboot",
                    "Lock",
                    "Log Out"
                ]

                delegate: Rectangle {
                    required property string modelData

                    width: content.width
                    height: content.height / 5
                    radius: 10

                    color: hover.hovered
                        ? "#3C383E"
                        : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    HoverHandler {
                        id: hover
                    }

                    Text {
                        anchors.centerIn: parent

                        text: modelData
                        color: KuromiM.whiteRose

                        font.family: KuromiM.fontFamily
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.runAction(modelData)
                        }
                    }
                }
            }
        }
    }
}
