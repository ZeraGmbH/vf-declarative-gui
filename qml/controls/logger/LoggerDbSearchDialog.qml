import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0

Popup {
    id: root
    closePolicy: Popup.NoAutoClose
    modal: !Qt.inputMethod.visible

    property var searchProgressId;
    property bool noSearchResults: false;
    readonly property QtObject loggerDB: VeinEntity.getEntity("_LoggingSystem")
    property int rowHeight: Qt.inputMethod.visible ? height/10 : height/20;

    signal fileSelected(string t_file);

    function sendSearchRPC(searchPattern) {
        if(searchPattern !== undefined) {
            console.assert(searchProgressId === undefined, "Search already in progress.")
            var searchPatternArray = (Array.isArray(searchPattern) ? searchPattern : [searchPattern]);
            searchResultData.clear();
            searchProgressId = loggerDB.invokeRPC("findDBFile(QString searchPath, QStringList searchPatternList)", {
                                                      "searchPath": dbLocationSelector.currentPath,
                                                      "searchPatternList": searchPatternArray
                                                  })
        }
    }

    function cancelSearchRPC() {
        if(searchProgressId !== undefined) {
            loggerDB.cancelRPCInvokation(searchProgressId);
        }
    }

    Connections {
        target: loggerDB
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
                searchResultData.append({"modelData":t_progressData["ZeraDBLogger::searchResultEntry"]});
            }
        }
    }

    LoggerDbLocationSelector {
        id: dbLocationSelector
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
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

        Label {
            textFormat: Text.PlainText
            text: Z.tr("Database filename:")
            font.pointSize: 20
        }

        BusyIndicator {
            //spacer
            width: 48
            opacity: 1.0 * (searchProgressId !== undefined)
        }

        // No ZLineEdit due to different RETURN/ESC/redBackground handling
        TextField {
            id: tfSearchPattern
            text: "*";
            Layout.fillWidth: true;
            bottomPadding: GC.standardTextBottomMargin
            inputMethodHints: Qt.ImhNoAutoUppercase
            Keys.onEscapePressed: {
                focus = false
            }
            onAccepted: {
                sendSearchRPC(text+".db");
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
        }

        Button {
            text: Z.tr("Search");
            enabled: searchProgressId === undefined && tfSearchPattern.text.length>0;
            onClicked: sendSearchRPC(tfSearchPattern.text+".db");
        }
        Button {
            text: Z.tr("Cancel");
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
        anchors.bottom: closeButtonContainer.top
        anchors.bottomMargin: root.bottomMargin
        anchors.top: controlsTopSearchBar.bottom
        model: searchResultData.count > 0 ? searchResultData : []
        boundsBehavior: Flickable.StopAtBounds
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
            width: parent.width-8 //don't overlap with the ScrollIndicator
            height: rowHeight*1.5
            readonly property bool isHighlighted: highlighted;

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4

                Label {
                    text: String(modelData).replace(dbLocationSelector.currentPath + "/", "")
                    Layout.alignment: Qt.AlignVCenter
                }
                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: Z.tr("Select file")
                    //padding: 0
                    implicitHeight: rowHeight*1.5
                    onClicked: {
                        root.fileSelected(modelData);
                        root.close();
                    }
                }
            }
        }
    }
    Item {
        id: closeButtonContainer
        anchors.bottom: parent.bottom
        height: root.rowHeight*2
        width: root.width
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: Z.tr("Close");
            onClicked: root.close();
            font.pointSize: root.rowHeight
        }
    }
}
