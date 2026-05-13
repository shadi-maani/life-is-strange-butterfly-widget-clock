import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import QtQuick.Effects
import "components"

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
    property int flapDuration: Plasmoid.configuration.flapDuration || 180
    property int floatDuration: Plasmoid.configuration.floatDuration || 2800
    property int glowStrength: Plasmoid.configuration.glowStrength || 16
    property int flickerInterval: Plasmoid.configuration.flickerInterval || 5000
    property color topButterflyColor: Plasmoid.configuration.topButterflyColor || "#84cff9"
    property bool use24HourFormat: Plasmoid.configuration.use24HourFormat
    property bool showAMPM: Plasmoid.configuration.showAMPM


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
        property string ampmString: "AM"

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: visualRoot.updateTime()
        }

        Component.onCompleted: updateTime()

        // ─── Watch config changes and restart animations ───
        Connections {
            target: root
            function onFlapDurationChanged() {
                butterfly1.restartScale()
                butterfly2.restartScale()
            }
            function onFloatDurationChanged() {
                butterfly1.restartFloatAndRotation()
                butterfly2.restartFloatAndRotation()
                subtitleBar.restartFloat()
            }
            function onFlickerIntervalChanged() {
                subtitleBar.restartFlickerTimer()
            }
            function onUse24HourFormatChanged() {
                visualRoot.updateTime()
            }
            function onShowAMPMChanged() {
                visualRoot.updateTime()
            }
        }

        function updateTime() {
            var now = new Date()
            var h = now.getHours()
            var m = now.getMinutes()

            var displayH = h
            if (!root.use24HourFormat) {
                displayH = h % 12
                if (displayH === 0) displayH = 12
            }

            var ht = Math.floor(displayH / 10).toString()
            var ho = (displayH % 10).toString()
            var mt = Math.floor(m / 10).toString()
            var mo = (m % 10).toString()

            if (hourTens   !== ht) hourTens   = ht
            if (hourOnes   !== ho) hourOnes   = ho
            if (minuteTens !== mt) minuteTens = mt
            if (minuteOnes !== mo) minuteOnes = mo

            var ap = h >= 12 ? "PM" : "AM"
            if (ampmString !== ap) ampmString = ap
        }

        // ─── Digit-change reactions ───
        onMinuteOnesChanged: {
            if (!Plasmoid.configuration.lowPowerMode) {
                moGlitch.restart()
                butterfly1.react()
            }
        }
        onMinuteTensChanged: {
            if (!Plasmoid.configuration.lowPowerMode) mtGlitch.restart()
        }
        onHourOnesChanged: {
            if (!Plasmoid.configuration.lowPowerMode) {
                hoGlitch.restart()
                butterfly2.react()
            }
        }
        onHourTensChanged: {
            if (!Plasmoid.configuration.lowPowerMode) htGlitch.restart()
        }

        // ─── Glitch animations ───
        GlitchAnimation { id: moGlitch; targetItem: clockRow.moText }
        GlitchAnimation { id: mtGlitch; targetItem: clockRow.mtText }
        GlitchAnimation { id: hoGlitch; targetItem: clockRow.hoText }
        GlitchAnimation { id: htGlitch; targetItem: clockRow.htText }



        // ─────── CLOCK DIGITS ROW ───────
        ClockRow {
            id: clockRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -18

            hourTensText: visualRoot.hourTens
            hourOnesText: visualRoot.hourOnes
            minuteTensText: visualRoot.minuteTens
            minuteOnesText: visualRoot.minuteOnes
            ampmText: visualRoot.ampmString

            use24HourFormat: root.use24HourFormat
            showAMPM: root.showAMPM
            lowPowerMode: Plasmoid.configuration.lowPowerMode

            digitSize: visualRoot.digitSize
            digitBoxWidth: visualRoot.digitBoxWidth
            textColor: root.textColor
            neonColor: root.neonColor
            glowStrength: root.glowStrength
            fontName: sketchFont.name
        }

        // ─────── BUTTERFLY 1 — minutes ───────
        TopButterfly {
            id: butterfly1
            imageSource: "../../assets/butterfly1.png"
            size: 42
            topButterflyColor: root.topButterflyColor
            floatDuration: root.floatDuration
            floatTo: -14
            flapDuration: root.flapDuration
            flapScaleTo: 0.82
            x: clockRow.x + clockRow.moBox.x + clockRow.moBox.width * 0.3 - width * 0.5
            y: clockRow.y + clockRow.moBox.y - height * 0.55
            isVisible: Plasmoid.configuration.showTopButterflies
            lowPowerMode: Plasmoid.configuration.lowPowerMode
            z: 10
        }

        // ─────── BUTTERFLY 2 — hours ───────
        TopButterfly {
            id: butterfly2
            imageSource: "../../assets/butterfly2.png"
            size: 34
            topButterflyColor: root.topButterflyColor
            floatDuration: Math.max(100, root.floatDuration - 600)
            floatTo: -11
            flapDuration: Math.max(50, root.flapDuration - 20)
            flapScaleTo: 0.78
            rotDurationOffset: -200
            rotFrom: 5
            rotTo: -10
            flickerInterval: 2500
            flickerOpacities: [0.3, 1.0, 0.5, 1.0]
            flickerDurations: [45, 45, 40, 80]
            x: clockRow.x + clockRow.hoBox.x + clockRow.hoBox.width * 0.7
            y: clockRow.y + clockRow.hoBox.y - height * 0.45
            isVisible: Plasmoid.configuration.showTopButterflies
            lowPowerMode: Plasmoid.configuration.lowPowerMode
            z: 9
        }

        // ─────── SUBTITLE WITH BUTTERFLY ───────
        SubtitleBar {
            id: subtitleBar
            anchors.top: clockRow.bottom
            anchors.topMargin: -8
            anchors.horizontalCenter: parent.horizontalCenter
            subtitleText: Plasmoid.configuration.subtitleText
            subtitleColor: Plasmoid.configuration.subtitleColor
            neonColor: Plasmoid.configuration.neonColor
            glowStrength: Plasmoid.configuration.glowStrength
            floatDuration: Plasmoid.configuration.floatDuration
            flickerInterval: Plasmoid.configuration.flickerInterval
            fontName: duduFont.name
            isVisible: Plasmoid.configuration.showSubtitle
            lowPowerMode: Plasmoid.configuration.lowPowerMode
        }
    }
}
