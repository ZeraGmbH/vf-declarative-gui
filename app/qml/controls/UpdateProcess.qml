import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import UpdateWrapper 1.0
import UpstreamReleaseGetter 1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import anmsettings 1.0
import GlobalConfig 1.0

Item {
    id: root
    readonly property bool isNetworkConnected: networkListModel.networkConnected
    onIsNetworkConnectedChanged: {
        if(isNetworkConnected && GC.notifyOnRelease)
            checkLatestRelease()
    }
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]
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
            releaseInfo.close()
        }
    }
    InfoInterface { id: networkListModel }
    WaitTransaction { id: waitPopup }
    UpdateWrapper {id: updateWrapper}
    UpstreamReleaseGetter {id: releaseGetter}
    ReleaseInfo {
        id: releaseInfo
        releaseVersion: releaseGetter.releaseVersion
        releaseText: releaseGetter.releaseText
        currentReleaseVersion: root.currentReleaseVersion
        Connections {
            target: releaseInfo
            function onSigUpdateRequest() {
                updateWrapper.updateDevice()
            }
        }
    }
    function checkLatestRelease() {
        if(isNetworkConnected)
            releaseGetter.startGetLatestReleaseDetails()
    }

    Connections {
        target: releaseGetter
        function onSigReleaseVersionChanged() {
            if (currentReleaseVersion != null && currentReleaseVersion !== releaseGetter.releaseVersion)
                releaseInfo.open()
        }
    }

    Timer {
        id: checkNewReleaseTimer
        interval: 86400000  // 24 hours
        running: GC.notifyOnRelease && isNetworkConnected
        repeat: true
        onTriggered: checkLatestRelease()
    }
}
