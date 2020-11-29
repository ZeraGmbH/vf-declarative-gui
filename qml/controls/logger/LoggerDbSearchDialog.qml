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

    property var searchProgressId;
    property bool noSearchResults: false;
    readonly property QtObject loggerEntity: VeinEntity.getEntity("_LoggingSystem")
    readonly property QtObject filesEntity: VeinEntity.getEntity("_Files")

    function sendSearchRPC(searchPattern) {
        if(searchPattern !== undefined) {
            console.assert(searchProgressId === undefined, "Search already in progress.")
            var searchPatternArray = (Array.isArray(searchPattern) ? searchPattern : [searchPattern]);
            searchResultData.clear();
            searchProgressId = loggerEntity.invokeRPC("findDBFile(QString searchPath, QStringList searchPatternList)", {
                                                      "searchPath": dbLocationSelector.currentPath,
                                                      "searchPatternList": searchPatternArray
                                                  })
        }
    }
    function cancelSearchRPC() {
        if(searchProgressId !== undefined) {
            loggerEntity.cancelRPCInvokation(searchProgressId);
        }
    }
    Connections {
        target: loggerEntity
        onSigRPCFinished: {
            if(t_resultData["RemoteProcedureData::errorMessage"]) {
                console.warn("RPC error:" << t_resultData["RemoteProcedureData::errorMessage"]);
            }

            if(t_resultData["RemoteProcedureData::resultCode"] === 4) { //EINTR, the search was canceled
                searchProgressId = undefined;
            }
            else if(t_identifier === searchProgressId) {
                noSearchResults = searchResultData.count === 0
                searchProgressId = undefined;
            }
        }
        onSigRPCProgress: {
            if(t_identifier === searchProgressId) {
                // TODO sort
                searchResultData.append({"modelData":t_progressData["ZeraDBLogger::searchResultEntry"]});
            }
        }
    }

    property var deleteRpcId
    function startDbDeleteRpc(removeDbName) {
        // is it current db
        if(removeDbName === loggerEntity.DatabaseFile) {
            loggerEntity.DatabaseFile = ""
            GC.setCurrDatabaseFileName("")
            GC.setCurrDatabaseSessionName("")
        }
        if(!deleteRpcId) {
            deleteRpcId = filesEntity.invokeRPC("RPC_DeleteFile(QString p_fullPathFile)", {
                                                "p_fullPathFile": removeDbName })
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
                    // TODO update model without researching
                    removeDbPopup.close();
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
            searchResultData.clear();
            sendSearchRPC(tfSearchPattern.text+".db");
        }
    }

    RowLayout {
        id: controlsTopSearchBar
        anchors.top: dbLocationSelector.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin:  GC.standardTextHorizMargin
        anchors.rightMargin:  GC.standardTextHorizMargin
        Label {
            textFormat: Text.PlainText
            text: Z.tr("Database filename:")
            font.pointSize: pointSize
        }
        BusyIndicator {
            Layout.preferredWidth: (searchProgressId !== undefined) ? rowHeight / 2 : 0 // witdth == height
            opacity: 1.0 * (searchProgressId !== undefined)
        }
        // No ZLineEdit due to different RETURN/ESC/redBackground handling
        TextField {
            id: tfSearchPattern
            text: "*";
            font.pointSize: pointSize
            horizontalAlignment: Text.AlignRight
            Layout.fillWidth: true
            bottomPadding: GC.standardTextBottomMargin
            inputMethodHints: Qt.ImhNoAutoUppercase
            Keys.onEscapePressed: {
                focus = false
            }
            onAccepted: {
                sendSearchRPC(text+".db")
                focus = false
            }
            Rectangle {
                anchors.fill: parent
                color: "red"
                opacity: 0.2
                visible: root.noSearchResults === true
            }
        }
        Label {
            text: ".db";
            font.pointSize: pointSize
        }
        Button {
            text: Z.tr("Search");
            font.pointSize: pointSize
            enabled: searchProgressId === undefined && tfSearchPattern.text.length>0;
            onClicked: sendSearchRPC(tfSearchPattern.text+".db");
        }
        Button {
            text: Z.tr("Cancel");
            font.pointSize: pointSize
            enabled: searchProgressId !== undefined;
        }
    }

    ListModel {
        id: searchResultData
    }
    ListView {
        id: lvFileBrowser
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.bottomMargin
        anchors.top: controlsTopSearchBar.bottom
        model: searchResultData.count > 0 ? searchResultData : []
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
                Button {
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
                        menuStackLayout.goBack()
                    }
                }
                Button {
                    Layout.preferredWidth: rowHeight * 2
                    Layout.fillHeight: true
                    font.family: FA.old
                    font.pointSize: pointSize * 1.25
                    text: FA.fa_trash
                    background: Rectangle {
                        color: "transparent"
                    }
                    onClicked: {
                        if(modelData === loggerEntity.DatabaseFile) {
                            loggerEntity.DatabaseFile = ""
                        }
                        removeDbPopup.removeDbName = modelData
                        removeDbPopup.open()
                    }
                }
            }
        }
    }
}
