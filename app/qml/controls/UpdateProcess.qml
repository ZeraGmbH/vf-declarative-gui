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
        checkLatestRelease(false)
    }
    signal sigUpstreamHasSameVersionAsInstalled()

    id: root
    Timer {
        interval: 86400000  // 24 hours
        running: GC.notifyOnRelease && isNetworkConnected
        repeat: true
        onTriggered: checkLatestRelease(true)
    }
    function checkLatestRelease(calledFromAutoCheck) {
        if(isNetworkConnected) {
            fireOnSame = !calledFromAutoCheck
            releaseGetter.startGetLatestReleaseDetails()
        }
    }

    InfoInterface { id: networkListModel }
    readonly property bool isNetworkConnected: networkListModel.networkConnected
    onIsNetworkConnectedChanged: { tryUpdate() }
    readonly property bool isAutoUpdateCheckActive: GC.notifyOnRelease
    onIsAutoUpdateCheckActiveChanged: { tryUpdate() }
    function tryUpdate() {
        if(isNetworkConnected && isAutoUpdateCheckActive)
            checkLatestRelease(true)
    }

    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]
    property bool fireOnSame: false

    UpdateWrapperQml { id: updateWrapperQml }
    UpstreamReleaseGetter { id: releaseGetter }
    Connections {
        target: releaseGetter
        function onSigReleaseVersionChanged() {
            if (currentReleaseVersion === releaseGetter.releaseVersion) {
                if (fireOnSame)
                    sigUpstreamHasSameVersionAsInstalled()
            }
            else
                releaseInfo.open()
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
