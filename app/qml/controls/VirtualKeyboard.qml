import QtQuick 2.14
import QtQuick.VirtualKeyboard 2.14
import GlobalConfig 1.0

InputPanel {
    id: inputPanel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: QT_MAJOR_VERSION === "5" ? -parent.height * 0.035 : 0
    anchors.rightMargin: QT_MAJOR_VERSION === "5" ? -parent.width * 0.035 : 0
    anchors.leftMargin: anchors.rightMargin
    property bool textEntered: Qt.inputMethod.visible
    onHeightChanged: GC.vkeyboardHeight = height
    opacity: 0
    NumberAnimation on opacity {
        id: keyboardOpacityAnimation
        onStarted: {
            if(to === 1)
                inputPanel.visible = GC.showVirtualKeyboard
        }
        onFinished: {
            if(to === 0)
                inputPanel.visible = false
        }
    }
    onTextEnteredChanged: {
        var rectInput = Qt.inputMethod.anchorRectangle
        if(inputPanel.textEntered) {
            if(GC.showVirtualKeyboard) {
                if(rectInput.bottom > inputPanel.y) {
                    // shift flickable (normal elements)
                    flickableAnimation.to = rectInput.bottom - inputPanel.y + 10
                    flickableAnimation.start()
                    // shift overlay (Popup)
                    overlayAnimation.to = -(rectInput.bottom - inputPanel.y + 10)
                    overlayAnimation.start()
                }
                keyboardOpacityAnimation.to = 1
                keyboardOpacityAnimation.duration = 300
                keyboardOpacityAnimation.start()
            }
        }
        else {
            if(flickable.contentY !== 0) {
                // shift everything back
                overlayAnimation.to = 0
                overlayAnimation.start()
                flickableAnimation.to = 0
                flickableAnimation.start()
            }
            keyboardOpacityAnimation.to = 0
            keyboardOpacityAnimation.duration = 0
            keyboardOpacityAnimation.start()
        }
    }
}
