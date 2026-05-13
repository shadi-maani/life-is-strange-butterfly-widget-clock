import QtQuick

SequentialAnimation {
    id: glitchAnim
    property Item targetItem

    OpacityAnimator { target: glitchAnim.targetItem; to: 0.1; duration: 50 }
    OpacityAnimator { target: glitchAnim.targetItem; to: 0.9; duration: 40 }
    OpacityAnimator { target: glitchAnim.targetItem; to: 0.15; duration: 45 }
    OpacityAnimator { target: glitchAnim.targetItem; to: 1.0; duration: 90 }
}
