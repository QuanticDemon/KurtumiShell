
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Wayland
import "../Themes"

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    margins {
        top: 180
        right: 160
    }

    implicitWidth: 300
    implicitHeight: 280
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "pomodoro"
    exclusionMode: ExclusionMode.Ignore


    property int focusMinutes: 25
    property int shortBreakMinutes: 5
    property int longBreakMinutes: 15
    property int sessionsBeforeLong: 4

    
    property string phase: "focus"
    property int completed: 0
    property bool running: false
    property real endAt: 0
    property int remaining: focusMinutes * 60

    readonly property int total:
        phase === "focus" ? focusMinutes * 60
        : phase === "short" ? shortBreakMinutes * 60
        : longBreakMinutes * 60

    readonly property color accent:
        phase === "focus" ? "#CA9EE6"
        : phase === "short" ? "#94E2D5"
        : "#F5C2E7"

    readonly property string phaseLabel:
        phase === "focus" ? "Фокус"
        : phase === "short" ? "Перерва"
        : "Довга перерва"

    readonly property int cycleDone:
        phase === "long" ? sessionsBeforeLong
        : completed % sessionsBeforeLong

    
    function formatTime(s) {
        const m = Math.floor(s / 60)
        const sec = s % 60

        return String(m).padStart(2, "0")
             + ":"
             + String(sec).padStart(2, "0")
    }

    function setPhase(p) {
        running = false
        phase = p
        remaining = total
    }

    function toggleTimer() {
        if (running) {
            running = false
        } else {
            if (remaining <= 0)
                remaining = total

            endAt = Date.now() + remaining * 1000
            running = true
        }
    }

    function resetTimer() {
        running = false
        remaining = total
    }

    
    function skipPhase() {
        setPhase(phase === "focus" ? "short" : "focus")
    }

    function finishPhase() {
        if (phase === "focus") {
            completed++

            const isLong =
                completed % sessionsBeforeLong === 0

            sendNotice(
                isLong
                ? "Сесію завершено! Час для довгої перерви"
                : "Сесію завершено! Час відпочити"
            )

            setPhase(isLong ? "long" : "short")
        } else {
            sendNotice(
                "Перерву завершено! Час зосередитися!"
            )

            setPhase("focus")
        }
    }

    function sendNotice(msg) {
        notifier.command = [
            "notify-send",
            "-a", "Pomodoro",
            "Pomodoro",
            msg
        ]

        notifier.running = true
    }

    Process {
        id: notifier
    }

    Timer {
        interval: 250
        repeat: true
        running: root.running

        onTriggered: {
            root.remaining = Math.max(
                0,
                Math.ceil((root.endAt - Date.now()) / 1000)
            )

            if (root.remaining === 0)
                root.finishPhase()
        }
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: 10

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: "../assets/images/kurtCobain.jpg"
            asynchronous: true
            scale: 1.08

            layer.enabled: true

            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.25
                blurMax: 32
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.38)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // ── Перемикання фаз ────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { label: "Фокус", key: "focus" },
                        { label: "Перерва", key: "short" },
                        { label: "Довга", key: "long" }
                    ]

                    delegate: Rectangle {
                        id: chip

                        required property var modelData

                        readonly property bool active:
                            root.phase === chip.modelData.key

                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        radius: height / 2

                        color: active
                            ? Qt.rgba(1, 1, 1, 0.28)
                            : Qt.rgba(1, 1, 1, 0)

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: chip.modelData.label
                            color: "white"
                            opacity: chip.active ? 1 : 0.6
                            font.family: KuromiM.fontFamily
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.setPhase(
                                    chip.modelData.key
                                )
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            
            Item {
                id: ring

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 150
                Layout.preferredHeight: 150

                readonly property real stroke: 8

                property real progress:
                    root.total > 0
                    ? root.remaining / root.total
                    : 0

                Behavior on progress {
                    NumberAnimation {
                        duration: 900
                        easing.type: Easing.Linear
                    }
                }

                Shape {
                    anchors.fill: parent
                    layer.enabled: true
                    layer.samples: 4

                    // Фонове кільце
                    ShapePath {
                        strokeColor:
                            Qt.rgba(1, 1, 1, 0.2)

                        strokeWidth: ring.stroke
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: ring.width / 2
                            centerY: ring.height / 2

                            radiusX:
                                ring.width / 2 - ring.stroke

                            radiusY: radiusX

                            startAngle: -90
                            sweepAngle: 360
                        }
                    }

                    
                    ShapePath {
                        strokeColor:
                            ring.progress > 0.002
                            ? root.accent
                            : "transparent"

                        strokeWidth: ring.stroke
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: ring.width / 2
                            centerY: ring.height / 2

                            radiusX:
                                ring.width / 2 - ring.stroke

                            radiusY: radiusX

                            startAngle: -90
                            sweepAngle: 360 * ring.progress
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.phaseLabel
                        color: "white"
                        opacity: 0.7
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.formatTime(root.remaining)
                        color: "white"
                        font.family: KuromiM.fontFamily
                        font.pixelSize: 36
                        font.bold: true
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5

                        Repeater {
                            model: root.sessionsBeforeLong

                            delegate: Rectangle {
                                required property int index

                                width: 7
                                height: 7
                                radius: 3.5

                                color:
                                    index < root.cycleDone
                                    ? root.accent
                                    : Qt.rgba(1, 1, 1, 0.25)
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Repeater {
                    model: ["reset", "toggle", "skip"]

                    delegate: Rectangle {
                        id: btn

                        required property string modelData

                        readonly property bool primary:
                            modelData === "toggle"

                        implicitWidth: primary ? 100 : 74
                        implicitHeight: 36
                        radius: height / 2

                        color: primary
                            ? root.accent
                            : (ma.containsMouse
                               ? Qt.rgba(1, 1, 1, 0.28)
                               : Qt.rgba(1, 1, 1, 0.16))

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            text:
                                btn.modelData === "reset"
                                ? "Скинути"
                                : btn.modelData === "skip"
                                ? "Пропустити"
                                : (root.running
                                   ? "Пауза"
                                   : "Почати")

                            color: btn.primary
                                ? "#1E1C1F"
                                : "white"

                            font.family: KuromiM.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: ma

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (btn.modelData === "reset")
                                    root.resetTimer()
                                else if (btn.modelData === "skip")
                                    root.skipPhase()
                                else
                                    root.toggleTimer()
                            }
                        }
                    }
                }
            }
        }
    }
}
