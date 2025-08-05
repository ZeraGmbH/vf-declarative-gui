import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import FontAwesomeQml 1.0
import ZeraTranslation 1.0
import ZeraThemeConfig 1.0

Loader {
    id: root
    active: false
    property bool opened: active ? item.opened : false
    function startWait(strDisplay) {
        active = true
        item.startWait(strDisplay)
    }
    function stopWait(warningTxtArr, errorTxtArr, funcExecutedOnFinish) {
        item.stopWait(warningTxtArr, errorTxtArr, funcExecutedOnFinish)
    }
    sourceComponent: Popup {
        id: popup
        function startWait(strDisplay) {
            warningTxtArr = []
            errorTxtArr = []
            header.text = strDisplay
            open()
            fadeInAnimation.start()
            animationLoader.visible = false
            longRunAnimationSTartTimer.start()
        }
        function stopWait(warningTxtArr, errorTxtArr, funcExecutedOnFinish) {
            popup.warningTxtArr = warningTxtArr
            popup.errorTxtArr = errorTxtArr
            popup.funcExecutedOnFinish = funcExecutedOnFinish
            fadeInAnimation.stop()
            longRunAnimationSTartTimer.stop()
            animationLoader.active = false
            if(errorTxtArr.length === 0 && warningTxtArr.length === 0) {
                finishTimer.start()
            }
            else {
                popup.opacity = 1.0
            }
        }

        parent: Overlay.overlay
        width: parent.width
        height: parent.height

        closePolicy: Popup.NoAutoClose

        // layout calculations
        readonly property real rowHeight: parent.height > 0 ? parent.height/8 : 10
        readonly property real pointSize: rowHeight * 0.3

        property var warningTxtArr: []
        property var errorTxtArr: []
        property var funcExecutedOnFinish: null

        NumberAnimation {
            id: fadeInAnimation
            target: popup
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
                    popup.opacity = 1.0
                }
            }
            onTriggered: {
                if(popup.funcExecutedOnFinish) {
                    popup.funcExecutedOnFinish()
                }
                popup.close()
            }
        }

        // visible controls
        Label {
            id: header
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 5 - height
            font.pointSize: popup.pointSize
        }
        Label { // finish OK indicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: popup.pointSize * 5
            text: FAQ.fa_check
            color: ZTC.isDarkTheme ? ZTC.accentColor : Material.color(Material.Green)
            visible: finishTimer.running && popup.warningTxtArr.length === 0 && popup.errorTxtArr.length === 0
        }
        Label { // warning/error indicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: popup.pointSize
            horizontalAlignment: Label.AlignHCenter
            text: {
                let colorTxt = ''
                popup.warningTxtArr.forEach(txt =>
                    colorTxt += (colorTxt !== '' ? '<br>' : '' ) + '<font color=\"yellow\">' + Z.tr('Warning:') +' ' + txt + '</font>')
                popup.errorTxtArr.forEach(txt =>
                    colorTxt += (colorTxt !== '' ? '<br>' : '' ) + '<font color=\"red\">' + Z.tr('Error:') + ' ' + txt + '</font>')
                return colorTxt
            }
            visible: popup.warningTxtArr.length + popup.errorTxtArr.length > 0
            wrapMode: Label.WordWrap
            width: parent.width * 0.9
            height: implicitHeight
        }
        Loader {
            id: animationLoader
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: AnimationSlowBits { }
            height: popup.rowHeight * 1.5
            width: popup.width * 0.9
            active: false
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 4 / 5
            width: popup.width * 0.25
            text: Z.tr("Close")
            font.pointSize: popup.pointSize
            visible: popup.warningTxtArr.length > 0 || popup.errorTxtArr.length > 0
            onClicked: popup.close()
        }
    }
}
