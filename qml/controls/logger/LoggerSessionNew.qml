import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0


Item {
    id: root
    // we need a reference to menu stack layout to move around
    property var menuStackLayout

    readonly property real rowHeight: parent.height/12
    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10

    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")

    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Add new session")
        font.pointSize: root.pointSize * 1.5
    }


    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.bottom: parent.bottom


        Item { // spacer
            Layout.fillHeight: true
        }
        RowLayout { // Cancel / OK buttons
            id: cancelOKRow
            Item {
                id: spacerItem
                Layout.fillWidth: true
            }
            Button {
                id: cancelButton
                text: Z.tr("Cancel")
                font.pointSize: root.pointSize
                onClicked: {
                    // go back
                    menuStackLayout.showSessionNameSelector()
                }
            }
            Button {
                id: okButton
                text: Z.tr("OK")
                font.pointSize: root.pointSize
                Layout.minimumWidth: cancelButton.width
                onClicked: {
                    // TODO
                    menuStackLayout.pleaseCloseMe(true)
                }
            }
        }
    }
}
