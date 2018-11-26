import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation 1.0

Popup {
  id: root

  dim: true
  modal: true
  closePolicy: Popup.NoAutoClose

  property var searchProgressId;
  property bool noSearchResults: false;
  readonly property QtObject loggerDB: VeinEntity.getEntity("_LoggingSystem")
  property int rowHeight: height/16;

  signal fileSelected(string t_file);

  //VF_RPC(findDBFile, "findDBFile(QString searchPath, QString searchPatternList)", "returns ZeraDBLogger::searchResult: A lists of available database files on the currently selected storage")

  function sendSearchRPC(searchPattern) {
    if(searchPattern !== undefined)
    {
      console.assert(searchProgressId === undefined, "Search already in progress.")
      var searchPatternArray = (Array.isArray(searchPattern) ? searchPattern : [searchPattern]);
      searchResultData.clear();
      searchProgressId = loggerDB.invokeRPC("findDBFile(QString searchPath, QString searchPatternList)", {
                                              "searchPath": dbLocationSelector.storageList[dbLocationSelector.currentIndex],
                                              "searchPatternList": searchPatternArray
                                            })
    }
  }

  function cancelSearchRPC() {
    if(searchProgressId !== undefined)
    {
      loggerDB.cancelRPCInvokation(searchProgressId);
    }
  }

  Connections {
    target: loggerDB
    onSigRPCFinished: {
      if(t_resultData["RemoteProcedureData::errorMessage"])
      {
        console.warn("RPC error:" << t_resultData["RemoteProcedureData::errorMessage"]);
      }

      if(t_resultData["RemoteProcedureData::resultCode"] === 4) //EINTR, the search was canceled
      {
        searchProgressId = undefined;
      }
      else if(t_identifier === searchProgressId)
      {
        if(searchResultData.count === 0)
        {
          noSearchResults=true;
        }

        searchProgressId = undefined;
      }
    }
    onSigRPCProgress: {
      if(t_identifier === searchProgressId)
      {
        searchResultData.append({"modelData":t_progressData["ZeraDBLogger::searchResultEntry"]});
      }
    }
  }

  LoggerDbLocationSelector {
    id: dbLocationSelector
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    rowHeight: root.rowHeight
    onCurrentIndexChanged: searchResultData.clear();
  }

  RowLayout {
    id: controlsTopSearchBar
    anchors.top: dbLocationSelector.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    Label {
      textFormat: Text.PlainText
      text: ZTR["Database filename:"]
      font.pixelSize: 20
    }

    Item {
      //spacer
      width: 48
    }

    TextField {
      id: tfSearchPattern
      text: "*";
      Layout.fillWidth: true;
      Rectangle {
        anchors.fill: parent
        color: "red"
        opacity: 0.2
        visible: root.noSearchResults == true
      }
    }

    Label {
      text: ".db";
    }

    Button {
      text: ZTR["Search"];
      enabled: searchProgressId === undefined && tfSearchPattern.text.length>0;
      onClicked: sendSearchRPC(tfSearchPattern.text+".db");
    }
    Button {
      text: ZTR["Cancel"];
      enabled: searchProgressId !== undefined;
    }
    Item {
      Layout.fillWidth: true
    }

    Button {
      text: ZTR["Close"];
      onClicked: root.close();
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
    anchors.top: controlsTopSearchBar.bottom
    model: searchResultData.count > 0 ? searchResultData : []
    boundsBehavior: Flickable.StopAtBounds
    highlightFollowsCurrentItem: true
    ScrollIndicator.vertical: ScrollIndicator {
      width: 8
      active: true
      onActiveChanged: {
        if(active !== true)
        {
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
          text: modelData
          Layout.alignment: Qt.AlignVCenter
        }
        Item {
          Layout.fillWidth: true
        }

        Button {
          text: ZTR["Select file"]
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
}
