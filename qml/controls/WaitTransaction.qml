import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ZeraFa 1.0
import ZeraTranslation  1.0

Popup {
    id: root
    property alias animationComponent: animationLoader.sourceComponent
    function startWait(strDisplay) {
        root.warningTxtArr = []
        root.errorTxtArr = []
        header.text = strDisplay
        open()
        fadeInAnimation.start()
        animationLoader.visible = false
        longRunAnimationSTartTimer.start()
    }
    function stopWait(warningTxtArr, errorTxtArr, fpOnFinish /* function pointer on finish */) {
        if(!root.opened) {
            return
        }
        root.warningTxtArr = warningTxtArr
        root.errorTxtArr = errorTxtArr
        root.fpOnFinish = fpOnFinish
        fadeInAnimation.stop()
        longRunAnimationSTartTimer.stop()
        animationLoader.active = false
        if(errorTxtArr.length === 0 && warningTxtArr.length === 0) {
            finishTimer.start()
        }
        else {
            root.opacity = 1.0
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

    property var warningTxtArr: []
    property var errorTxtArr: []
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
        y: parent.height / 5 - height
        font.pointSize: pointSize
    }
    Label { // finish OK indicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.family: FA.old
        font.pointSize: pointSize * 5
        text: FA.fa_check
        color: Material.accentColor
        visible: finishTimer.running && root.warningTxtArr.length === 0 && root.errorTxtArr.length === 0
    }
    Label { // warning/error indicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: pointSize
        text: {
            let colorTxt = ''
            root.warningTxtArr.forEach(txt =>
                colorTxt += (colorTxt !== '' ? '<br>' : '' ) + '<font color=\"yellow\">' + Z.tr('Warning:') +' ' + txt + '</font>')
            root.errorTxtArr.forEach(txt =>
                colorTxt += (colorTxt !== '' ? '<br>' : '' ) + '<font color=\"red\">' + Z.tr('Error:') + ' ' + txt + '</font>')
            return colorTxt
        }
        visible: root.warningTxtArr.length + root.errorTxtArr.length > 0
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
        y: parent.height * 4 / 5
        width: root.width * 0.25
        text: Z.tr("Close")
        font.pointSize: pointSize
        visible: root.warningTxtArr.length > 0 || root.errorTxtArr.length > 0
        onClicked: close()
    }
}
