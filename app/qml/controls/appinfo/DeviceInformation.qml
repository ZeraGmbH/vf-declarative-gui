import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import ZeraTranslation  1.0
import DeviceVersions 1.0
import '../../controls'
import QmlFileIO 1.0

Item {
    id: root

    readonly property real rowHeight: height > 0 ? height/(saveButtonHeightRows+DevVersions.allVersionsTr.length) : 10
    readonly property real saveButtonHeightRows: 2
    readonly property real pointSize: rowHeight * 0.7

    property var versionMap: ({})
    function appendVersions(strLabel, version) {
        versionMap[strLabel] = version
    }

    WaitTransaction {
        id: waitPopup
        animationComponent: AnimationSlowBits { }
    }

    VisualItemModel {
        id: statusModel

        RowLayout {
            width: parent.width
            height: root.rowHeight * saveButtonHeightRows
            Button {
                id: buttonStoreLog
                font.pointSize: root.pointSize
                text: Z.tr("Save logfile to USB")
                readonly property bool writingLogsToUsb: QmlFileIO.writingLogsToUsb
                enabled: (QmlFileIO.mountedPaths.length > 0) && !writingLogsToUsb
                highlighted: true
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    QmlFileIO.startWriteJournalctlOnUsb(root.versionMap, GC.serverIp)
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
        }

        ColumnLayout {
            width: parent.width
            Repeater {
                id: repeaterPCBVersions
                model: DevVersions.allVersionsTr
                RowLayout {
                    height: root.rowHeight
                    Label {
                        font.pointSize: root.pointSize
                        text: modelData[0] + ":"
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Label {
                        font.pointSize: root.pointSize
                        text: modelData[1]
                    }
                }
            }
        }
    }

    ListView {
        id: statusListView
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: rowHeight/2
        model: statusModel
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: rightScrollbar
    }
    ScrollBar {
        id: rightScrollbar
        anchors.left: statusListView.right
        anchors.top: statusListView.top
        anchors.bottom: statusListView.bottom
        anchors.leftMargin: parent.width/80
        visible: statusListView.contentHeight>statusListView.height
        Component.onCompleted: {
            policy = ScrollBar.AlwaysOn;
        }
    }
}
