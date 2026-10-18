import QtQuick
import QtQuick.Shapes
import "../services"
import "../Themes"
Item {
    id: root

    property real value:Battery.battery_percent /100
    property bool charging: Battery.charging
    property real thickness: 3
    property color trackColor: "black"
    property color barColor: value > 0.7 ? KuromiM.rose1:value< 0.70 && value > 0.40  ?"#CA9EE6":"#E78284"
    property string label:root.charging ? Math.round(value * 100) + " 󱎗": Math.round(value * 100) + "%"

    implicitWidth: 35
    anchors.verticalCenter:parent.verticalCenter
    implicitHeight: 35

  
    property real shown: value
    Behavior on shown {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer   

      
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.trackColor
            strokeWidth: root.thickness

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width - root.thickness) / 2
                radiusY: (root.height - root.thickness) / 2
                startAngle: 0
                sweepAngle: 360
            }
        }

     
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.charging ?   "lime":root.barColor
            strokeWidth: root.thickness
            capStyle: ShapePath.RoundCap         

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: (root.width - root.thickness) / 2
                radiusY: (root.height - root.thickness) / 2
                startAngle: -90
                sweepAngle:root.charging ? 800 * root.shown:360 * root.shown
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: "#cdd6f4"
        font.bold: true
        font.pixelSize: root.width * 0.22
    }
}