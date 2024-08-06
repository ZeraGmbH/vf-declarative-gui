import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.14
import GlobalConfig 1.0
import ZeraTranslation  1.0
import DeviceVersions 1.0

Rectangle {
    id: root
    readonly property real rowHeight: height > 0 ? height * 0.0725 : 10
    readonly property real pointSize: rowHeight * 0.5
    color: Material.backgroundColor

    ListView {
        id: statusListView
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: rightScrollbar.left }
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
