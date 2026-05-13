import QtQuick
import QtQuick.Effects

Item {
    id: butterflyRoot

    property string imageSource: ""
    property int size: 42
    property color topButterflyColor: "#84cff9"
    property bool isVisible: true
    property bool lowPowerMode: false

    // Animation configs
    property int floatDuration: 2800
    property real floatTo: -14
    
    property int flapDuration: 180
    property real flapScaleTo: 0.82
    property int flapPause: 120
    
    property int rotDurationOffset: 400
    property real rotFrom: -6
    property real rotTo: 8
    
    property int flickerInterval: 1800
    property var flickerOpacities: [0.25, 1.0, 0.45, 1.0]
    property var flickerDurations: [45, 45, 40, 80]

    width: size
    height: size
    visible: isVisible

    // Inner container for Animator to avoid conflicting with external positioning constraints
    Item {
        id: visualContainer
        width: butterflyRoot.width
        height: butterflyRoot.height
        x: 0
        y: 0
        transformOrigin: Item.Center

        // Original image — shown when using default color
        Image {
            id: bImgOriginal
            source: butterflyRoot.imageSource
            sourceSize.width: butterflyRoot.size
            sourceSize.height: butterflyRoot.size
            anchors.fill: parent
            cache: true
            asynchronous: true
            visible: Qt.colorEqual(butterflyRoot.topButterflyColor, "#84cff9")
        }

        // Hidden source for MultiEffect
        Image {
            id: bImgForEffect
            source: butterflyRoot.imageSource
            sourceSize.width: butterflyRoot.size
            sourceSize.height: butterflyRoot.size
            anchors.fill: parent
            cache: true
            asynchronous: true
            visible: false
        }
        MultiEffect {
            source: bImgForEffect
            anchors.fill: bImgForEffect
            visible: !Qt.colorEqual(butterflyRoot.topButterflyColor, "#84cff9")
            colorization: 1.0
            colorizationColor: butterflyRoot.topButterflyColor
        }
    }

    // ─── Float ───
    SequentialAnimation {
        id: floatAnim
        loops: Animation.Infinite
        YAnimator { target: visualContainer; from: 0; to: butterflyRoot.floatTo; duration: Math.max(100, butterflyRoot.floatDuration); easing.type: Easing.InOutSine }
        YAnimator { target: visualContainer; from: butterflyRoot.floatTo; to: 0; duration: Math.max(100, butterflyRoot.floatDuration); easing.type: Easing.InOutSine }
    }

    // ─── Flap ───
    SequentialAnimation {
        id: scaleAnim
        loops: Animation.Infinite
        ScaleAnimator { target: visualContainer; from: 1.0; to: butterflyRoot.flapScaleTo; duration: Math.max(50, butterflyRoot.flapDuration); easing.type: Easing.InOutQuad }
        ScaleAnimator { target: visualContainer; from: butterflyRoot.flapScaleTo; to: 1.0; duration: Math.max(50, butterflyRoot.flapDuration); easing.type: Easing.InOutQuad }
        PauseAnimation { duration: butterflyRoot.flapPause }
    }

    // ─── Rotation ───
    SequentialAnimation {
        id: rotAnim
        loops: Animation.Infinite
        RotationAnimator { target: visualContainer; from: butterflyRoot.rotFrom; to: butterflyRoot.rotTo; duration: Math.max(100, butterflyRoot.floatDuration + butterflyRoot.rotDurationOffset); easing.type: Easing.InOutSine }
        RotationAnimator { target: visualContainer; from: butterflyRoot.rotTo; to: butterflyRoot.rotFrom; duration: Math.max(100, butterflyRoot.floatDuration + butterflyRoot.rotDurationOffset); easing.type: Easing.InOutSine }
    }

    // ─── Flicker ───
    Timer {
        id: flickerTimer
        interval: butterflyRoot.flickerInterval
        repeat: true
        onTriggered: flickerAnim.restart()
    }
    SequentialAnimation {
        id: flickerAnim
        OpacityAnimator { target: visualContainer; to: butterflyRoot.flickerOpacities[0]; duration: butterflyRoot.flickerDurations[0] }
        OpacityAnimator { target: visualContainer; to: butterflyRoot.flickerOpacities[1]; duration: butterflyRoot.flickerDurations[1] }
        OpacityAnimator { target: visualContainer; to: butterflyRoot.flickerOpacities[2]; duration: butterflyRoot.flickerDurations[2] }
        OpacityAnimator { target: visualContainer; to: butterflyRoot.flickerOpacities[3]; duration: butterflyRoot.flickerDurations[3] }
    }

    // ─── Reaction ───
    SequentialAnimation {
        id: reactAnim
        onStarted: scaleAnim.stop()
        onFinished: { if (!butterflyRoot.lowPowerMode) scaleAnim.restart() }
        ParallelAnimation {
            ScaleAnimator { target: visualContainer; to: 1.4; duration: 250; easing.type: Easing.OutBack }
            OpacityAnimator { target: visualContainer; to: 0.3; duration: 80 }
        }
        ParallelAnimation {
            ScaleAnimator { target: visualContainer; to: 1.0; duration: 500; easing.type: Easing.InOutCubic }
            OpacityAnimator { target: visualContainer; to: 1.0; duration: 250 }
        }
    }

    function react() {
        if (!butterflyRoot.lowPowerMode) reactAnim.restart()
    }

    function restartScale() {
        if (!butterflyRoot.lowPowerMode) scaleAnim.restart()
    }
    
    function restartFloatAndRotation() {
        if (!butterflyRoot.lowPowerMode) {
            floatAnim.restart()
            rotAnim.restart()
        }
    }

    onLowPowerModeChanged: {
        if (lowPowerMode) {
            floatAnim.stop()
            scaleAnim.stop()
            rotAnim.stop()
            flickerTimer.stop()
            flickerAnim.stop()
        } else {
            floatAnim.start()
            scaleAnim.start()
            rotAnim.start()
            flickerTimer.start()
        }
    }

    Component.onCompleted: {
        if (!lowPowerMode) {
            floatAnim.start()
            scaleAnim.start()
            rotAnim.start()
            flickerTimer.start()
        }
    }
}
