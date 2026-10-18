import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import "../Themes"

PanelWindow {
    id: root

    implicitWidth: 900
    implicitHeight: 200
    color: "transparent"
    exclusiveZone: 0

    

    property bool opened: false

    property string home: Quickshell.env("HOME")
    property string wallpaperDir: "file://" + home + "/Pictures/kuromi"
    property string thumbDir: "file://" + home + "/.cache/wallpaper-thumbs/"

    
    visible: opened || content.y > -content.height

    onOpenedChanged: if (opened) list.positionViewAtBeginning()

    
    onVisibleChanged: if (!visible) shuffle()

    HyprlandFocusGrab {
        windows: [root]
        active: root.opened
        onCleared: root.opened = false
    }

    function shuffle() {
        const items = []
        for (let i = 0; i < wallpaperPics.count; i++) {
            items.push({
                fileName: wallpaperPics.get(i, "fileName"),
                fileUrl: wallpaperPics.get(i, "fileUrl").toString()
            })
        }

        for (let i = items.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1))
            const tmp = items[i]
            items[i] = items[j]
            items[j] = tmp
        }

        shuffledPics.clear()
        for (const item of items)
            shuffledPics.append(item)
    }

    function setWallpaper(url) {
        // decodeURIComponent: nombres con espacios u otros caracteres llegan como %20, etc.
        const path = decodeURIComponent(url.toString().replace("file://", ""))

        wallpaperProcess.command = [
            "awww", "img", path,
            "--transition-type", "random",
            "--transition-fps", "60",
            "--transition-duration", "0.5"
        ]
        wallpaperProcess.running = true
    }

    Process {
        id: wallpaperProcess
        running: false
    }

    
    Process {
        id: thumbProcess
        command: ["bash", "-c", `
            mkdir -p "$HOME/.cache/wallpaper-thumbs"
            for f in "$HOME"/Pictures/kuromi/*.{png,jpg,jpeg,webp}; do
                [ -e "$f" ] || continue
                out="$HOME/.cache/wallpaper-thumbs/$(basename "$f").jpg"
                [ -e "$out" ] || vipsthumbnail "$f" -s 400 -o "$out[Q=85]"
            done
        `]
        onExited: root.shuffle()
    }

    FolderListModel {
        id: wallpaperPics

        folder: root.wallpaperDir
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        showFiles: true

        onStatusChanged: {
            if (status === FolderListModel.Ready)
                thumbProcess.running = true
        }
    }

    ListModel {
        id: shuffledPics
    }


    Timer {
        interval: 10 * 60 * 1000
        repeat: true
        running: true
        onTriggered: {
            if (shuffledPics.count === 0) return
            const i = Math.floor(Math.random() * shuffledPics.count)
            root.setWallpaper(shuffledPics.get(i).fileUrl)
        }
    }

    

    Rectangle {
        id: content
        width: parent.width
        height: parent.height
        color: KuromiM.bg0
        radius: 10

        y: root.opened ? 0 : -height

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Image {
            id: kuromiLeft
            source: "../assets/images/kuromiWall.jpg"   
            width: 110
            height: 110
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            anchors.verticalCenter:parent.verticalCenter
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 8
            anchors.bottomMargin: 8
        }
        
        Image {
            id: kuromiRight
            source: "../assets/images/kuromiWall2.jpg"
            width: 130
            height: 130
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            anchors.verticalCenter:parent.verticalCenter
        
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 8
            anchors.bottomMargin: 8
        }
        ListView {
            id: list

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: kuromiLeft.right
            anchors.right: kuromiRight.left
            anchors.margins: 8
            leftMargin: 12
            rightMargin: 12

            orientation: ListView.Horizontal
            spacing: 8
            clip: true

            model: shuffledPics

            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 2500
            maximumFlickVelocity: 1500
            cacheBuffer: 400
            reuseItems: true

            
            NumberAnimation {
                id: scrollAnim
                target: list
                property: "contentX"
                duration: 220
                easing.type: Easing.OutCubic
            }

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                    const min = list.originX - list.leftMargin
                    const max = list.originX + list.contentWidth - list.width + list.rightMargin
                    const from = scrollAnim.running ? scrollAnim.to : list.contentX

                    scrollAnim.stop()
                    scrollAnim.to = Math.max(min, Math.min(max, from - delta * 1.5))
                    scrollAnim.start()
                }
            }

            delegate: Item {
                id: card

                required property string fileName
                required property string fileUrl

                width: 200
                height: list.height
                z: mouse.containsMouse ? 1 : 0

              
                ClippingRectangle {
                    id: thumb

                    width: 200
                    height: 150
                    anchors.centerIn: parent
                    radius: 12
                    color: "#313244"
                    scale: mouse.containsMouse ? 1.08 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: root.thumbDir + encodeURIComponent(card.fileName) + ".jpg"
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        sourceSize.width: 400
                        sourceSize.height: 300
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setWallpaper(card.fileUrl)
                    }
                }
            }
        }
    }
}
