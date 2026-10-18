
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import "../Themes"

PanelWindow {
    id: root

    property bool opened: false
    property bool openDN: false
    property bool adding: false
    property var tasks: []

    readonly property var pendingTasks: root.tasks.filter(t => !t.completed)
    readonly property var doneTasks: root.tasks.filter(t => t.completed)

    readonly property string tasksPath: Quickshell.env("HOME") + "/.local/share/kuromi-tasks.json"

    visible: opened
    WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusiveZone: 0
    color: "transparent"

    implicitHeight: 450
    implicitWidth: openDN ? 600 : 300

    onOpenedChanged: if (!opened) adding = false

    function goInside() {
        openDN = true
        stack.replace(inside)
    }

    function goHome() {
        adding = false
        openDN = false
        stack.replace(home)
    }

    function saveTasks() {
        tasksFile.setText(JSON.stringify(root.tasks, null, 2))
    }

    function addTask(title) {
        const name = title.trim()
        if (name.length === 0) return

        root.tasks = root.tasks.concat([{ id: Date.now(), title: name, completed: false }])
        saveTasks()
    }

    function toggleTask(id) {
        root.tasks = root.tasks.map(t =>
            t.id === id ? { id: t.id, title: t.title, completed: !t.completed } : t)
        saveTasks()
    }

    function removeTask(id) {
        root.tasks = root.tasks.filter(t => t.id !== id)
        saveTasks()
    }

    FileView {
        id: tasksFile
        path: root.tasksPath
        blockLoading: true

        onLoaded: {
            try {
                const data = JSON.parse(text())
                if (Array.isArray(data)) root.tasks = data
            } catch (e) {
                console.warn("Завдання: некоректний JSON", e)
            }
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.opened
        onCleared: root.opened = false
    }

    Rectangle {
        anchors.fill: parent
        color: KuromiM.bg0
        radius: 15
        clip: true

        StackView {
            id: stack
            anchors.fill: parent

            initialItem: root.openDN ? inside : home

            pushEnter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            }
            pushExit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutCubic }
            }
            replaceEnter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
            }
            replaceExit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutCubic }
            }
        }

        Component {
            id: home

            Item {
                Image {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: 400
                    source: "../assets/images/dn.png"
                    fillMode: Image.PreserveAspectCrop
                }

                Button {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Увійти"
                    onClicked: root.goInside()

                    background:Rectangle{
                        color:KuromiM.bg1
                    }

                   
                }
            }
        }

        Component {
            id: inside

            Item {
                anchors.fill: parent

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Rectangle {
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: backText.implicitWidth + 28
                            radius: height / 2
                            color: backMouse.containsMouse ? KuromiM.purple1 : KuromiM.bg1

                            Text {
                                id: backText
                                anchors.centerIn: parent
                                text: "‹  На головну"
                                color: backMouse.containsMouse ? KuromiM.bg0 : KuromiM.whiteRose
                                font.family: KuromiM.fontFamily
                                font.pixelSize: 16
                            }

                            MouseArea {
                                id: backMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.goHome()
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        Repeater {
                            model: [
                                { title: "У процесі", done: false },
                                { title: "Виконані", done: true }
                            ]

                            delegate: Rectangle {
                                id: column

                                required property var modelData

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredWidth: 1
                                radius: 12
                                color: "#DADDD7"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            Layout.fillWidth: true
                                            text: column.modelData.title === "" ? "" : column.modelData.title + " · " + taskList.count
                                            color: KuromiM.bg1
                                            font.family: KuromiM.fontFamily
                                            font.pixelSize: 20
                                        }

                                        Rectangle {
                                            visible: !column.modelData.done
                                            Layout.preferredWidth: 28
                                            Layout.preferredHeight: 28
                                            radius: 14
                                            color: addMouse.containsMouse ? KuromiM.purple1 : "#E1E9E8"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "＋"
                                                color: KuromiM.bg0
                                                font.pixelSize: 18
                                            }

                                            MouseArea {
                                                id: addMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.adding = !root.adding
                                            }
                                        }
                                    }

                                    TextField {
                                        id: taskInput

                                        visible: root.adding && !column.modelData.done
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34

                                        placeholderText: "Яке завдання потрібно виконати?"
                                        placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                                        color: KuromiM.whiteRose
                                        font.family: KuromiM.fontFamily
                                        font.pixelSize: 15
                                        leftPadding: 10

                                        background: Rectangle {
                                            radius: 8
                                            color: KuromiM.bg0
                                            border.width: 1
                                            border.color: KuromiM.purple1
                                        }

                                        onVisibleChanged: if (visible) {
                                            text = ""
                                            forceActiveFocus()
                                        }

                                        onAccepted: {
                                            root.addTask(text)
                                            root.adding = false
                                        }

                                        Keys.onEscapePressed: root.adding = false
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        ListView {
                                            id: taskList

                                            anchors.fill: parent
                                            clip: true
                                            spacing: 6

                                            model: column.modelData.done ? root.doneTasks : root.pendingTasks

                                            delegate: Rectangle {
                                                id: card

                                                required property var modelData

                                                width: ListView.view.width
                                                height: 38
                                                radius: 8
                                                color: "transparent"
                                                

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 10
                                                    anchors.rightMargin: 8
                                                    spacing: 8

                                                    Rectangle {
                                                        Layout.preferredWidth: 18
                                                        Layout.preferredHeight: 18
                                                        radius: 9
                                                        color: card.modelData.completed ? KuromiM.bg1 : "transparent"
                                                        border.width: 2
                                                        border.color: KuromiM.bg1

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: root.toggleTask(card.modelData.id)
                                                        }
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: card.modelData.title
                                                        elide: Text.ElideRight
                                                        color: KuromiM.bg1
                                                        opacity: card.modelData.completed ? 0.5 : 1
                                                        font.strikeout: card.modelData.completed
                                                        font.family: KuromiM.fontFamily
                                                        font.pixelSize: 16
                                                    }

                                                    Text {
                                                        text: "✕"
                                                        color: removeMouse.containsMouse ? KuromiM.rose1 : KuromiM.whiteRose
                                                        opacity: removeMouse.containsMouse ? 1 : 0.5

                                                        MouseArea {
                                                            id: removeMouse
                                                            anchors.fill: parent
                                                            anchors.margins: -6
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: root.removeTask(card.modelData.id)
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: taskList.count === 0
                                            text: column.modelData.done ? "Поки що немає виконаних завдань" : "Немає невиконаних завдань"
                                            color: KuromiM.bg1
                                            opacity: 0.4
                                            font.family: KuromiM.fontFamily
                                            font.pixelSize: 14
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
