import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import UpdateWrapper 1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import anmsettings 1.0
import GlobalConfig 1.0

Item {
    id: root
    property int windowHeight
    property int windowWidth
    readonly property real rowHeight: Math.max(windowHeight * 0.0725, 10)
    readonly property real pointSize: rowHeight * 0.5
    readonly property bool isNetworkConnected: networkListModel.entryCount > 0
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]
    property QtObject updateWrapper
    readonly property int installStatus: updateWrapper.status
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
            releaseInfo.releaseInfoWindowOnOff(false)
        }
    }
    UpdateWrapper {id: updateWrapper}

    InfoInterface { id: networkListModel }
    WaitTransaction { id: waitPopup }
    ReleaseInfo {
        id: releaseInfo
        updateWrapper: updateWrapper
        currentReleaseVersion: root.currentReleaseVersion
        windowHeight: root.windowHeight
        windowWidth: root.windowWidth
    }

    function checkLatestRelease() {
        if(isNetworkConnected)
            if(currentReleaseVersion != null)
                updateWrapper.checkIfReleaseIsLatest(currentReleaseVersion)
    }

    Connections {
        target: updateWrapper
        function onSigReleaseCheckFinished(newReleaseFound) {
            if(newReleaseFound);
                newReleasePopup.visible = true
        }
    }

    Timer {
        id: checkNewReleaseTimer
        interval: 86400000  // 24 hours
        running: GC.notifyOnRelease
        repeat: true
        onTriggered: checkLatestRelease()
    }

    Popup {
        id: newReleasePopup
        x: (windowWidth - width) / 2
        y: (windowHeight - height) / 2
        width: contentWidth * 1.2
        height: contentHeight * 1.2
        visible: false
        ColumnLayout {
            anchors.fill: parent
            Label {
                font.pointSize: pointSize
                text: Z.tr("New Release version has been published !")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                ZButton {
                    text: Z.tr("More")
                    font.pointSize: pointSize
                    onClicked: {
                        newReleasePopup.close()
                        updateWrapper.prepareReleaseUpdate()
                        releaseInfo.releaseInfoWindowOnOff(true)
                    }
                }
                ZButton {
                    text: Z.tr("Close")
                    font.pointSize: pointSize
                    onClicked: {
                        newReleasePopup.close()
                        GC.setNotifyOnRelease(false)
                    }
                }
                ZButton {
                    text: Z.tr("Remind me later")
                    font.pointSize: pointSize
                    onClicked: {
                        newReleasePopup.close()
                        checkNewReleaseTimer.restart()
                    }
                }
            }
        }
    }
}
