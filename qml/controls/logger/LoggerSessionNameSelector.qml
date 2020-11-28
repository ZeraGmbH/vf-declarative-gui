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

    property real rowHeight: height/8
    readonly property real fontScale: 0.30
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real pointSizeHeader: pointSize * 1.25

    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")

    Popup {
        id: removeSessionPopup
        anchors.centerIn: parent
        modal: true
        property string sessionToDelete
        property var rpcIDRemoveSession
        Connections {
            target: loggerEntity
            onSigRPCFinished: {
                // TODO error handling
                if(t_identifier === removeSessionPopup.rpcIDRemoveSession) {
                    removeSessionPopup.rpcIDRemoveSession = undefined
                    if(t_resultData["RemoteProcedureData::resultCode"] === 0 &&
                            t_resultData["RemoteProcedureData::Return"] === true) { // ok
                        removeSessionPopup.close();
                    }
                }
            }
        }
        ColumnLayout {
            Label { // header
                text: Z.tr("Delete session")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            Label {
                text: Z.tr("Please confirm that you want to delete session <b>'%1'</b>").arg(removeSessionPopup.sessionToDelete)
                Layout.fillWidth: true
                font.pointSize: pointSize
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                Button {
                    id: removeCancel
                    text: Z.tr("Cancel")
                    font.pointSize: pointSize
                    onClicked: {
                        removeSessionPopup.close()
                    }
                }
                Button {
                    text: "<font color='red'>" + Z.tr("OK") + "</font>"
                    font.pointSize: pointSize
                    Layout.preferredWidth: removeCancel.width
                    onClicked: {
                        if(!removeSessionPopup.rpcIDRemoveSession) {
                            removeSessionPopup.rpcIDRemoveSession = loggerEntity.invokeRPC("RPC_deleteSession(QString p_session)", {
                                                                                "p_session": removeSessionPopup.sessionToDelete })
                        }
                    }
                }
            }
        }
    }


    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Select session name")
        font.pointSize: pointSizeHeader
    }
    ColumnLayout {
        id: selectionColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: GC.standardTextHorizMargin
        anchors.leftMargin: GC.standardTextHorizMargin
        anchors.top: captionLabel.bottom
        anchors.topMargin: rowHeight / 2
        anchors.bottom: buttonAdd.top
        Label {
            text: Z.tr("Select existing:");
            font.pointSize: root.pointSize
            visible: existingList.visible
        }
        ListView {
            id: existingList
            Layout.fillHeight: true
            Layout.fillWidth: true
            currentIndex: model ? model.indexOf(loggerEntity.sessionName) : -1
            clip: true
            ScrollIndicator.vertical: ScrollIndicator {
                width: 8
                active: true
                onActiveChanged: {
                    if(active !== true) {
                        active = true;
                    }
                }
            }
            model: loggerEntity.ExistingSessions.sort()

            delegate: ItemDelegate {
                anchors.left: parent.left
                width: parent.width - (existingList.contentHeight > existingList.height ? 8 : 0) //don't overlap with the ScrollIndicator
                height: root.rowHeight
                highlighted: ListView.isCurrentItem
                RowLayout {
                    anchors.fill: parent
                    Label {
                        id: activeIndicator
                        font.family: FA.old
                        font.pointSize: root.pointSize
                        horizontalAlignment: Text.AlignLeft
                        text: FA.fa_check
                        opacity: (modelData === loggerEntity.sessionName) ? 1.0 : 0.0
                        Layout.preferredWidth: root.pointSize * 1.5
                    }
                    Label {
                        font.pointSize: root.pointSize
                        horizontalAlignment: Text.AlignLeft
                        text: modelData
                        Layout.fillWidth: true
                    }
                    Button {
                        Layout.preferredWidth: rowHeight * 2
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        font.family: FA.old
                        font.pointSize: pointSize * 1.25
                        text: FA.fa_trash
                        background: Rectangle {
                            color: "transparent"
                        }
                        onClicked: {
                            removeSessionPopup.sessionToDelete = modelData
                            removeSessionPopup.open()
                        }
                    }
                }
                onClicked: {
                    if(loggerEntity.sessionName !== modelData) {
                        loggerEntity.sessionName = modelData
                        GC.setCurrDatabaseSessionName(modelData)
                    }
                }
            }
        }
    }
    Button {
        id: buttonAdd
        text: "+"
        anchors.bottom: parent.bottom
        onClicked: {
            menuStackLayout.showSessionNew()
        }
    }
}
