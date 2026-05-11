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
    property alias cfg_flapDuration: flapSpinBox.value
    property alias cfg_floatDuration: floatSpinBox.value

    // ─── Default values (required by Plasma 6) ───
    property color cfg_neonColorDefault: "#00aaff"
    property color cfg_textColorDefault: "#dff2ff"
    property color cfg_subtitleColorDefault: "#dff2ff"
    property int cfg_flapDurationDefault: 180
    property int cfg_floatDurationDefault: 2800

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
                flapSpinBox.value = cfg_flapDurationDefault
                floatSpinBox.value = cfg_floatDurationDefault
            }
        }
    }
}
