
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import "../Themes"

PanelWindow {
    id: root

    property bool opened: false

    visible: opened
    color: "transparent"
    exclusiveZone: 0

    anchors {
        top: true
        right: true
    }

    margins {
        right: 100
    }

    implicitWidth: 360
    implicitHeight: opened ? 440 : 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: opened
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

   

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: KuromiM.bg0
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: "Bluetooth"
                        color: KuromiM.whiteRose
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 21
                    }

                    Text {
                        text: !Bluetooth.defaultAdapter
                            ? "Адаптер не знайдено"
                            : Bluetooth.defaultAdapter.enabled
                                ? "Доступні пристрої"
                                : "Bluetooth вимкнено"

                        color: KuromiM.whiteRose
                        opacity: 0.55
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 27
                    radius: 14

                    color: Bluetooth.defaultAdapter &&
                           Bluetooth.defaultAdapter.enabled
                        ? KuromiM.purple1
                        : KuromiM.bg1

                    opacity: Bluetooth.defaultAdapter ? 1 : 0.4

                    Rectangle {
                        width: 19
                        height: 19
                        radius: 10
                        y: 4

                        x: Bluetooth.defaultAdapter &&
                           Bluetooth.defaultAdapter.enabled
                            ? 23 : 4

                        color: KuromiM.whiteRose

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: Bluetooth.defaultAdapter !== null
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.enabled =
                                    !Bluetooth.defaultAdapter.enabled
                            }
                        }
                    }
                }

                Text {
                    text: "✕"
                    color: KuromiM.whiteRose
                    opacity: closeMouse.containsMouse ? 1 : 0.5
                    font.pixelSize: 19

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.opened = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: KuromiM.whiteRose
                opacity: 0.12
            }

            Text {
                Layout.fillWidth: true
                visible: !Bluetooth.defaultAdapter ||
                         !Bluetooth.defaultAdapter.enabled

                text: !Bluetooth.defaultAdapter
                    ? "Не знайдено Bluetooth-адаптер."
                    : "Увімкніть Bluetooth, щоб переглянути пристрої."

                color: KuromiM.whiteRose
                opacity: 0.55
                wrapMode: Text.WordWrap
                font.family: KuromiM.fontFamily
                font.pixelSize: 12
            }

            ListView {
                id: deviceList

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 7

                model: Bluetooth.defaultAdapter &&
                       Bluetooth.defaultAdapter.enabled
                    ? Bluetooth.defaultAdapter.devices
                    : null

                delegate: Rectangle {
                    id: deviceRow

                    required property var modelData
                    property var device: modelData

                    width: deviceList.width
                    height: 66
                    radius: 10

                    color: device.connected
                        ? KuromiM.bg1
                        : deviceMouse.containsMouse
                            ? "#292B40"
                            : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: "󰂯"
                            color: KuromiM.purple1
                            font.family: KuromiM.fontFamily
                            font.pixelSize: 23
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: device.name || device.deviceName
                                color: KuromiM.whiteRose
                                font.family: KuromiM.fontFamily
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            Text {
                                text: device.connected
                                    ? "Підключено"
                                    : device.pairing
                                        ? "Створення пари..."
                                        : device.paired
                                            ? "Збережений пристрій"
                                            : "Не підключено"

                                color: KuromiM.whiteRose
                                opacity: 0.5
                                font.family: KuromiM.fontFamily
                                font.pixelSize: 10
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 76
                            Layout.preferredHeight: 29
                            radius: 8

                            color: KuromiM.bg1
                            border.width: 1
                            border.color: KuromiM.purple1

                            Text {
                                anchors.centerIn: parent

                                text: device.connected
                                    ? "Від'єднати"
                                    : device.paired
                                        ? "З'єднати"
                                        : "Створити пару"

                                color: KuromiM.whiteRose
                                font.family: KuromiM.fontFamily
                                font.pixelSize: 9
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (device.connected) {
                                        device.disconnect()
                                    } else if (device.paired) {
                                        device.connect()
                                    } else if (!device.pairing) {
                                        device.pair()
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: deviceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        z: -1
                    }
                }

                Text {
                    anchors.centerIn: parent

                    visible: deviceList.count === 0 &&
                             Bluetooth.defaultAdapter &&
                             Bluetooth.defaultAdapter.enabled

                    width: parent.width - 20
                    text: "Немає пристроїв у списку."
                    color: KuromiM.whiteRose
                    opacity: 0.5
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.family: KuromiM.fontFamily
                    font.pixelSize: 12
                }
            }
        }
    }
}
