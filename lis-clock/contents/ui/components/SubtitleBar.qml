import QtQuick
import QtQuick.Effects

Item {
    id: subtitleRoot
    
    property string subtitleText: "This action will have consequences..."
    property color subtitleColor: "#dff2ff"
    property color neonColor: "#00aaff"
    property int glowStrength: 16
    property int floatDuration: 2800
    property int flickerInterval: 5000
    property string fontName: ""
    property bool isVisible: true
    property bool lowPowerMode: false
    
    visible: isVisible

    implicitWidth: subtitleRow.width
    implicitHeight: subtitleRow.height

    Row {
        id: subtitleRow
        anchors.centerIn: parent
        spacing: 16

        Item {
            id: b3Container
            width: 22; height: 22
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: butterfly3
                source: "../../assets/darkroombutterfly3.png"
                width: 22; height: 22
                sourceSize.width: 22
                sourceSize.height: 22
                cache: true
                asynchronous: true
                x: 0; y: 0
            }

            SequentialAnimation {
                id: b3FloatAnim
                loops: Animation.Infinite
                YAnimator { target: butterfly3; from: 0; to: -6; duration: Math.max(100, subtitleRoot.floatDuration); easing.type: Easing.InOutSine }
                YAnimator { target: butterfly3; from: -6; to: 0; duration: Math.max(100, subtitleRoot.floatDuration); easing.type: Easing.InOutSine }
            }

            Timer {
                id: b3FlickerTimer
                interval: Math.max(1000, subtitleRoot.flickerInterval)
                repeat: true
                onTriggered: b3Flicker.restart()
            }
            SequentialAnimation {
                id: b3Flicker
                OpacityAnimator { target: butterfly3; to: 0.15; duration: 60 }
                OpacityAnimator { target: butterfly3; to: 0.9;  duration: 60 }
                OpacityAnimator { target: butterfly3; to: 0.35; duration: 70 }
                OpacityAnimator { target: butterfly3; to: 0.9;  duration: 100 }
            }
        }

        Text {
            id: subText
            text: subtitleRoot.subtitleText
            font.family: subtitleRoot.fontName
            font.pixelSize: 16
            color: subtitleRoot.subtitleColor
            opacity: 0.85
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    MultiEffect {
        source: subtitleRow; anchors.fill: subtitleRow
        shadowEnabled: true; shadowColor: subtitleRoot.neonColor
        shadowBlur: Math.min(1.0, subtitleRoot.glowStrength / 25.0)
        blurMax: 32
        autoPaddingEnabled: true
    }

    function restartFloat() {
        if (!subtitleRoot.lowPowerMode) b3FloatAnim.restart()
    }
    
    function restartFlickerTimer() {
        if (!subtitleRoot.lowPowerMode) b3FlickerTimer.restart()
    }

    onLowPowerModeChanged: {
        if (lowPowerMode) {
            b3FloatAnim.stop()
            b3FlickerTimer.stop()
            b3Flicker.stop()
        } else {
            b3FloatAnim.start()
            b3FlickerTimer.start()
        }
    }

    Component.onCompleted: {
        if (!lowPowerMode) {
            b3FloatAnim.start()
            b3FlickerTimer.start()
        }
    }
}
