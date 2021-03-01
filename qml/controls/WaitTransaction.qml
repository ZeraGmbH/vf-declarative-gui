import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraFa 1.0
import ZeraTranslation  1.0

Popup {
    id: root
    property alias animationComponent: animationLoader.sourceComponent
    function startWait(strDisplay) {
        root.errorTxt = ""
        header.text = strDisplay
        open()
        fadeInAnimation.start()
        animationLoader.visible = false
        longRunAnimationSTartTimer.start()
    }
    function stopWait(errorTxt, fpOnFinish) {
        root.errorTxt = errorTxt
        root.fpOnFinish = fpOnFinish
        fadeInAnimation.stop()
        longRunAnimationSTartTimer.stop()
        animationLoader.active = false
        if(errorTxt === '') {
            finishTimer.start()
        }
    }

    parent: Overlay.overlay
    width: parent.width
    height: parent.height
    closePolicy: Popup.NoAutoClose

    // layout calculations
    readonly property real rowHeight: parent.height > 0 ? parent.height/8 : 10
    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale

    property string errorTxt: ''
    property var fpOnFinish: null

    NumberAnimation {
        id: fadeInAnimation
        target: root
        property: "opacity"
        duration: 1500
        from: 0
        to: 0.9
    }
    Timer {
        id: longRunAnimationSTartTimer
        interval: 2000
        repeat: false
        onTriggered: {
            // No checks required: loader does simply nothing
            // without source component
            animationLoader.active = true
            animationLoader.visible = true
        }
    }
    Timer {
        id: finishTimer
        interval: 800
        repeat: false
        onRunningChanged: {
            if(running) {
                root.opacity = 1.0
            }
        }
        onTriggered: {
            if(fpOnFinish) {
                root.fpOnFinish()
            }
            close()
        }
    }

    // visible controls
    Label {
        id: header
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 4
        font.pointSize: pointSize
    }
    Label { // finish OK indicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.family: FA.old
        font.pointSize: pointSize * 5
        text: FA.fa_check
        color: Material.accentColor
        visible: finishTimer.running && root.errorTxt === ''
    }
    Label { // error indicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: pointSize
        text: root.errorTxt
        Material.foreground: Material.Red
        visible: root.errorTxt !== ''
    }
    Loader {
        id: animationLoader
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: rowHeight * 1.5
        width: root.width * 0.9
        active: false
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 3 / 4
        text: Z.tr("Close")
        font.pointSize: pointSize
        visible: root.errorTxt !== ''
        onClicked: close()
    }
}
