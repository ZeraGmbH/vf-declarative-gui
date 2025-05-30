import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import ZeraTranslation  1.0
import ScreenCapture 1.0
import QmlFileIO 1.0

Loader {
    active: false
    anchors.fill: parent

    function handlePrintPressed() {
        active = true
        item.handlePrintPressed()
    }

    sourceComponent: Item {
        id: screenShooter
        anchors.fill: parent

        readonly property var mountedPaths: QmlFileIO.mountedPaths
        function handlePrintPressed() {
            if (mountedPaths.length)
                takeScreenshot()
            else
                waitForMounts()
        }

        function takeScreenshot() {
            if(screenCapture.captureOnFirstMounted(mountedPaths))
                successfulPopup.open()
            else
                unseccessfulPopup.open()
        }
        function waitForMounts() {
            firstLoadDelayTimer.start()
        }
        Timer {
            id: firstLoadDelayTimer
            interval: 300
            repeat: false
            onTriggered: unseccessfulPopup.open()
            readonly property var mountedPaths: screenShooter.mountedPaths
        }
        onMountedPathsChanged: {
            if(firstLoadDelayTimer.running) {
                firstLoadDelayTimer.stop()
                screenShooter.takeScreenshot()
            }
        }

        ScreenCapture { id: screenCapture }
        Popup {
            id : successfulPopup
            anchors.centerIn: parent
            width: parent.width * 0.85
            height: parent.height * 0.18
            modal: true
            ColumnLayout {
                anchors.fill: parent
                Label {
                    font.pointSize: pointSize
                    text: Z.tr("Screenshot taken and saved on USB-stick")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
            Timer {
                id: timerCloseSuccessfulPopup
                interval: 1200
                repeat: false
                onTriggered: successfulPopup.close()
            }
            onOpened: timerCloseSuccessfulPopup.start()
        }
        Popup {
            id : unseccessfulPopup
            anchors.centerIn: parent
            width: parent.width * 0.45
            height: parent.height * 0.27
            modal: true
            closePolicy: Popup.CloseOnEscape
            ColumnLayout {
                anchors.fill: parent
                Label {
                    font.pointSize: pointSize
                    text: Z.tr("No USB-stick inserted")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
                Button {
                    text: "OK"
                    font.pointSize: pointSize
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: unseccessfulPopup.close()
                }
            }
        }
    }
}
