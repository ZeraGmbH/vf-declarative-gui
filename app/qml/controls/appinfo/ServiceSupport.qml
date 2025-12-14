import QtQuick 2.5
import QtQuick.Controls 2.0
import ZeraTranslation  1.0
import QmlFileIO 1.0
import GlobalConfig 1.0
import UpdateWrapper 1.0
import ZeraComponents 1.0
import '../../controls'

Item {
    id: root
    readonly property real rowHeight: height > 0 ? height * 0.0725 : 10
    readonly property real pointSize: rowHeight * 0.5

    WaitTransaction { id: waitPopup }
    DeviceVersions { id: devVersions }

    ZButton {
        id: buttonStoreLog
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: implicitContentWidth * 1.5
        text: Z.tr("Save logfile to USB")
        readonly property bool writingLogsToUsb: QmlFileIO.writingLogsToUsb
        enabled: (QmlFileIO.mountedPaths.length > 0) && !writingLogsToUsb
        highlighted: true
        readonly property var allVersionsForStore: {
            let versions = {}
            let allVersions = devVersions.allVersions
            for(let entry = 0; entry < allVersions.length; entry++) {
                let label = allVersions[entry][0]
                let value = allVersions[entry][1]
                versions[label] = value
            }
            return versions
        }
        onClicked: {
            QmlFileIO.startWriteJournalctlOnUsb(allVersionsForStore, GC.serverIp)
        }
        onWritingLogsToUsbChanged: {
            if(writingLogsToUsb)
                waitPopup.startWait(Z.tr("Saving logs and dumps to external drive..."))
            else {
                if(QmlFileIO.lastWriteLogsOk)
                    waitPopup.stopWait([], [], null)
                else
                    waitPopup.stopWait([], [Z.tr("Could not save logs and dumps")], null)
            }
        }
    }
    UpdateWrapper {id: updateWrapper}
    ZButton {
        id: buttonStartUpdate
        anchors {top: buttonStoreLog.bottom; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: buttonStoreLog.width
        text: Z.tr("Start Update")
        readonly property int installStatus: updateWrapper.status
        onClicked: {
            updateWrapper.startInstallation()
        }
        enabled: (QmlFileIO.mountedPaths.length > 0)
        highlighted: true
        onInstallStatusChanged: {
            if(installStatus === UpdateWrapper.InProgress)
                waitPopup.startWait(Z.tr("Starting update..."))
            else {
                if(installStatus === UpdateWrapper.PackageNotFound)
                    waitPopup.stopWait([], [Z.tr("Could not update. Please check if necessary files are available.")])
                if(installStatus === UpdateWrapper.NotEnoughSpace)
                    waitPopup.stopWait([], [Z.tr("Could not update. Not enough space (>400MB) available.")])
                if(installStatus === UpdateWrapper.Failure)
                    waitPopup.stopWait([],[Z.tr("Update failed. Please save logs and send them to service@zera.de.")],null)
                if(installStatus === UpdateWrapper.Success)
                    waitPopup.stopWait([],[],null)
            }
        }
    }

}
