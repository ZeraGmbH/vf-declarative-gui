import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import QtQuick.Layouts 1.14
import ZeraTranslation  1.0
import anmsettings 1.0

Item {
    id: root
    property int port
    property bool show
    property string prefix

    InfoInterface { id: networkListModel }
    readonly property bool isNetworkConnected: networkListModel.entryCount > 0
    readonly property real pointSize: height > 0 ? height * 0.3 : 1
    readonly property real horizonalTextMargin: height * 0.3

    Rectangle {
        anchors.fill: parent

        visible: show
        color: Material.backgroundDimColor
        radius: 4

        ListView {
            id: ipList
            clip: true
            visible: isNetworkConnected
            anchors { fill: parent; verticalCenter: parent.verticalCenter;
                      leftMargin: horizonalTextMargin;
                      rightMargin: horizonalTextMargin}
            boundsBehavior: Flickable.OvershootBounds
            orientation: ListView.Horizontal
            spacing: horizonalTextMargin
            model: networkListModel
            delegate: Text {
                height: parent.height
                leftPadding: 5
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: pointSize
                textFormat: Text.PlainText
                text: prefix + ipv4 + ":" + port
            }
        }
        Text {
            id: notConnectedDisplay
            visible: !isNetworkConnected
            anchors { fill: parent; verticalCenter: parent.verticalCenter;
                      leftMargin: horizonalTextMargin;
                      rightMargin: horizonalTextMargin }
            verticalAlignment: Text.AlignVCenter
            text: Z.tr("Not connected")
            font.pointSize: pointSize
        }
    }
}
