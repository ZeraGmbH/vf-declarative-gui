import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import ZeraTranslation  1.0
import QmlFileIO 1.0
import GlobalConfig 1.0
import UpdateWrapper 1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import anmsettings 1.0
import '../../controls'

Item {
    id: root
    readonly property real rowHeight: Math.max(height * 0.0725, 10)
    readonly property real pointSize: rowHeight * 0.5
    readonly property bool isNetworkConnected: networkListModel.entryCount > 0
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
        width: implicitContentWidth * 2
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
        id: buttonStartUpdateWithUSBStick
        anchors {top: buttonStoreLog.bottom; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: buttonStoreLog.width
        text: Z.tr("Start Update using USB stick")
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
    Connections {
        target: updateWrapper
        function onSigReleaseVersionChanged() {
            if(currentReleaseVersion == updateWrapper.releaseVersion)
                sameVersionPopup.visible = true
            else
                confirmationPopup.visible = true
        }
    }
    ZButton {
        id: buttonUpdateWithoutUSBStick
        anchors {top: buttonStartUpdateWithUSBStick.bottom; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: buttonStoreLog.width
        text: Z.tr("Start Update")
        enabled: isNetworkConnected
        highlighted: true
        readonly property int installStatus: updateWrapper.status
        onClicked: updateWrapper.prepareReleaseUpdate()

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
                confirmationPopup.close()
            }
        }
    }
    Popup {
        id: confirmationPopup
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8
        visible: false
        ColumnLayout {
            anchors.fill: parent
            Flickable {
                id: licenseFlickable
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: updateText.implicitHeight
                contentWidth: parent.width
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                ScrollBar.vertical: ScrollBar {
                    width: 8
                    policy:
                        licenseFlickable.contentHeight > licenseFlickable.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }
                Label {
                    id: updateText
                    width: licenseFlickable.width
                    wrapMode: Text.WordWrap
                    font.pointSize: pointSize
                    //when we add HTML tags to qml text, it switches from plain text to HTML rendering.
                    text: "<b>" +Z.tr("Update device ") + root.currentReleaseVersion + "->" + updateWrapper.releaseVersion + "</b><br><br>" +
                          updateWrapper.releaseText.replace(/\n/g, "<br>")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
            RowLayout {
                id: okCancelButtonRow
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                anchors.bottom: confirmationPopup.bottom
                readonly property real buttonWidth: Math.max(cancelButton.implicitWidth, okButton.implicitWidth) * 1.1
                ZButton {
                    id: cancelButton
                    text: Z.tr("Cancel")
                    font.pointSize: pointSize
                    Layout.preferredWidth: okCancelButtonRow.buttonWidth
                    onClicked: confirmationPopup.close()
                }
                ZButton {
                    id: okButton
                    text: Z.tr("OK")
                    font.pointSize: pointSize
                    Layout.preferredWidth: okCancelButtonRow.buttonWidth
                    onClicked: updateWrapper.updateDevice()
                }
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
                Layout.preferredWidth: okCancelButtonRow.buttonWidth
                onClicked: sameVersionPopup.close()
            }
        }
    }

}
