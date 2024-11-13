import QtQuick 2.5
import QtQuick.Controls 2.0
import ZeraTranslation  1.0
import QmlFileIO 1.0
import GlobalConfig 1.0
import DeviceVersions 1.0
import UpdateWrapper 1.0
import '../../controls'

Item {
    id: root
    readonly property real rowHeight: height > 0 ? height * 0.0725 : 10
    readonly property real pointSize: rowHeight * 0.5

    WaitTransaction {
        id: waitPopup
        animationComponent: AnimationSlowBits { }
    }

    Button {
        id: buttonStoreLog
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        implicitWidth: implicitContentWidth * 1.2
        text: Z.tr("Save logfile to USB")
        readonly property bool writingLogsToUsb: QmlFileIO.writingLogsToUsb
        enabled: (QmlFileIO.mountedPaths.length > 0) && !writingLogsToUsb
        highlighted: true
        onClicked: {
            QmlFileIO.startWriteJournalctlOnUsb(DevVersions.allVersionsForStore, GC.serverIp)
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
    Button {
        id: buttonStartUpdate
        anchors {top: buttonStoreLog.bottom; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: buttonStoreLog.width
        text: Z.tr("Start Update")
        onClicked: {
            updateWrapper.startInstallation()
        }
        enabled: (QmlFileIO.mountedPaths.length > 0)
        highlighted: true
    }

}
