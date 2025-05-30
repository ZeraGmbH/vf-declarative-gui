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
        anchors.fill: parent

        function handlePrintPressed() {
            if(screenCapture.captureOnFirstMounted(screenCapture.mountedPaths))
                successfulPopup.open()
            else
                unseccessfulPopup.open()
        }

        ScreenCapture {
            id: screenCapture
            readonly property var mountedPaths: QmlFileIO.mountedPaths // bind to ensure valid on first key press
        }
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
