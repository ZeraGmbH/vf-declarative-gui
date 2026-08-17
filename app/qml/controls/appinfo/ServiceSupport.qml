import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import ZeraTranslation  1.0
import QmlFileIO 1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import VeinEntity 1.0
import anmsettings 1.0
import '../../controls'

Item {
    id: root
    readonly property real rowHeight: Math.max(height * 0.0725, 10)
    readonly property real rowWidth: Math.max(buttonStoreLog.implicitContentWidth,
                                              buttonStartUpdateWithUSBStick.implicitContentWidth,
                                              buttonUpdateWithoutUSBStick.implicitContentWidth)
    readonly property real pointSize: rowHeight * 0.5
    readonly property bool isNetworkConnected: networkListModel.networkConnected
    readonly property QtObject statusEntity: VeinEntity.getEntity("StatusModule1");
    readonly property string currentReleaseVersion : statusEntity["INF_ReleaseNr"]

    WaitTransaction { id: waitPopup }
    DeviceVersions { id: devVersions }
    InfoInterface { id: networkListModel }
    UpdateProcess { id: updateProcess }

    ZButton {
        id: buttonStoreLog
        anchors.topMargin: rowHeight * 3.5
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

    ZButton {
        id: buttonStartUpdateWithUSBStick
        anchors.topMargin: rowHeight / 2
        anchors {top: buttonStoreLog.bottom; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        width: rowWidth * 1.5
        text: Z.tr("Start update by USB stick")
        onClicked: {
            updateProcess.startUpdateUsb()
        }
        enabled: (QmlFileIO.mountedPaths.length > 0)
        highlighted: true
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
        onClicked: {
            updateProcess.tryStartUpdateNet()
        }
    }

    Item {
        id: checkBoxAutoNotify
        anchors {top: buttonUpdateWithoutUSBStick.bottom;
                 left: buttonUpdateWithoutUSBStick.left;
                 right: buttonUpdateWithoutUSBStick.right; }
        height: root.rowHeight * 1.25
        width: rowWidth * 1.5
        visible: true
        Item {
            anchors.fill: parent
            Label {
                font.pointSize: root.pointSize * 1.125
                text: Z.tr("Notify on new releases:")
                textFormat: Text.PlainText
                height: parent.height
                anchors.left: parent.left
                verticalAlignment: Label.AlignVCenter
            }
            ZCheckBox {
                height: parent.height * 1.625
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                padding: 0
                checked: GC.notifyOnRelease
                onCheckedChanged: GC.setNotifyOnRelease(checked)
            }
        }
    }

    Connections {
        target: updateProcess
        function onSigUpstreamHasSameVersionAsInstalled() {
            versionGetOddResultPopup.text = Z.tr("Device has the latest release version")
            versionGetOddResultPopup.open()
        }
        function onSigUpstreamCheckFailed() {
            versionGetOddResultPopup.text = Z.tr("An error occurred retrieving release info.\nPlease check your network connection or try again later.")
            versionGetOddResultPopup.open()
        }
    }
    Popup {
        id: versionGetOddResultPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        readonly property real pointSize: parent.width * 0.02
        property alias text: textLabel.text
        ColumnLayout {
            anchors.fill: parent
            Label {
                id: textLabel
                font.pointSize: versionGetOddResultPopup.pointSize
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            ZButton {
                text: Z.tr("Close")
                font.pointSize: versionGetOddResultPopup.pointSize
                Layout.alignment: Qt.AlignHCenter
                onClicked: versionGetOddResultPopup.close()
            }
        }
    }
}
