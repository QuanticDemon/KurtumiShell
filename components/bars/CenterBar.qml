import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import "../../Themes"
import "../../components"

Item {
    id: root

   
    property real bodyWidth: hover.hovered ? 330 : 300
    property real bodyHeight: parent.height
    property real radius:hover.hovered ? 28 : 20    
    property real flare: 20      
    property color fill: KuromiM.bg0

    
    readonly property real f: Math.min(flare, bodyHeight / 2)
    readonly property real r: Math.max(0, Math.min(radius, bodyWidth / 2, bodyHeight - flare))

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    width: bodyWidth + f * 2
    height: bodyHeight

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0.7, 0.1, 1, 1, 1]  
    }

    HoverHandler { id: hover }
    
    
    
    Behavior on bodyWidth  { Anim {} }
    Behavior on bodyHeight { Anim {} }
    Behavior on radius     { Anim {} }
    Behavior on flare      { Anim {} }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer   // Qt 6.6+, bordes suaves

        ShapePath {
            fillColor: root.fill
            strokeWidth: -1

            startX: 0; startY: 0

            // borde superior
            PathLine { x: root.width; y: 0 }

            // unión cóncava derecha
            PathArc {
                x: root.width - root.f; y: root.f
                radiusX: root.f; radiusY: root.f
                direction: PathArc.Counterclockwise
            }

            // lado derecho
            PathLine { x: root.width - root.f; y: root.height - root.r }

            // esquina inferior derecha (convexa)
            PathArc {
                x: root.width - root.f - root.r; y: root.height
                radiusX: root.r; radiusY: root.r
                direction: PathArc.Clockwise
            }

            // base
            PathLine { x: root.f + root.r; y: root.height }

            // esquina inferior izquierda (convexa)
            PathArc {
                x: root.f; y: root.height - root.r
                radiusX: root.r; radiusY: root.r
                direction: PathArc.Clockwise
            }

            // lado izquierdo
            PathLine { x: root.f; y: root.f }

            // unión cóncava izquierda
            PathArc {
                x: 0; y: 0
                radiusX: root.f; radiusY: root.f
                direction: PathArc.Counterclockwise
            }
        }
    }

    RowLayout{
        anchors.fill:parent

       
        Row {
            Layout.alignment:Qt.AlignCenter
            Clock {}
        }
    }
    
}