import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property real flareLeft: 20     
    property real flareRight: 20    
    property real radiusLeft: 20    
    property real radiusRight: 20   
    property color fill: "black"
    default property alias content: body.data

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0.7, 0.1, 1, 1, 1]
    }
    Behavior on flareLeft   { Anim {} }
    Behavior on flareRight  { Anim {} }
    Behavior on radiusLeft  { Anim {} }
    Behavior on radiusRight { Anim {} }

    
    readonly property real fl: Math.min(flareLeft,  height / 2)
    readonly property real fr: Math.min(flareRight, height / 2)
    readonly property real rl: Math.max(0, Math.min(radiusLeft,  (width - fl - fr) / 2, height - fl))
    readonly property real rr: Math.max(0, Math.min(radiusRight, (width - fl - fr) / 2, height - fr))

    
    readonly property string outline: {
        const W = width, H = height
        let s = `L ${W} 0 `
        if (fr > 0) s += `A ${fr} ${fr} 0 0 0 ${W - fr} ${fr} `
        s += `L ${W - fr} ${H - rr} `
        if (rr > 0) s += `A ${rr} ${rr} 0 0 1 ${W - fr - rr} ${H} `
        s += `L ${fl + rl} ${H} `
        if (rl > 0) s += `A ${rl} ${rl} 0 0 1 ${fl} ${H - rl} `
        s += `L ${fl} ${fl} `
        if (fl > 0) s += `A ${fl} ${fl} 0 0 0 0 0 `
        return s + "Z"
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.fill
            strokeWidth: -1
            startX: 0; startY: 0
            PathSvg { path: root.outline }
        }
    }

    Item {
        id: body
        anchors.fill: parent
        anchors.leftMargin: root.fl
        anchors.rightMargin: root.fr
    }
}