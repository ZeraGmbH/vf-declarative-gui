import QtQuick 2.14
import QtQuick.Controls 2.14
import ZeraTranslation 1.0
import GlobalConfig 1.0
import QmlFileIO 1.0
import ZeraComponents 1.0

Item {
    id: splashItem
    anchors.fill: parent
    Label {
        anchors.centerIn: parent
        text: {
            if (splashItem.firmwareUpdateRunning)
                return Z.tr("Firmware update is running.\nDo not switch off the device!")
            return safeDelay.running ? Z.tr("Please wait...") : Z.tr("Something went wrong")
        }
        font.pointSize: parent.height * 0.08
        horizontalAlignment: Label.AlignHCenter
        verticalAlignment: Label.AlignVCenter
    }
    BusyIndicator {
        visible: splashItem.firmwareUpdateRunning || safeDelay.running
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        height: parent.height * 0.125
        width: height
        anchors.bottomMargin: height
    }
    ZButton {
        visible: !safeDelay.running && !splashItem.firmwareUpdateRunning
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: parent.width * 0.5
        height: parent.height * 0.125
        font.pointSize: parent.height * 0.04
        text: Z.tr("Save/Send logs")
        onClicked: {
            GC.setLastInfoTabSelected(1)
            layoutStack.currentIndex = GC.layoutStackEnum.layoutStatusIndex
        }
    }
    property bool firmwareUpdateRunning: QmlFileIO.fileExists("/tmp/firmware-update-pending")
    Timer {
        interval: 300
        repeat: true
        running: true
        onTriggered: {
            splashItem.firmwareUpdateRunning = QmlFileIO.fileExists("/tmp/firmware-update-pending")
        }
    }
    Timer {
        id: safeDelay
        interval: 10000
        repeat: false
        running: !splashItem.firmwareUpdateRunning
    }
}
