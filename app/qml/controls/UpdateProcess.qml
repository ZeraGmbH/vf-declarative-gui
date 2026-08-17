import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import UpstreamReleaseGetter 1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import anmsettings 1.0
import GlobalConfig 1.0

Item {
    function startUpdateUsb() {
        updateWrapperQml.startUpdateUsb()
    }
    function tryStartUpdateNet() {
        checkNetLatestRelease(true)
    }
    signal sigUpstreamHasSameVersionAsInstalled()
    signal sigUpstreamCheckFailed()

    id: root
    Timer {
        interval: 3600 * 1000 // 1 hour
        running: GC.notifyOnRelease && isNetworkConnected
        repeat: true
        onTriggered: checkNetLatestRelease(false)
    }
    function checkNetLatestRelease(calledByUser) {
        if(isNetworkConnected) {
            userRequestedUpdate = calledByUser
            releaseGetter.startGetLatestReleaseDetails()
            // continues at onSigReleaseVersionChanged()
        }
    }

    InfoInterface { id: networkListModel }
    readonly property bool isNetworkConnected: networkListModel.networkConnected
    onIsNetworkConnectedChanged: { tryNetUpdateCheck() }
    readonly property bool isAutoUpdateCheckActive: GC.notifyOnRelease
    onIsAutoUpdateCheckActiveChanged: {
        if (isAutoUpdateCheckActive)
            GC.resetVersionCanceledByUser()
        tryNetUpdateCheck()
    }
    function tryNetUpdateCheck() {
        if (isNetworkConnected && isAutoUpdateCheckActive)
            checkNetLatestRelease(false)
    }

    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]
    property bool userRequestedUpdate: false

    UpdateWrapperQml { id: updateWrapperQml }
    UpstreamReleaseGetter { id: releaseGetter }
    Connections {
        target: releaseGetter
        function onSigReleaseVersionChanged() {
            if (releaseGetter.releaseVersion === "") {
                if (userRequestedUpdate)
                    sigUpstreamCheckFailed()
            }
            else if (currentReleaseVersion === releaseGetter.releaseVersion) {
                if (userRequestedUpdate)
                    sigUpstreamHasSameVersionAsInstalled()
            }
            else {
                if (userRequestedUpdate || GC.releaseVersionCanceledByUser !== releaseGetter.releaseVersion)
                    releaseInfo.open()
            }
        }
    }
    ReleaseInfo {
        id: releaseInfo
        releaseVersion: releaseGetter.releaseVersion
        releaseText: releaseGetter.releaseText
        Connections {
            target: releaseInfo
            function onSigUpdateRequest() {
                releaseInfo.close()
                updateWrapperQml.startUpdateNet()
            }
        }
    }
}
