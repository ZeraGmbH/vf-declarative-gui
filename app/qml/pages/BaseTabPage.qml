import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import ScreenCapture 1.0
import QmlFileIO 1.0
import ZeraTranslation  1.0

Item {
    id: root
    focus: true

    readonly property real tabPointSize: height * 0.0225
    readonly property real tabHeight: height * 0.07

    property alias swipeView: swipeView
    property alias tabBar: tabBar
    // We default to what most views (measurement pages) do. Other type
    // of views can override getLastTabSelected and setLastTabSelected
    function getLastTabSelected() {
        return GC.lastTabSelected
    }
    function setLastTabSelected(tabNo) {
        GC.setLastTabSelected(tabNo)
    }
    function finishInit() {
        let lastTabSelected = getLastTabSelected()
        if(lastTabSelected >= swipeView.count) {
            lastTabSelected = 0
        }
        if(lastTabSelected) {
            swipeView.setCurrentIndex(lastTabSelected)
            initTimer.start()
        }
        else {
            initialized = true
        }
    }

    // pass focus to swipeView
    onFocusChanged: {
        if(focus) {
            swipeView.forceActiveFocus()
        }
    }
    onInitializedChanged: forceActiveFocus()

    Keys.onPressed: {
        if(event.key === Qt.Key_Print) {
            if(QmlFileIO.mountedPaths.length > 0) {
                QmlFileIO.storeScreenShotOnUsb()
                successfulWindow.open()
                timerCloseSucessfulWindow.start()
            }
            else
                unseccessfulWindow.open()
        }
    }

    Timer {
        id: timerCloseSucessfulWindow
        interval: 1200
        repeat: false
        onTriggered: successfulWindow.close()
    }

    Popup {
        id : successfulWindow
        anchors.centerIn: parent
        width: parent.width/1.8
        height: parent.height/6
        modal: true
        ColumnLayout {
            anchors.fill: parent
            Label {
                font.pointSize: root.height/40
                text: Z.tr("Screenshot taken and saved on USB-stick")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }
    }

    Popup {
        id : unseccessfulWindow
        anchors.centerIn: parent
        width: parent.width/3
        height: parent.height/5
        modal: true
        ColumnLayout {
            anchors.fill: parent
            Label {
                font.pointSize: root.height/40
                text: Z.tr("No USB-stick inserted")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Button {
                text: "OK"
                font.pointSize: root.height/50
                Layout.alignment: Qt.AlignHCenter
                onClicked: unseccessfulWindow.close()
            }
        }
    }

    SwipeView {
        id: swipeView
        visible: initialized
        anchors.fill: parent
        anchors.topMargin: tabBar.height
        currentIndex: tabBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: tabBar
        width: parent.width
        contentHeight: tabHeight
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: {
            if(initialized) {
                setLastTabSelected(currentIndex)
                swipeView.forceActiveFocus()
            }
        }
    }

    ScreenCapture {
        id: screencapture
    }

    property bool initialized: false
    Timer {
        id: initTimer
        interval: 250
        onTriggered: {
            initialized = true
        }
    }


}
