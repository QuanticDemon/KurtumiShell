
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Wayland
import "../Themes"

PanelWindow {
    id: root

    property bool opened: false
    property var selectedNetwork: null
    property string password: ""
    property string statusMessage: ""
    property bool connecting: false

    visible: opened
    color: "transparent"
    exclusiveZone: 0

    anchors {
        top: true
        right: true
    }

    margins {
        right: 150
    }

    implicitHeight: opened ? 440 : 0
    implicitWidth: 500

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: opened
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

  

    function connectToNetwork(network) {
        statusMessage = ""

        if (network.connected)
            return

        if (network.known ||
            network.security === WifiSecurityType.Open) {
            network.connect()
            statusMessage = "Підключення до " + network.name + "..."
            return
        }

        if (network.security === WifiSecurityType.WpaPsk ||
            network.security === WifiSecurityType.Wpa2Psk ||
            network.security === WifiSecurityType.Sae) {
            selectedNetwork = network
            password = ""
            passwordDialog.open()
            return
        }

        statusMessage = "Ця мережа потребує додаткових налаштувань."
    }

    Rectangle {
        anchors.fill: parent
        color: KuromiM.bg0
        radius: 16
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Wi-Fi"
                        color: KuromiM.whiteRose
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 22
                    }

                    Text {
                        text: Networking.wifiEnabled
                            ? "Доступні мережі"
                            : "Wi-Fi вимкнено"
                        color: KuromiM.whiteRose
                        opacity: 0.55
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 12
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 28
                    radius: 14

                    color: Networking.wifiEnabled
                        ? KuromiM.purple1
                        : KuromiM.bg1

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        y: 4
                        x: Networking.wifiEnabled ? 24 : 4
                        color: KuromiM.whiteRose

                        Behavior on x {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Networking.wifiEnabled =
                                !Networking.wifiEnabled
                        }
                    }
                }

                Text {
                    text: "✕"
                    color: KuromiM.whiteRose
                    opacity: closeMouse.containsMouse ? 1 : 0.5
                    font.pixelSize: 20

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        anchors.margins: -8
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

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentHeight: networkColumn.implicitHeight

                ColumnLayout {
                    id: networkColumn
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: Networking.devices

                        delegate: ColumnLayout {
                            required property var modelData
                            property var device: modelData

                            Layout.fillWidth: true
                            visible: device.type === DeviceType.Wifi
                            spacing: 8

                            Component.onCompleted: {
                                if (device.type === DeviceType.Wifi)
                                    device.scannerEnabled = true
                            }

                            Repeater {
                                model: device.networks

                                delegate: Rectangle {
                                    required property var modelData
                                    property var network: modelData

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 58
                                    radius: 10

                                    color: network.connected
                                        ? KuromiM.bg1
                                        : rowMouse.containsMouse
                                            ? "#292B40"
                                            : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        spacing: 12

                                        Text {
                                            text: "◉"
                                            color: KuromiM.purple1
                                            font.pixelSize: 22
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 3

                                            Text {
                                                Layout.fillWidth: true
                                                text: network.name
                                                color: KuromiM.whiteRose
                                                elide: Text.ElideRight
                                                font.family: KuromiM.fontFamily
                                                font.pixelSize: 14
                                            }

                                            Text {
                                                text: network.connected
                                                    ? "Підключено"
                                                    : Math.round(
                                                        network.signalStrength * 100
                                                    ) + "% · " +
                                                    (network.known
                                                        ? "Збережена"
                                                        : network.security === WifiSecurityType.Open
                                                            ? "Відкрита"
                                                            : "Захищена")

                                                color: KuromiM.whiteRose
                                                opacity: 0.5
                                                font.pixelSize: 11
                                            }
                                        }

                                        Text {
                                            text: network.connected
                                                ? "✓"
                                                : network.known
                                                    ? "↻"
                                                    : "›"
                                            color: KuromiM.purple1
                                            font.pixelSize: 20
                                        }
                                    }

                                    MouseArea {
                                        id: rowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            root.connectToNetwork(network)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: !Networking.wifiEnabled
                        text: "Увімкніть Wi-Fi, щоб побачити мережі."
                        color: KuromiM.whiteRose
                        opacity: 0.55
                        wrapMode: Text.WordWrap
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: statusMessage.length > 0
                        text: statusMessage
                        color: KuromiM.purple1
                        wrapMode: Text.WordWrap
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    Popup {
        id: passwordDialog

        parent: root
        anchors.centerIn: parent

        width: 360
        padding: 20

        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose

        onOpened: passwordInput.forceActiveFocus()

        background: Rectangle {
            color: KuromiM.bg0
            radius: 16
            border.width: 1
            border.color: KuromiM.purple1
        }

        contentItem: ColumnLayout {
            spacing: 12

            Text {
                Layout.fillWidth: true

                text: root.selectedNetwork
                    ? "Пароль для " + root.selectedNetwork.name
                    : ""

                color: KuromiM.whiteRose
                font.family: KuromiM.fontFamily
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            TextField {
                id: passwordInput

                Layout.fillWidth: true
                placeholderText: "Введіть пароль..."
                echoMode: TextInput.Password
                color: KuromiM.whiteRose
                placeholderTextColor: "#77798D"
                font.family: KuromiM.fontFamily

                onTextChanged: root.password = text
                onAccepted: submitPassword()

                background: Rectangle {
                    color: KuromiM.bg1
                    radius: 8
                    border.width: 1
                    border.color: KuromiM.purple1
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.statusMessage.length > 0
                text: root.statusMessage
                color: KuromiM.purple1
                wrapMode: Text.WordWrap
                font.family: KuromiM.fontFamily
                font.pixelSize: 12
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Скасувати"

                    onClicked: {
                        passwordDialog.close()
                        root.password = ""
                        root.selectedNetwork = null
                        root.connecting = false
                        root.statusMessage = ""
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: root.connecting
                        ? "Підключення..."
                        : "Підключити"

                    enabled: !root.connecting

                    onClicked: submitPassword()
                }
            }
        }
    }

    function submitPassword() {
        if (!selectedNetwork || password.length === 0 || connecting)
            return

        connecting = true
        statusMessage = "Спроба підключення..."

        selectedNetwork.connectWithPsk(password)
    }

    Connections {
        target: root.selectedNetwork

        function onConnectedChanged() {
            if (root.selectedNetwork && root.selectedNetwork.connected) {
                root.connecting = false
                root.statusMessage = "Підключено"
                passwordDialog.close()
                root.password = ""
                root.selectedNetwork = null
            }
        }

        function onConnectionFailed(reason) {
            root.connecting = false
            root.statusMessage = "Не вдалося підключитися. Перевірте пароль."
        }
    }
}
