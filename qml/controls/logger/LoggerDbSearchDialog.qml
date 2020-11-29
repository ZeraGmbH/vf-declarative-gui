import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import ZeraFa 1.0

Item {
    id: root

    // we need a reference to menu stack layout to move around
    property var menuStackLayout

    property real rowHeight: height/8
    readonly property real fontScale: 0.25
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10
    readonly property real pointSizeHeader: pointSize * 1.25

    property var searchRpcId;
    property bool noSearchResults: false;
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")

    // RPC_FindFileSpecial handling
    property var foundFiles: []
    function startRpcSearch() {
        if(!searchRpcId) {
            searchRpcId = filesEntity.invokeRPC("RPC_FindFileSpecial(QString p_baseDir,QStringList p_nameFilterList,bool p_returnMatchingDirsOnly)", {
                                                "p_baseDir": dbLocationSelector.currentPath,
                                                "p_nameFilterList": [ "*.db" ],
                                                "p_returnMatchingDirsOnly": false})
        }
        else {
            console.warn("RPC_FindFileSpecial already running")
        }
    }
    // RPC_FindFileSpecial handling
    property var deleteRpcId
    function startDbDeleteRpc(removeDbName) {
        if(!deleteRpcId) {
            deleteRpcId = filesEntity.invokeRPC("RPC_DeleteFile(QString p_fullPathFile)", {
                                                "p_fullPathFile": removeDbName })
        }
        else {
            console.warn("RPC_DeleteFile already running")
        }
    }
    Connections {
        target: filesEntity
        onSigRPCFinished: {
            // TODO error handling
            if(t_identifier === deleteRpcId) {
                deleteRpcId = undefined
                if(t_resultData["RemoteProcedureData::resultCode"] === 0 &&
                        t_resultData["RemoteProcedureData::Return"] === true) { // ok
                    // Update model without researching - we trust RPC
                    var tmpfoundFiles = foundFiles // splice on foundFiles does not cause redraw
                    var delIdx = tmpfoundFiles.indexOf(removeDbPopup.removeDbName)
                    if(delIdx >= 0) {
                        tmpfoundFiles.splice(delIdx, 1);
                        foundFiles = tmpfoundFiles
                    }
                    removeDbPopup.close();
                }
            }
            if(t_identifier === searchRpcId) {
                searchRpcId = undefined
                if(t_resultData["RemoteProcedureData::resultCode"] === 0) {
                    foundFiles = t_resultData["RemoteProcedureData::Return"]
                }
            }
        }
    }

    Popup {
        id: removeDbPopup
        anchors.centerIn: parent
        modal: true
        property string removeDbName;

        ColumnLayout {
            Label { // header
                text: Z.tr("Confirmation")
                font.pointSize: pointSizeHeader
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item { Layout.preferredHeight: rowHeight/3 }
            Label {
                text: {
                    var dbFileName = removeDbPopup.removeDbName.replace(dbLocationSelector.currentPath, "")
                    if(dbFileName.startsWith('/')) {
                        dbFileName = dbFileName.substring(1)
                    }
                    return Z.tr("Delete database <b>'%1'</b>?").arg(dbFileName)
                }
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
                        removeDbPopup.close()
                    }
                }
                Button {
                    text: "<font color='red'>" + Z.tr("Delete") + "</font>"
                    font.pointSize: pointSize
                    Layout.preferredWidth: removeCancel.width
                    onClicked: {
                        // is it current db
                        if(removeDbPopup.removeDbName === loggerEntity.DatabaseFile) {
                            loggerEntity.DatabaseFile = ""
                            GC.setCurrDatabaseFileName("")
                            GC.setCurrDatabaseSessionName("")
                        }
                        startDbDeleteRpc(removeDbPopup.removeDbName)
                    }
                }
            }
        }
    }

    // and the visible items
    Label { // Header
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Databases")
        font.pointSize: pointSizeHeader
        height: rowHeight
    }
    LoggerDbLocationSelector {
        id: dbLocationSelector
        pointSize: root.pointSize // root is required here
        anchors.top: captionLabel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin:  GC.standardTextHorizMargin
        anchors.rightMargin:  GC.standardTextHorizMargin
        onCurrentPathChanged: {
            startRpcSearch()
        }
    }

    ListView {
        id: lvFileBrowser
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin:  GC.standardTextHorizMargin
        anchors.rightMargin:  GC.standardTextHorizMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.bottomMargin
        anchors.top: dbLocationSelector.bottom
        model: foundFiles
        highlightFollowsCurrentItem: true
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
        delegate: ItemDelegate {
            width: parent.width - (lvFileBrowser.contentHeight > lvFileBrowser.height ? 8 : 0) // don't overlap with the ScrollIndicator
            readonly property bool isHighlighted: highlighted;

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4

                Label {
                    id: activeIndicator
                    font.family: FA.old
                    font.pointSize: root.pointSize
                    horizontalAlignment: Text.AlignLeft
                    text: FA.fa_check
                    opacity: modelData === loggerEntity.DatabaseFile ? 1.0 : 0.0
                    Layout.preferredWidth: root.pointSize * 1.5
                }
                Label {
                    text: {
                        var newText = String(modelData).replace(dbLocationSelector.currentPath, "")
                        if(newText.startsWith('/')) {
                            newText = newText.substring(1)
                        }
                        return newText
                    }
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                }
                Button { // Make current
                    font.family: FA.old
                    font.pointSize: pointSize * 1.25
                    text: FA.fa_check_circle
                    property bool isCurrent: modelData === loggerEntity.DatabaseFile
                    opacity: isCurrent ? 0.0 : 1.0
                    background: Rectangle {
                        color: "transparent"
                    }
                    onClicked: {
                        loggerEntity.DatabaseFile = modelData
                        GC.setCurrDatabaseFileName(modelData)
                        GC.setCurrDatabaseSessionName("")
                        menuStackLayout.pleaseCloseMe(true)
                    }
                }
                Button { // delete
                    Layout.preferredWidth: rowHeight * 2
                    Layout.fillHeight: true
                    font.family: FA.old
                    font.pointSize: pointSize * 1.25
                    text: FA.fa_trash
                    background: Rectangle {
                        color: "transparent"
                    }
                    onClicked: {
                        removeDbPopup.removeDbName = modelData
                        removeDbPopup.open()
                    }
                }
            }
        }
    }
}
