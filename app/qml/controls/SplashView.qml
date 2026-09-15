import QtQuick 2.14
import QtQuick.Controls 2.14
import ZeraTranslation 1.0
import GlobalConfig 1.0
import QmlFileIO 1.0
import ZeraComponents 1.0
import "./appinfo"

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
        font.pointSize: Math.max(parent.height * 0.08, 10)
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
    ButtonStoreLog {
        visible: !safeDelay.running && !splashItem.firmwareUpdateRunning
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        height: parent.height * 0.125
        font.pointSize: Math.max(parent.height * 0.04, 10)
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
