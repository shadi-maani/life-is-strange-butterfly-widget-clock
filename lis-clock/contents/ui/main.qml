import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import QtQuick.Effects

PlasmoidItem {
    id: root

    // Remove default plasma background
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    width: 340
    height: 220

    // ─── Configuration Properties ───
    property color neonColor: Plasmoid.configuration.neonColor
    property color textColor: Plasmoid.configuration.textColor
    property color subtitleColor: Plasmoid.configuration.subtitleColor
    property int flapDuration: Plasmoid.configuration.flapDuration
    property int floatDuration: Plasmoid.configuration.floatDuration


    // ─── Fonts ───
    FontLoader {
        id: sketchFont
        source: "../assets/CabinSketch-Bold.ttf"
    }
    FontLoader {
        id: duduFont
        source: "../assets/DuduCalligraphy.ttf"
    }

    // ═════════════════════════════════════
    //         FULL REPRESENTATION
    // ═════════════════════════════════════
    fullRepresentation: Item {
        id: visualRoot
        Layout.preferredWidth: 340
        Layout.preferredHeight: 220

        // ─── Design tokens ───
        readonly property int digitSize: 90
        readonly property int digitBoxWidth: 58

        // ─── Time variables ───
        property string hourTens: "0"
        property string hourOnes: "0"
        property string minuteTens: "0"
        property string minuteOnes: "0"

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: visualRoot.updateTime()
        }

        Component.onCompleted: updateTime()

        // ─── Watch config changes and restart animations ───
        Connections {
            target: root
            function onFlapDurationChanged() {
                b1ScaleAnim.restart()
                b2ScaleAnim.restart()
            }
            function onFloatDurationChanged() {
                b1FloatAnim.restart()
                b1RotAnim.restart()
                b2FloatAnim.restart()
                b2RotAnim.restart()
                b3FloatAnim.restart()
            }
        }

        function updateTime() {
            var now = new Date()
            var h = now.getHours()
            var m = now.getMinutes()

            // 12-hour format
            var h12 = h % 12
            if (h12 === 0) h12 = 12

            var ht = Math.floor(h12 / 10).toString()
            var ho = (h12 % 10).toString()
            var mt = Math.floor(m / 10).toString()
            var mo = (m % 10).toString()

            if (hourTens   !== ht) hourTens   = ht
            if (hourOnes   !== ho) hourOnes   = ho
            if (minuteTens !== mt) minuteTens = mt
            if (minuteOnes !== mo) minuteOnes = mo
        }

        // ─── Digit-change reactions ───
        onMinuteOnesChanged: {
            moGlitch.restart()
            b1React.restart()
        }
        onMinuteTensChanged: mtGlitch.restart()
        onHourOnesChanged: {
            hoGlitch.restart()
            b2React.restart()
        }
        onHourTensChanged: htGlitch.restart()

        // ─── Glitch animations ───
        SequentialAnimation {
            id: moGlitch
            NumberAnimation { target: moText; property: "opacity"; to: 0.1; duration: 50 }
            NumberAnimation { target: moText; property: "opacity"; to: 0.9; duration: 40 }
            NumberAnimation { target: moText; property: "opacity"; to: 0.15; duration: 45 }
            NumberAnimation { target: moText; property: "opacity"; to: 1.0; duration: 90 }
        }
        SequentialAnimation {
            id: mtGlitch
            NumberAnimation { target: mtText; property: "opacity"; to: 0.1; duration: 50 }
            NumberAnimation { target: mtText; property: "opacity"; to: 0.9; duration: 40 }
            NumberAnimation { target: mtText; property: "opacity"; to: 0.15; duration: 45 }
            NumberAnimation { target: mtText; property: "opacity"; to: 1.0; duration: 90 }
        }
        SequentialAnimation {
            id: hoGlitch
            NumberAnimation { target: hoText; property: "opacity"; to: 0.1; duration: 50 }
            NumberAnimation { target: hoText; property: "opacity"; to: 0.9; duration: 40 }
            NumberAnimation { target: hoText; property: "opacity"; to: 0.15; duration: 45 }
            NumberAnimation { target: hoText; property: "opacity"; to: 1.0; duration: 90 }
        }
        SequentialAnimation {
            id: htGlitch
            NumberAnimation { target: htText; property: "opacity"; to: 0.1; duration: 50 }
            NumberAnimation { target: htText; property: "opacity"; to: 0.9; duration: 40 }
            NumberAnimation { target: htText; property: "opacity"; to: 0.15; duration: 45 }
            NumberAnimation { target: htText; property: "opacity"; to: 1.0; duration: 90 }
        }

        // ─── Butterfly reaction to digit change ───
        SequentialAnimation {
            id: b1React
            ParallelAnimation {
                NumberAnimation { target: butterfly1; property: "scale"; to: 1.4; duration: 250; easing.type: Easing.OutBack }
                NumberAnimation { target: butterfly1; property: "opacity"; to: 0.3; duration: 80 }
            }
            ParallelAnimation {
                NumberAnimation { target: butterfly1; property: "scale"; to: 1.0; duration: 500; easing.type: Easing.InOutCubic }
                NumberAnimation { target: butterfly1; property: "opacity"; to: 1.0; duration: 250 }
            }
        }
        SequentialAnimation {
            id: b2React
            ParallelAnimation {
                NumberAnimation { target: butterfly2; property: "scale"; to: 1.4; duration: 250; easing.type: Easing.OutBack }
                NumberAnimation { target: butterfly2; property: "opacity"; to: 0.3; duration: 80 }
            }
            ParallelAnimation {
                NumberAnimation { target: butterfly2; property: "scale"; to: 1.0; duration: 500; easing.type: Easing.InOutCubic }
                NumberAnimation { target: butterfly2; property: "opacity"; to: 1.0; duration: 250 }
            }
        }

        // ─────── CLOCK DIGITS ROW ───────
        Row {
            id: clockRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -18
            spacing: 2

            // H-tens
            Item {
                id: htBox
                width: visualRoot.digitBoxWidth; height: visualRoot.digitSize
                Text {
                    id: htText
                    text: visualRoot.hourTens
                    font.family: sketchFont.name
                    font.pixelSize: visualRoot.digitSize
                    font.bold: true
                    color: root.textColor
                    anchors.centerIn: parent
                }
                MultiEffect {
                    source: htText; anchors.fill: htText
                    shadowEnabled: true; shadowColor: root.neonColor
                    shadowBlur: 1.0; blurMax: Plasmoid.configuration.glowStrength * 3
                    shadowHorizontalOffset: 0; shadowVerticalOffset: 0
                    autoPaddingEnabled: true
                }
            }

            // H-ones (b2 butterfly tracks this)
            Item {
                id: hoBox
                width: visualRoot.digitBoxWidth; height: visualRoot.digitSize
                Text {
                    id: hoText
                    text: visualRoot.hourOnes
                    font.family: sketchFont.name
                    font.pixelSize: visualRoot.digitSize
                    font.bold: true
                    color: root.textColor
                    anchors.centerIn: parent
                }
                MultiEffect {
                    source: hoText; anchors.fill: hoText
                    shadowEnabled: true; shadowColor: root.neonColor
                    shadowBlur: 1.0; blurMax: Plasmoid.configuration.glowStrength * 3
                    shadowHorizontalOffset: 0; shadowVerticalOffset: 0
                    autoPaddingEnabled: true
                }
            }

            // Colon
            Item {
                id: colonBox
                width: 24; height: visualRoot.digitSize
                Text {
                    id: colonText
                    text: ":"
                    font.family: sketchFont.name
                    font.pixelSize: visualRoot.digitSize
                    font.bold: true
                    color: root.textColor
                    anchors.centerIn: parent
                }
                MultiEffect {
                    source: colonText; anchors.fill: colonText
                    shadowEnabled: true; shadowColor: root.neonColor
                    shadowBlur: 1.0; blurMax: Plasmoid.configuration.glowStrength * 3
                    autoPaddingEnabled: true
                }
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                }
            }

            // M-tens
            Item {
                id: mtBox
                width: visualRoot.digitBoxWidth; height: visualRoot.digitSize
                Text {
                    id: mtText
                    text: visualRoot.minuteTens
                    font.family: sketchFont.name
                    font.pixelSize: visualRoot.digitSize
                    font.bold: true
                    color: root.textColor
                    anchors.centerIn: parent
                }
                MultiEffect {
                    source: mtText; anchors.fill: mtText
                    shadowEnabled: true; shadowColor: root.neonColor
                    shadowBlur: 1.0; blurMax: Plasmoid.configuration.glowStrength * 3
                    shadowHorizontalOffset: 0; shadowVerticalOffset: 0
                    autoPaddingEnabled: true
                }
            }

            // M-ones (b1 butterfly tracks this)
            Item {
                id: moBox
                width: visualRoot.digitBoxWidth; height: visualRoot.digitSize
                Text {
                    id: moText
                    text: visualRoot.minuteOnes
                    font.family: sketchFont.name
                    font.pixelSize: visualRoot.digitSize
                    font.bold: true
                    color: root.textColor
                    anchors.centerIn: parent
                }
                MultiEffect {
                    source: moText; anchors.fill: moText
                    shadowEnabled: true; shadowColor: root.neonColor
                    shadowBlur: 1.0; blurMax: Plasmoid.configuration.glowStrength * 3
                    shadowHorizontalOffset: 0; shadowVerticalOffset: 0
                    autoPaddingEnabled: true
                }
            }
        }

        // ─────── BUTTERFLY 1 — minutes ───────
        Image {
            id: butterfly1
            source: "../assets/butterfly1.png"
            width: 42; height: 42
            transformOrigin: Item.Center

            property real floatY: 0

            x: clockRow.x + moBox.x + moBox.width * 0.3 - width * 0.5
            y: clockRow.y + moBox.y - height * 0.55 + floatY

            SequentialAnimation on floatY {
                id: b1FloatAnim
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: -14; duration: Math.max(100, root.floatDuration); easing.type: Easing.InOutSine }
                NumberAnimation { from: -14; to: 0; duration: Math.max(100, root.floatDuration); easing.type: Easing.InOutSine }
            }

            SequentialAnimation on scale {
                id: b1ScaleAnim
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.82; duration: Math.max(50, root.flapDuration); easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.82; to: 1.0; duration: Math.max(50, root.flapDuration); easing.type: Easing.InOutQuad }
                PauseAnimation { duration: 120 }
            }

            SequentialAnimation on rotation {
                id: b1RotAnim
                loops: Animation.Infinite
                NumberAnimation { from: -6; to: 8; duration: Math.max(100, root.floatDuration + 400); easing.type: Easing.InOutSine }
                NumberAnimation { from: 8; to: -6; duration: Math.max(100, root.floatDuration + 400); easing.type: Easing.InOutSine }
            }

            Timer {
                interval: 1800
                running: true; repeat: true
                onTriggered: b1Flicker.restart()
            }
            SequentialAnimation {
                id: b1Flicker
                NumberAnimation { target: butterfly1; property: "opacity"; to: 0.25; duration: 45 }
                NumberAnimation { target: butterfly1; property: "opacity"; to: 1.0;  duration: 45 }
                NumberAnimation { target: butterfly1; property: "opacity"; to: 0.45; duration: 40 }
                NumberAnimation { target: butterfly1; property: "opacity"; to: 1.0;  duration: 80 }
            }
        }

        // ─────── BUTTERFLY 2 — hours ───────
        Image {
            id: butterfly2
            source: "../assets/butterfly2.png"
            width: 34; height: 34
            transformOrigin: Item.Center

            property real floatY: 0

            x: clockRow.x + hoBox.x + hoBox.width * 0.7
            y: clockRow.y + hoBox.y - height * 0.45 + floatY

            SequentialAnimation on floatY {
                id: b2FloatAnim
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: -11; duration: Math.max(100, root.floatDuration - 600); easing.type: Easing.InOutSine }
                NumberAnimation { from: -11; to: 0; duration: Math.max(100, root.floatDuration - 600); easing.type: Easing.InOutSine }
            }

            SequentialAnimation on scale {
                id: b2ScaleAnim
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.78; duration: Math.max(50, root.flapDuration - 20); easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.78; to: 1.0; duration: Math.max(50, root.flapDuration - 20); easing.type: Easing.InOutQuad }
                PauseAnimation { duration: 200 }
            }

            SequentialAnimation on rotation {
                id: b2RotAnim
                loops: Animation.Infinite
                NumberAnimation { from: 5; to: -10; duration: Math.max(100, root.floatDuration - 200); easing.type: Easing.InOutSine }
                NumberAnimation { from: -10; to: 5; duration: Math.max(100, root.floatDuration - 200); easing.type: Easing.InOutSine }
            }

            Timer {
                interval: 2500
                running: true; repeat: true
                onTriggered: b2Flicker.restart()
            }
            SequentialAnimation {
                id: b2Flicker
                NumberAnimation { target: butterfly2; property: "opacity"; to: 0.3; duration: 45 }
                NumberAnimation { target: butterfly2; property: "opacity"; to: 1.0; duration: 45 }
                NumberAnimation { target: butterfly2; property: "opacity"; to: 0.5; duration: 40 }
                NumberAnimation { target: butterfly2; property: "opacity"; to: 1.0; duration: 80 }
            }
        }

        // ─────── SUBTITLE WITH BUTTERFLY ───────
        Row {
            id: subtitleRow
            anchors.top: clockRow.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            visible: Plasmoid.configuration.showSubtitle

            Image {
                id: butterfly3
                source: "../assets/darkroombutterfly3.png"
                width: 18; height: 18
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.85

                SequentialAnimation on y {
                    id: b3FloatAnim
                    loops: Animation.Infinite
                    NumberAnimation { from: butterfly3.y; to: butterfly3.y - 4; duration: Math.max(100, root.floatDuration); easing.type: Easing.InOutSine }
                    NumberAnimation { from: butterfly3.y - 4; to: butterfly3.y; duration: Math.max(100, root.floatDuration); easing.type: Easing.InOutSine }
                }

                Timer {
                    interval: 3200
                    running: true; repeat: true
                    onTriggered: b3Flicker.restart()
                }
                SequentialAnimation {
                    id: b3Flicker
                    NumberAnimation { target: butterfly3; property: "opacity"; to: 0.3; duration: 50 }
                    NumberAnimation { target: butterfly3; property: "opacity"; to: 0.85; duration: 50 }
                    NumberAnimation { target: butterfly3; property: "opacity"; to: 0.5; duration: 60 }
                    NumberAnimation { target: butterfly3; property: "opacity"; to: 0.85; duration: 90 }
                }
            }

            Text {
                id: subText
                text: Plasmoid.configuration.subtitleText || "This action will have consequences..."
                font.family: duduFont.name
                font.pixelSize: 16
                color: root.subtitleColor
                opacity: 0.85
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MultiEffect {
            source: subtitleRow; anchors.fill: subtitleRow
            shadowEnabled: true; shadowColor: root.neonColor
            shadowBlur: 0.7; blurMax: Plasmoid.configuration.glowStrength
            autoPaddingEnabled: true
            visible: subtitleRow.visible
        }
    }
}
