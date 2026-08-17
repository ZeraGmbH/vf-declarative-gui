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
    id: root
    function checkLatestRelease() {
        if(isNetworkConnected)
            releaseGetter.startGetLatestReleaseDetails()
    }

    Timer {
        interval: 86400000  // 24 hours
        running: GC.notifyOnRelease && isNetworkConnected
        repeat: true
        onTriggered: checkLatestRelease()
    }

    InfoInterface { id: networkListModel }
    readonly property bool isNetworkConnected: networkListModel.networkConnected
    onIsNetworkConnectedChanged: {
        if(isNetworkConnected && GC.notifyOnRelease)
            checkLatestRelease()
    }

    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]

    UpdateWrapperQml { id: updateWrapperQml }
    UpstreamReleaseGetter { id: releaseGetter }
    Connections {
        target: releaseGetter
        function onSigReleaseVersionChanged() {
            if (currentReleaseVersion != null && currentReleaseVersion !== releaseGetter.releaseVersion)
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
