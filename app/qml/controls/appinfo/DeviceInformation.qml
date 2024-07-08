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
    readonly property real rowHeight: height > 0 ? height * 0.0725 : 10
    readonly property real pointSize: rowHeight * 0.5

    WaitTransaction {
        id: waitPopup
        animationComponent: AnimationSlowBits { }
    }

    Button {
        id: buttonStoreLog
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        font.pointSize: root.pointSize
        height: root.rowHeight * 1.625
        implicitWidth: implicitContentWidth * 1.2
        text: Z.tr("Save logfile to USB")
        readonly property bool writingLogsToUsb: QmlFileIO.writingLogsToUsb
        enabled: (QmlFileIO.mountedPaths.length > 0) && !writingLogsToUsb
        highlighted: true
        onClicked: {
            QmlFileIO.startWriteJournalctlOnUsb(DevVersions.allVersionsForStore, GC.serverIp)
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

    ListView {
        id: statusListView
        anchors { top: buttonStoreLog.bottom; bottom: parent.bottom; left: parent.left; right: rightScrollbar.left }
        anchors { leftMargin: root.width * 0.01; rightMargin: root.width * 0.01 }
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: rightScrollbar
        model: DevVersions.allVersionsForDisplay
        delegate: RowLayout {
            height: root.rowHeight
            width: statusListView.width
            Label {
                font.pointSize: root.pointSize
                text: modelData[0] + ":"
            }
            Item { Layout.fillWidth: true }
            Label {
                font.pointSize: root.pointSize
                text: modelData[1]
            }
        }
    }
    ScrollBar {
        id: rightScrollbar
        anchors.right: parent.right
        anchors.top: statusListView.top
        anchors.bottom: statusListView.bottom
        policy: ScrollBar.AlwaysOn
        width: statusListView.contentHeight>statusListView.height ? root.width * 0.01 : 0
    }
}
