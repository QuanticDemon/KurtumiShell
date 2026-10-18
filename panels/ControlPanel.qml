import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import "../Themes"

PanelWindow {
    id: root

    implicitWidth: 300
    implicitHeight: 480
    color: "transparent"
    exclusiveZone: 0

    anchors { left: true }

    property bool opened: false
    visible: opened || content.x > -content.width

    
    readonly property string iconFont: "JetBrainsMono Nerd Font"

    
    property real ramTotal: 0         
    property real ramUsed: 0          
    property real temp: 0             
    property var disks: ({})          
    property string osName: ""
    property string kernelName: ""
    readonly property string shellName: (Quickshell.env("SHELL") || "").split("/").pop()

    readonly property var partNames: ({ "/home": "Home", "/data": "Data", "/boot": "Boot" })
    readonly property var partColors: ({
        "/home": KuromiM.rose1,
        "/data": KuromiM.purple1,
        "/boot": KuromiM.purple2
    })

    function fmtBytes(b) {
        const units = ["B", "K", "M", "G", "T"]
        let i = 0
        let v = b
        while (v >= 1024 && i < units.length - 1) {
            v /= 1024
            i++
        }
        return v.toFixed(v < 10 && i > 0 ? 1 : 0) + units[i]
    }

    function memValue(text, key) {
        const m = text.match(new RegExp("^" + key + ":\\s+(\\d+)", "m"))
        return m ? Number(m[1]) : 0
    }

    
    function gauge(key) {
        if (key === "ram") {
            const f = ramTotal > 0 ? ramUsed / ramTotal : 0
            return {
                title: "RAM",
                sub: fmtBytes(ramUsed * 1024) + " / " + fmtBytes(ramTotal * 1024),
                center: Math.round(f * 100) + "%",
                fraction: f,
                color: KuromiM.purple1
            }
        }
        if (key === "temp") {
            return {
                title: "Temp",
                sub: "CPU",
                center: Math.round(temp) + "°C",
                fraction: Math.max(0, Math.min(temp / 100, 1)),
                color: temp > 60 ? KuromiM.rose1 : KuromiM.lilac
            }
        }
        const d = disks[key]
        const used = d && d.size > 0 ? d.used / d.size : 0
        return {
            title: partNames[key] || key,
            sub: d ? fmtBytes(d.used) + " / " + fmtBytes(d.size) : "—",
            center: d ? Math.round(used * 100) + "%" : "—",
            fraction: used,
            color: partColors[key] || KuromiM.purple1
        }
    }

    function refresh() {
        if (!sensorProc.running) sensorProc.running = true
        if (!diskProc.running) diskProc.running = true
        memFile.reload()
    }

    
    Timer {
        interval: 2000
        repeat: true
        running: root.visible
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    
    Process {
        id: sensorProc
        command: ["sh", "-c",
            "sensors | grep -E 'Package id 0|Tctl|Tdie' | head -n1 | grep -oE '[0-9]+(\\.[0-9]+)?°C' | head -n1 | sed 's/°C//'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(this.text)
                if (!isNaN(v)) root.temp = v
            }
        }
    }

    
    Process {
        id: diskProc
        command: ["sh", "-c",
            "for p in /home /data /boot; do df -B1 --output=size,used \"$p\" 2>/dev/null | awk -v p=\"$p\" 'NR==2 {print p, $1, $2}'; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = {}
                for (const line of this.text.trim().split("\n")) {
                    const p = line.trim().split(/\s+/)
                    if (p.length === 3) out[p[0]] = { size: Number(p[1]), used: Number(p[2]) }
                }
                root.disks = out
            }
        }
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: {
            const t = memFile.text()
            root.ramTotal = root.memValue(t, "MemTotal")
            root.ramUsed = root.ramTotal - root.memValue(t, "MemAvailable")
        }
    }

    FileView {
        id: osView
        path: "/etc/os-release"
        blockLoading: true
        onLoaded: {
            const m = osView.text().match(/^PRETTY_NAME="?([^"\n]*)"?/m)
            if (m) root.osName = m[1]
        }
    }

    FileView {
        id: kernelView
        path: "/proc/sys/kernel/osrelease"
        blockLoading: true
        onLoaded: root.kernelName = kernelView.text().trim()
    }

    
    Component {
        id: gaugeDelegate

        ColumnLayout {
            id: g

            required property var modelData

            readonly property var info: root.gauge(modelData)
            readonly property bool big: modelData === "ram" || modelData === "temp"
            readonly property real ringSize: big ? 100 : 80
            readonly property real thickness: big ? 7 : 6
            property real shown: info.fraction

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 6

            Behavior on shown {
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: g.ringSize
                Layout.preferredHeight: g.ringSize

                Shape {
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer

                    
                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: KuromiM.bg1
                        strokeWidth: g.thickness

                        PathAngleArc {
                            centerX: g.ringSize / 2
                            centerY: g.ringSize / 2
                            radiusX: (g.ringSize - g.thickness) / 2
                            radiusY: radiusX
                            startAngle: 0
                            sweepAngle: 360
                        }
                    }

                   
                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: g.shown > 0.003 ? g.info.color : "transparent"
                        strokeWidth: g.thickness
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: g.ringSize / 2
                            centerY: g.ringSize / 2
                            radiusX: (g.ringSize - g.thickness) / 2
                            radiusY: radiusX
                            startAngle: -90
                            sweepAngle: 360 * g.shown
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: g.info.center
                    color: KuromiM.whiteRose
                    font.family: KuromiM.fontFamily
                    font.pixelSize: g.big ? 28 : 22
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: g.info.title
                color: KuromiM.whiteRose
                font.family: KuromiM.fontFamily
                font.pixelSize: 18
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: g.info.sub
                visible: text !== ""
                color: KuromiM.whiteRose
                opacity: 0.6
                font.family: KuromiM.fontFamily
                font.pixelSize: 15
            }
        }
    }

    
    Rectangle {
        id: content

       
        width: root.width + radius
        height: root.height
        radius: 18
        color: KuromiM.bg0

        x: root.opened ? -radius : -width

        Behavior on x {
            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: content.radius + 14
            anchors.rightMargin: 14
            anchors.topMargin: 18
            anchors.bottomMargin: 18
            spacing: 18

            
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Image {
                    source:"../assets/images/logonirv.png"
                    Layout.preferredHeight:80
                    Layout.preferredWidth:90
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 3

                    Repeater {
                        model: [
                            { k: "Username", v: Quickshell.env("USER") },
                            { k: "OS",       v: root.osName },
                            { k: "Kernel",   v: root.kernelName },
                            { k: "Shell",    v: root.shellName }
                        ]

                        delegate: RowLayout {
                            required property var modelData

                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                Layout.preferredWidth: 72
                                text: modelData.k
                                color: KuromiM.rose1
                                font.family: KuromiM.fontFamily
                                font.pixelSize: 16
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.v
                                color: KuromiM.whiteRose
                                elide: Text.ElideRight
                                font.family: KuromiM.fontFamily
                                font.pixelSize: 16
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: KuromiM.purple1
                opacity: 0.35
            }

            
            RowLayout {
                Layout.fillWidth: true

                Repeater {
                    model: ["ram", "temp"]
                    delegate: gaugeDelegate
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: KuromiM.purple1
                opacity: 0.35
            }

            
            RowLayout {
                Layout.fillWidth: true

                Repeater {
                    model: ["/home", "/data", "/boot"]
                    delegate: gaugeDelegate
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}