import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import SortFilterProxyModel 0.2
import "qrc:/data/staticdata/FontAwesome.js" as FA

Item {
  id: root
  signal switchToViewMode();
  signal switchToEditMode();
  function searchFile() {
    if(selectedSearchField.text.length>0)
    {
      console.assert(searchProgressId === undefined, "Search in progress. todo: implement canceling pending search")
      searchResultData.clear();
      var searchMapData = ({});
      searchMapData[searchableProperties[searchFieldSelector.currentIndex]] = selectedSearchField.text
      searchProgressId = customerData.invokeRPC("customerDataSearch(QVariantMap searchMap)", { "searchMap": searchMapData })
    }
  }

  property bool noSearchResults: false;
  property var searchableProperties: [];
  property QtObject customerData: VeinEntity.getEntity("CustomerData")
  Connections {
    target: customerData
    onSigRPCFinished: {
      if(t_resultData["RemoteProcedureData::resultCode"] !== 0)
      {
        console.warn("RPC error:", t_resultData["RemoteProcedureData::errorMessage"]);
      }

      if(t_identifier === searchProgressId)
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
        searchResultData.append({"modelData":t_progressData["CustomerDataSystem::searchResult"]});
      }
    }
  }

  Popup {
    id: addFilePopup
    onOpened: filenameField.forceActiveFocus()
    onClosed: filenameField.clear()
    readonly property bool fileNameAlreadyExists: filenameField.text.length>0 && customerData.FileList.indexOf(filenameField.text.toLowerCase()+".json") > 0
    RowLayout {
      anchors.fill: parent
      Label {
        text: ZTR["File name:"]
      }
      Item {
        width: rowWidth/25
      }
      TextField {
        id: filenameField
        validator: RegExpValidator { regExp: /^[^.|"/`$!/\\<>:?~{}]+$/ }
        implicitWidth: Math.min(Math.max(rowWidth/5, contentWidth), rowWidth/2)
        selectByMouse: true
        Rectangle {
          anchors.fill: parent
          color: "red"
          opacity: 0.3
          visible: addFilePopup.fileNameAlreadyExists
        }
      }
      Label {
        text: ".json"
      }
      Item {
        Layout.fillWidth: true
        width: rowWidth/20
      }
      Button {
        text: ZTR["Save"]
        enabled: filenameField.text.length>0 && addFilePopup.fileNameAlreadyExists === false
        highlighted: true
        onClicked: {
          customerData.invokeRPC("customerDataAdd(QString fileName)", { "fileName": filenameField.text+".json" })
          customerData.FileSelected = filenameField.text+".json"
          addFilePopup.close()
          root.switchToEditMode();
        }
      }
      Button {
        text: ZTR["Close"]
        onClicked: {
          addFilePopup.close()
        }
      }
    }
  }

  Popup {
    id: removeFilePopup
    x: parent.width/2 - width/2
    modal: true
    dim: true
    property string fileName;
    onClosed: fileName="";
    Column {
      Label {
        text: ZTR["Really delete file <b>'%1'</b>?"].arg(removeFilePopup.fileName)
      }
      RowLayout {
        width: parent.width

        Button { ///todo: Qt 5.9 use DelayButton
          text: ZTR["Accept"]
          Material.accent: Material.color(Material.Red, Material.Shade500);
          highlighted: true
          onClicked: {
            customerData.invokeRPC("customerDataRemove(QString fileName)", { "fileName": removeFilePopup.fileName });
            removeFilePopup.close();
          }
        }
        Item {
          Layout.fillWidth: true
        }

        Button {
          text: ZTR["Close"]
          onClicked: {
            removeFilePopup.close()
          }
        }
      }
    }
  }

  property var searchProgressId;
  ListModel {
    id: searchResultData
  }

  RowLayout {
    id: topBar
    anchors.left: parent.left
    anchors.right: parent.right
    height: rowHeight*1.5;
    Button {
      text: FA.icon(FA.fa_file)+ZTR["New file"]
      font.family: "FontAwesome"
      topPadding: 0
      bottomPadding: 0
      implicitHeight: rowHeight*1.5
      onClicked: {
        addFilePopup.open()
      }
    }
    Item {
      Layout.fillWidth: true
    }
    ComboBox {
      id: searchFieldSelector
      model: searchableProperties
      implicitWidth: root.width/4
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.margins: 4
      displayText: ZTR[currentText]
      //flat: false


      ///@note qt 5.9 has a policy for scrollbars to be visible if required instead of the current "hiding if not scrolling" bullshit
      //...policy: ScrollBar.AsNeeded //or ScrollBar.AlwaysOn
      delegate: MenuItem {
        width: searchFieldSelector.popup.width
        text: searchFieldSelector.textRole ? (Array.isArray(searchFieldSelector.model) ? ZTR[modelData[searchFieldSelector.textRole]] : ZTR[model[searchFieldSelector.textRole]]) : ZTR[modelData]
        Material.foreground: searchFieldSelector.currentIndex === index ? searchFieldSelector.popup.Material.accent : searchFieldSelector.popup.Material.foreground
        highlighted: searchFieldSelector.highlightedIndex === index
        hoverEnabled: searchFieldSelector.hoverEnabled
      }
    }

    TextField {
      id: selectedSearchField
      placeholderText: "Regex search"
      selectByMouse: true
      anchors.top: parent.top
      implicitWidth: topBar.width/3
      onAccepted: root.searchFile();
      Rectangle {
        anchors.fill: parent
        color: "red"
        opacity: 0.2
        visible: root.noSearchResults == true
      }
    }
    Button {
      text: FA.icon(FA.fa_search)+ZTR["Search"]
      font.family: "FontAwesome"
      topPadding: 0
      bottomPadding: 0
      implicitHeight: rowHeight*1.5
      enabled: selectedSearchField.text.length>0 && searchProgressId === undefined
      onClicked: {
        root.noSearchResults = false;
        root.searchFile();
      }
    }
    Button {
      text: ZTR["Clear"]
      topPadding: 0
      bottomPadding: 0
      implicitHeight: rowHeight*1.5
      enabled: searchResultData.count>0 || root.noSearchResults === true
      onClicked: {
        root.noSearchResults = false;
        console.assert(searchProgressId === undefined, "Search in progress. todo: implement canceling pending search");
        selectedSearchField.clear();
        searchResultData.clear();
      }
    }
  }
  ListView {
    id: lvFileBrowser
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.top: topBar.bottom
    model: searchResultData.count > 0 ? searchResultData : customerData.FileList
    boundsBehavior: Flickable.StopAtBounds
    highlightFollowsCurrentItem: true
    currentIndex: customerData.FileList ? customerData.FileList.indexOf(customerData.FileSelected) : 0
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
      highlighted: ListView.isCurrentItem
      onClicked: {
        if(customerData.FileSelected !== modelData)
        {
          customerData.FileSelected = modelData
        }
      }
      onDoubleClicked: {
        root.switchToViewMode()
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        Label {
          text: modelData
          anchors.verticalCenter: parent.verticalCenter
        }
        Item {
          Layout.fillWidth: true
        }

        Button {
          text: FA.icon(FA.fa_trash)+ZTR["Delete file"]
          font.family: "FontAwesome"
          //padding: 0
          implicitHeight: rowHeight*1.5
          onClicked: {
            removeFilePopup.fileName = modelData
            removeFilePopup.open()
          }
        }
      }
    }
  }
}
