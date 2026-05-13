import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kquickcontrols as KQC
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configPage

    // ─── Current values (bound by Plasma) ───
    property alias cfg_neonColor: neonColorPicker.color
    property alias cfg_textColor: textColorPicker.color
    property alias cfg_subtitleColor: subtitleColorPicker.color
    property alias cfg_topButterflyColor: topButterflyColorPicker.color
    property alias cfg_flapDuration: flapSpinBox.value
    property alias cfg_floatDuration: floatSpinBox.value
    property alias cfg_showSubtitle: showSubtitleCheckbox.checked
    property alias cfg_subtitleText: subtitleTextField.text
    property alias cfg_glowStrength: glowSpinBox.value
    property alias cfg_flickerInterval: flickerSpinBox.value
    property alias cfg_use24HourFormat: use24HourCheckbox.checked
    property alias cfg_showAMPM: showAMPMCheckbox.checked
    property alias cfg_showTopButterflies: showTopButterfliesCheckbox.checked
    property alias cfg_lowPowerMode: lowPowerModeCheckbox.checked

    // ─── Default values (required by Plasma 6) ───
    property color cfg_neonColorDefault: "#00aaff"
    property color cfg_textColorDefault: "#dff2ff"
    property color cfg_subtitleColorDefault: "#dff2ff"
    property color cfg_topButterflyColorDefault: "#84cff9"
    property int cfg_flapDurationDefault: 180
    property int cfg_floatDurationDefault: 2800
    property bool cfg_showSubtitleDefault: true
    property string cfg_subtitleTextDefault: "This action will have consequences..."
    property int cfg_glowStrengthDefault: 16
    property int cfg_flickerIntervalDefault: 5000
    property bool cfg_use24HourFormatDefault: false
    property bool cfg_showAMPMDefault: false
    property bool cfg_showTopButterfliesDefault: true
    property bool cfg_lowPowerModeDefault: false

    Kirigami.FormLayout {

        KQC.ColorButton {
            id: neonColorPicker
            Kirigami.FormData.label: i18n("Neon Glow Color:")
        }

        KQC.ColorButton {
            id: textColorPicker
            Kirigami.FormData.label: i18n("Clock Text Color:")
        }

        KQC.ColorButton {
            id: subtitleColorPicker
            Kirigami.FormData.label: i18n("Subtitle Text Color:")
        }

        KQC.ColorButton {
            id: topButterflyColorPicker
            Kirigami.FormData.label: i18n("Top Butterflies Color:")
        }

        QQC2.SpinBox {
            id: flapSpinBox
            from: 50
            to: 1000
            stepSize: 10
            Kirigami.FormData.label: i18n("Wing Flap Speed (ms):")
        }

        QQC2.SpinBox {
            id: floatSpinBox
            from: 500
            to: 10000
            stepSize: 100
            Kirigami.FormData.label: i18n("Floating Speed (ms):")
        }

        QQC2.SpinBox {
            id: glowSpinBox
            from: 1
            to: 50
            stepSize: 1
            Kirigami.FormData.label: i18n("Glow Sharpness (Radius):")
        }

        QQC2.SpinBox {
            id: flickerSpinBox
            from: 1000
            to: 30000
            stepSize: 500
            Kirigami.FormData.label: i18n("Subtitle Flicker Interval (ms):")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: use24HourCheckbox
            text: i18n("Use 24-Hour Format")
            Kirigami.FormData.label: i18n("Time Format:")
        }

        QQC2.CheckBox {
            id: showAMPMCheckbox
            text: i18n("Show AM/PM (12-Hour only)")
            enabled: !use24HourCheckbox.checked
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: showTopButterfliesCheckbox
            text: i18n("Show Top Butterflies")
            Kirigami.FormData.label: i18n("Visibility:")
        }

        QQC2.CheckBox {
            id: showSubtitleCheckbox
            text: i18n("Show Subtitle & Ghost Butterfly")
        }

        QQC2.CheckBox {
            id: lowPowerModeCheckbox
            text: i18n("Low Power Mode (Freeze Animations)")
            Kirigami.FormData.label: i18n("Performance:")
        }

        QQC2.TextField {
            id: subtitleTextField
            Kirigami.FormData.label: i18n("Subtitle Text:")
            Layout.fillWidth: true
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.Button {
            text: i18n("Restore Defaults")
            icon.name: "edit-undo"
            onClicked: {
                neonColorPicker.color = cfg_neonColorDefault
                textColorPicker.color = cfg_textColorDefault
                subtitleColorPicker.color = cfg_subtitleColorDefault
                topButterflyColorPicker.color = cfg_topButterflyColorDefault
                flapSpinBox.value = cfg_flapDurationDefault
                floatSpinBox.value = cfg_floatDurationDefault
                showSubtitleCheckbox.checked = cfg_showSubtitleDefault
                subtitleTextField.text = cfg_subtitleTextDefault
                glowSpinBox.value = cfg_glowStrengthDefault
                flickerSpinBox.value = cfg_flickerIntervalDefault
                use24HourCheckbox.checked = cfg_use24HourFormatDefault
                showAMPMCheckbox.checked = cfg_showAMPMDefault
                showTopButterfliesCheckbox.checked = cfg_showTopButterfliesDefault
                lowPowerModeCheckbox.checked = cfg_lowPowerModeDefault
            }
        }
    }
}
