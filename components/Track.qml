import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item{
    id:root

    Text {
            text: Hyprland.activeToplevel?.title ?? "Escritorio"
            color: "#89b4fa"
            font.pixelSize: 12
            elide: Text.ElideRight
            height:parent.height
            verticalAlignment:Text.AlignVCenter
            width:100
    }
}