import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import QmlFileIO 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

ZButton {
    property string serverIp

    text: Z.tr("Save logfile to USB")
    readonly property bool writingLogsToUsb: QmlFileIO.writingLogsToUsb
    enabled: (QmlFileIO.mountedPaths.length > 0) && !writingLogsToUsb
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
    DeviceVersions { id: devVersions }
    WaitTransaction { id: waitPopup }

    onClicked: {
        QmlFileIO.startWriteJournalctlOnUsb(allVersionsForStore, serverIp)
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
