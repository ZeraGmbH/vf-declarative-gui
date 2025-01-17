import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import FontAwesomeQml 1.0

Item {
    id: root
    // we need a reference to menu stack layout to move around
    property var menuStackLayout
    // how are we closing: true: go back to export view / false: show logger menu
    property bool goBackExport: false

    property real rowHeight: height/8
    readonly property real fontScale: 0.30
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real pointSizeHeader: pointSize * 1.25

    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property var existingSessions: loggerEntity.ExistingSessions.sort()
    readonly property string currentSessionName: loggerEntity.sessionName
    onCurrentSessionNameChanged: {
        selectorDelayHelper.restart() // immediate selection does not work
    }
    Timer {
        id: selectorDelayHelper
        interval: 300; repeat: false
        onTriggered: {
            existingList.currentIndex = existingSessions.indexOf(currentSessionName)
        }
    }

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
                text: Z.tr("Confirmation")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            Label {
                text: Z.tr("Delete session <b>'%1'</b>?").arg(removeSessionPopup.sessionToDelete)
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
                    text: "<font color='red'>" + Z.tr("Delete") + "</font>"
                    font.pointSize: pointSize
                    Layout.preferredWidth: removeCancel.width
                    onClicked: {
                        if(!removeSessionPopup.rpcIDRemoveSession) {
                            removeSessionPopup.rpcIDRemoveSession = loggerEntity.invokeRPC("RPC_deleteSession(QString p_session)", {
                                                                                "p_session": removeSessionPopup.sessionToDelete })
                            removeSessionPopup.close()
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
        anchors.bottom: goBackExport ? parent.bottom : buttonAdd.top
        Label {
            text: Z.tr("Select existing:");
            font.pointSize: root.pointSize
            visible: existingList.visible
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: Material.dialogColor
            ListView {
                id: existingList
                anchors.fill: parent
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
                model: existingSessions

                delegate: ItemDelegate {
                    anchors.left: parent.left
                    width: parent.width - (existingList.contentHeight > existingList.height ? 8 : 0) //don't overlap with the ScrollIndicator
                    height: root.rowHeight
                    //highlighted: ListView.isCurrentItem
                    RowLayout {
                        anchors.fill: parent
                        Label {
                            id: activeIndicator
                            font.pointSize: root.pointSize
                            horizontalAlignment: Text.AlignLeft
                            text: FAQ.fa_check
                            opacity: (modelData === currentSessionName) ? 1.0 : 0.0
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
                            font.pointSize: pointSize * 1.25
                            text: FAQ.fa_trash
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
                        if(goBackExport)
                            menuStackLayout.showExportView()
                        else
                            menuStackLayout.pleaseCloseMe(true)
                    }
                }
            }
        }
    }

    Button {
        id: buttonAdd
        // when coming from export it does not make sense to add a
        // new (=empty) session and export it
        visible: !goBackExport
        text: "+"
        font.pointSize: root.pointSize
        width: buttonBack.width
        anchors { left: parent.left; leftMargin: GC.standardTextHorizMargin; bottom: parent.bottom }
        onClicked: menuStackLayout.showSessionNew()
    }
    Button {
        id: buttonBack
        visible: !goBackExport
        text: Z.tr("Back")
        font.pointSize: root.pointSize
        anchors { right: parent.right; rightMargin: GC.standardTextHorizMargin; bottom: parent.bottom }
        onClicked: menuStackLayout.pleaseCloseMe(true)
    }
}
