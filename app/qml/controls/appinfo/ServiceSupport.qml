import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import QmlFileIO 1.0
import GlobalConfig 1.0
import UpdateWrapper 1.0
import UpstreamReleaseGetter 1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import anmsettings 1.0
import '../../controls'

Item {
    id: root
    readonly property real rowHeight: Math.max(height * 0.0725, 10)
    readonly property real rowWidth: Math.max(buttonStoreLog.implicitContentWidth, buttonStartUpdateWithUSBStick.implicitContentWidth,
                                              buttonUpdateWithoutUSBStick.implicitContentWidth)
    readonly property real pointSize: rowHeight * 0.5
    readonly property bool isNetworkConnected: networkListModel.networkConnected
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]

    WaitTransaction { id: waitPopup }
    DeviceVersions { id: devVersions }
    InfoInterface { id: networkListModel }

    ZButton {
        id: buttonStoreLog
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: rowWidth * 1.5
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
    UpdateWrapper { id: updateCppWrapper }
    UpstreamReleaseGetter { id: releaseGetter }
    Connections {
        target: releaseGetter
        function onSigReleaseVersionChanged() {
            if(currentReleaseVersion === releaseGetter.releaseVersion)
                sameVersionPopup.visible = true
            else
                releaseInfo.open()
        }
    }

    ReleaseInfo {
        id: releaseInfo
        releaseVersion: releaseGetter.releaseVersion
        releaseText: releaseGetter.releaseText
        currentReleaseVersion: root.currentReleaseVersion
        Connections {
            target: releaseInfo
            function onSigUpdateRequest() {
                updateCppWrapper.startUpdateNet()
            }
        }
    }

    ZButton {
        id: buttonStartUpdateWithUSBStick
        anchors {top: buttonStoreLog.bottom; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: rowWidth * 1.5
        text: Z.tr("Start update by USB stick")
        readonly property int installStatus: updateCppWrapper.status
        onClicked: {
            updateCppWrapper.startUpdateUsb()
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
    ZButton {
        id: buttonUpdateWithoutUSBStick
        anchors {top: buttonStartUpdateWithUSBStick.bottom; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: rowWidth * 1.5
        text: Z.tr("Start update by network")
        enabled: isNetworkConnected
        highlighted: true
        readonly property int installStatus: updateCppWrapper.status
        onClicked: releaseGetter.startGetLatestReleaseDetails()

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
                releaseInfo.close()
            }
        }
    }
    Popup {
        id: sameVersionPopup
        anchors.centerIn: parent
        width: contentWidth * 1.2
        height: contentHeight * 1.2
        visible: false
        ColumnLayout {
            anchors.fill: parent
            Label {
                font.pointSize: pointSize
                text: Z.tr("Device has the latest release version")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            ZButton {
                text: Z.tr("Close")
                font.pointSize: pointSize
                Layout.alignment: Qt.AlignHCenter
                onClicked: sameVersionPopup.close()
            }
        }
    }

    Item {
        anchors {top: buttonUpdateWithoutUSBStick.bottom;
                 left: buttonUpdateWithoutUSBStick.left;
                 right: buttonUpdateWithoutUSBStick.right; }
        height: root.rowHeight * 1.5
        width: rowWidth * 1.5
        visible: true
        RowLayout {
            anchors.fill: parent
            Label {
                font.pointSize: root.pointSize
                text: Z.tr("Notify on new releases: ")
                textFormat: Text.PlainText
                Layout.fillHeight: true
                Layout.fillWidth: true
                verticalAlignment: Label.AlignVCenter
            }
            ZCheckBox {
                Layout.fillHeight: true
                rightPadding: 0
                padding: 0
                spacing: 0
                checked: GC.notifyOnRelease
                onCheckedChanged: GC.setNotifyOnRelease(checked)
            }
        }
    }

}
