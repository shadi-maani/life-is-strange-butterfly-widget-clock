import QtQuick
import QtQuick.Effects

Row {
    id: clockRowRoot

    property string hourTensText: "0"
    property string hourOnesText: "0"
    property string minuteTensText: "0"
    property string minuteOnesText: "0"
    property string ampmText: "AM"
    
    property bool use24HourFormat: false
    property bool showAMPM: false
    property bool lowPowerMode: false

    property int digitSize: 90
    property int digitBoxWidth: 58
    property color textColor: "#ffffff"
    property color neonColor: "#00aaff"
    property int glowStrength: 16
    property string fontName: ""

    // Expose aliases so parent can position butterflies and trigger glitches
    property alias htBox: htDigit
    property alias hoBox: hoDigit
    property alias mtBox: mtDigit
    property alias moBox: moDigit

    property alias htText: htDigit.textItem
    property alias hoText: hoDigit.textItem
    property alias mtText: mtDigit.textItem
    property alias moText: moDigit.textItem

    spacing: 2

    // H-tens
    ClockDigit {
        id: htDigit
        width: clockRowRoot.digitBoxWidth
        height: clockRowRoot.digitSize
        digitText: clockRowRoot.hourTensText
        digitSize: clockRowRoot.digitSize
        textColor: clockRowRoot.textColor
        neonColor: clockRowRoot.neonColor
        glowStrength: clockRowRoot.glowStrength
        fontName: clockRowRoot.fontName
    }

    // H-ones (b2 tracks this)
    ClockDigit {
        id: hoDigit
        width: clockRowRoot.digitBoxWidth
        height: clockRowRoot.digitSize
        digitText: clockRowRoot.hourOnesText
        digitSize: clockRowRoot.digitSize
        textColor: clockRowRoot.textColor
        neonColor: clockRowRoot.neonColor
        glowStrength: clockRowRoot.glowStrength
        fontName: clockRowRoot.fontName
    }

    // Colon
    Item {
        id: colonBox
        width: 24; height: clockRowRoot.digitSize
        Text {
            id: colonTextElement
            text: ":"
            font.family: clockRowRoot.fontName
            font.pixelSize: clockRowRoot.digitSize
            font.bold: true
            color: clockRowRoot.textColor
            anchors.centerIn: parent
        }
        MultiEffect {
            source: colonTextElement; anchors.fill: colonTextElement
            shadowEnabled: true; shadowColor: clockRowRoot.neonColor
            shadowBlur: Math.min(1.0, clockRowRoot.glowStrength / 25.0)
            blurMax: 32
            autoPaddingEnabled: true
        }
        SequentialAnimation {
            id: colonAnim
            loops: Animation.Infinite
            OpacityAnimator { target: colonBox; to: 0.3; duration: 600; easing.type: Easing.InOutSine }
            OpacityAnimator { target: colonBox; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
        }
    }

    onLowPowerModeChanged: {
        if (lowPowerMode) {
            colonAnim.stop()
        } else {
            colonAnim.start()
        }
    }

    Component.onCompleted: {
        if (!lowPowerMode) {
            colonAnim.start()
        }
    }

    // M-tens
    ClockDigit {
        id: mtDigit
        width: clockRowRoot.digitBoxWidth
        height: clockRowRoot.digitSize
        digitText: clockRowRoot.minuteTensText
        digitSize: clockRowRoot.digitSize
        textColor: clockRowRoot.textColor
        neonColor: clockRowRoot.neonColor
        glowStrength: clockRowRoot.glowStrength
        fontName: clockRowRoot.fontName
    }

    // M-ones (b1 tracks this)
    ClockDigit {
        id: moDigit
        width: clockRowRoot.digitBoxWidth
        height: clockRowRoot.digitSize
        digitText: clockRowRoot.minuteOnesText
        digitSize: clockRowRoot.digitSize
        textColor: clockRowRoot.textColor
        neonColor: clockRowRoot.neonColor
        glowStrength: clockRowRoot.glowStrength
        fontName: clockRowRoot.fontName
    }

    // AM/PM Indicator
    Item {
        id: ampmBox
        width: clockRowRoot.digitBoxWidth * 0.9; height: clockRowRoot.digitSize
        visible: !clockRowRoot.use24HourFormat && clockRowRoot.showAMPM
        Text {
            id: ampmTextElement
            text: clockRowRoot.ampmText
            font.family: clockRowRoot.fontName
            font.pixelSize: clockRowRoot.digitSize * 0.35
            font.bold: true
            color: clockRowRoot.textColor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: clockRowRoot.digitSize * 0.15
            anchors.left: parent.left
            anchors.leftMargin: 4
        }
        MultiEffect {
            source: ampmTextElement; anchors.fill: ampmTextElement
            shadowEnabled: true; shadowColor: clockRowRoot.neonColor
            shadowBlur: Math.min(1.0, clockRowRoot.glowStrength / 25.0)
            blurMax: 32
            autoPaddingEnabled: true
        }
    }
}
