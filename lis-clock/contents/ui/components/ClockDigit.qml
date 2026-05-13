import QtQuick
import QtQuick.Effects

Item {
    id: digitRoot

    property string digitText: "0"
    property int digitSize: 90
    property color textColor: "#ffffff"
    property color neonColor: "#00aaff"
    property int glowStrength: 16
    property string fontName: ""

    // Expose the Text item for animations
    property alias textItem: textElement

    Text {
        id: textElement
        text: digitRoot.digitText
        font.family: digitRoot.fontName
        font.pixelSize: digitRoot.digitSize
        font.bold: true
        color: digitRoot.textColor
        anchors.centerIn: parent
    }

    MultiEffect {
        source: textElement
        anchors.fill: textElement
        shadowEnabled: true
        shadowColor: digitRoot.neonColor
        shadowBlur: Math.min(1.0, digitRoot.glowStrength / 25.0)
        blurMax: 64
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        autoPaddingEnabled: true
    }
}
