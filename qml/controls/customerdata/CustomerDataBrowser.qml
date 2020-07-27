import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import SortFilterProxyModel 0.2
import GlobalConfig 1.0
import ZeraComponents 1.0
import "qrc:/qml/controls" as CCMP
import ZeraFa 1.0

Item {
  id: root

  // 'public' properties
  property bool withOKButton: false

  // 'private' properties
  property var searchableProperties: [];
  property QtObject customerData: VeinEntity.getEntity("CustomerData")
  property var searchProgressId;
  property real rowHeight: height/11 // 11 lines total
  // Same as CustomerDataEntry 'Save' / 'Close'
  property real buttonWidth: width/4;
  // Used by file-list and filter-combobox
  property real indicatorWidth: 24

  function searchFile() {
    if(selectedSearchField.text.length>0)
    {
      console.assert(searchProgressId === undefined, "Search in progress. todo: implement canceling pending search")
      searchResultData.containsSelected = false
      searchResultData.clear();
      var searchMapData = ({});
      searchMapData[searchableProperties[searchFieldSelector.currentIndex]] = selectedSearchField.text
      searchProgressId = customerData.invokeRPC("customerDataSearch(QVariantMap searchMap)", { "searchMap": searchMapData })
    }
  }

  function saveChanges() {
    customerData.invokeRPC("customerDataAdd(QString fileName)", { "fileName": filenameField.text+".json" })
    customerData.FileSelected = filenameField.text+".json"
    addFilePopup.close()
    switchToEditMode();
  }

  signal switchToEditMode();
  signal ok();
  signal cancel();

  // for file listview & filter
  ListModel {
    id: searchResultData
    // True if search for customer data files did not find matching
    property bool noSearchResults: false;
    // True if search for customer data files contains selected
    property bool containsSelected: false
  }

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
          searchResultData.noSearchResults=true;
        }

        searchProgressId = undefined;
      }
    }
    onSigRPCProgress: {
      if(t_identifier === searchProgressId)
      {
        var name = t_progressData["CustomerDataSystem::searchResult"]
        searchResultData.append({"modelData":name});
        if(name === customerData.FileSelected)
          searchResultData.containsSelected = true
      }
    }
  }

  Popup {
    id: addFilePopup
    closePolicy: Popup.NoAutoClose

    readonly property bool fileNameAlreadyExists: filenameField.text.length>0 && customerData.FileList !== undefined && customerData.FileList.indexOf(filenameField.text.toLowerCase()+".json") >= 0

    onOpened: filenameField.forceActiveFocus()
    onClosed: filenameField.clear()
    RowLayout {
      anchors.fill: parent
      Label {
        text: Z.tr("File name:")
      }
      Item {
        width: rowWidth/25
      }
      // No ZLineEdit due to different RETURN/ESC/redBackground handling
      TextField {
        id: filenameField
        validator: RegExpValidator { regExp: /^[^.|"/`$!/\\<>:?~{}]+$/ }
        implicitWidth: Math.min(Math.max(rowWidth/5, contentWidth), rowWidth/2)
        bottomPadding: GC.standardTextBottomMargin
        selectByMouse: true
        inputMethodHints: Qt.ImhNoAutoUppercase
        Rectangle {
          anchors.fill: parent
          color: "red"
          opacity: 0.3
          visible: addFilePopup.fileNameAlreadyExists
        }
        onAccepted: {
          root.saveChanges()
        }
        Keys.onEscapePressed: {
          addFilePopup.close()
        }
      }
      Label {
        text: ".json"
      }
      Item {
        Layout.fillWidth: true
        width: rowWidth/20
      }
      ZButton {
        text: Z.tr("OK")
        width: newFileCancel.width
        enabled: filenameField.text.length>0 && addFilePopup.fileNameAlreadyExists === false
        //highlighted: true
        onClicked: {
          root.saveChanges()
        }
      }
      ZButton {
        id: newFileCancel
        text: Z.tr("Cancel")
        onClicked: {
          addFilePopup.close()
        }
      }
    }
  }

  Popup {
    id: removeFilePopup

    property string fileName;

    x: parent.width/2 - width/2
    modal: true
    dim: true
    onClosed: fileName="";
    Column {
      Label {
        text: Z.tr("Really delete file <b>'%1'</b>?").arg(removeFilePopup.fileName)
      }
      RowLayout {
        width: parent.width

        Button { ///todo: Qt 5.9 use DelayButton
          text: Z.tr("Accept")
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
          text: Z.tr("Close")
          onClicked: {
            removeFilePopup.close()
          }
        }
      }
    }
  }

  // For rookies like me: here starts view we see by default
  Rectangle {
    id: rectFiles
    color: "transparent"
    border.color: Material.dividerColor
    anchors.top: parent.top
    height: root.rowHeight*8
    width: root.width

    Label {
      textFormat: Text.PlainText
      anchors.left: parent.left
      anchors.leftMargin: GC.standardTextHorizMargin
      anchors.top: parent.top
      height: root.rowHeight
      text: Z.tr("Customer data files:")
      verticalAlignment: Text.AlignVCenter
      font.pixelSize: root.rowHeight/2
    }

    ListView {
      id: lvFileBrowser
      anchors.fill: parent
      anchors.topMargin: root.rowHeight
      anchors.rightMargin: root.buttonWidth+GC.standardTextHorizMargin
      model: searchResultData.count > 0 ? searchResultData : customerData.FileList
      boundsBehavior: Flickable.StopAtBounds
      highlightFollowsCurrentItem: true
      currentIndex: customerData.FileList ? customerData.FileList.indexOf(customerData.FileSelected) : 0
      clip: true

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
        id: fileListDelegate
        width: parent.width-8 //don't overlap with the ScrollIndicator
        height: rowHeight
        highlighted: ListView.isCurrentItem
        onClicked: {
          if(customerData.FileSelected !== modelData)
          {
            customerData.FileSelected = modelData
            if(searchResultData.count !== 0)
                searchResultData.containsSelected = true
          }
        }
        onDoubleClicked: {
          root.switchToEditMode()
        }

        Row {
          id: fileRow
          anchors.fill: parent
          anchors.leftMargin: GC.standardTextHorizMargin
          Label {
            id: activeIndicator
            width: indicatorWidth
            font.family: FA.old
            text: FA.fa_chevron_right
            opacity: (modelData === customerData.FileSelected)? 1.0 : 0.0
            anchors.verticalCenter: parent.verticalCenter
          }

          Label {
            x: indicatorWidth+GC.standardTextHorizMargin
            width: parent.width - root.buttonWidth - 2*GC.standardTextHorizMargin
            text: modelData
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }
    }
    ZButton {
      text: FA.icon(FA.fa_file)+Z.tr("New")
      font.family: FA.old

      anchors.right: parent.right
      width: root.buttonWidth

      anchors.top: parent.top
      anchors.topMargin: 1.5*rowHeight
      height: rowHeight

      onClicked: {
        addFilePopup.open()
      }
    }
    ZButton {
      text: FA.icon(FA.fa_edit)+Z.tr("Edit")
      font.family: FA.old

      anchors.right: parent.right
      width: root.buttonWidth

      anchors.top: parent.top
      anchors.topMargin: 4*rowHeight
      height: rowHeight

      enabled: customerData.FileSelected !== "" && (searchResultData.count === 0 || searchResultData.containsSelected)

      onClicked: {
        switchToEditMode()
      }
    }
    ZButton {
      text: FA.icon(FA.fa_trash)+Z.tr("Delete")
      font.family: FA.old

      anchors.right: parent.right
      width: root.buttonWidth

      anchors.top: parent.top
      anchors.topMargin: 6.5*rowHeight
      height: rowHeight

      enabled: customerData.FileSelected !== "" && (searchResultData.count === 0 || searchResultData.containsSelected)

      onClicked: {
        removeFilePopup.fileName = lvFileBrowser.model[lvFileBrowser.currentIndex].toString();
        removeFilePopup.open()
      }
    }

  }
  Rectangle {
    id: rectFilter
    color: "transparent"
    border.color: Material.dividerColor
    anchors.top: rectFiles.bottom
    height: root.rowHeight*2
    width: root.width
    property real comboTextVertOffset : -height * 0.05
    function clearSearch() {
      searchResultData.noSearchResults = false;
      console.assert(searchProgressId === undefined, "Search in progress. todo: implement canceling pending search");
      selectedSearchField.clear();
      searchResultData.clear();
    }

    Label {
      textFormat: Text.PlainText
      anchors.left: parent.left
      anchors.leftMargin: GC.standardTextHorizMargin
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -parent.height * 0.25
      text: Z.tr("Filter:")
      font.pixelSize: root.rowHeight/2
    }
    ComboBox {
      id: searchFieldSelector
      model: searchableProperties

      anchors.left: parent.left
      anchors.leftMargin: indicatorWidth+GC.standardTextHorizMargin
      width: parent.width/4

      height: parent.height*1.3/2
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: parent.height * 0.25 + rectFilter.comboTextVertOffset

      displayText: Z.tr(currentText)
      flat: false

      ///@note qt 5.9 has a policy for scrollbars to be visible if required instead of the current "hiding if not scrolling" bullshit
      //...policy: ScrollBar.AsNeeded //or ScrollBar.AlwaysOn
      delegate: MenuItem {
        width: searchFieldSelector.popup.width
        text: searchFieldSelector.textRole ? (Array.isArray(searchFieldSelector.model) ? Z.tr(modelData[searchFieldSelector.textRole]) : Z.tr(model[searchFieldSelector.textRole])) : Z.tr(modelData)
        Material.foreground: searchFieldSelector.currentIndex === index ? searchFieldSelector.popup.Material.accent : searchFieldSelector.popup.Material.foreground
        highlighted: searchFieldSelector.highlightedIndex === index
        hoverEnabled: searchFieldSelector.hoverEnabled
      }
    }

    // No ZLineEdit due to different RETURN/ESC/redBackground handling
    TextField {
      id: selectedSearchField
      placeholderText: Z.tr("Regex search")
      selectByMouse: true
      anchors.left: searchFieldSelector.right
      anchors.leftMargin: GC.standardTextHorizMargin
      anchors.right: parent.right
      anchors.rightMargin: root.buttonWidth+GC.standardTextHorizMargin

      height: parent.height*1.3/2
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: parent.height * 0.25 + rectFilter.comboTextVertOffset
      onAccepted: root.searchFile();
      inputMethodHints: Qt.ImhNoAutoUppercase
      Keys.onEscapePressed: {
        rectFilter.clearSearch()
      }

      Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: GC.standardTextBottomMargin
        color: "red"
        opacity: 0.2
        visible: searchResultData.noSearchResults === true
      }
    }

    ZButton {
      text: FA.icon(FA.fa_search)+Z.tr("Search")
      font.family: FA.old

      anchors.right: parent.right
      width: root.buttonWidth

      height: parent.height/2
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -parent.height * 0.25

      enabled: selectedSearchField.text.length>0 && searchProgressId === undefined
      onClicked: {
        searchResultData.noSearchResults = false;
        root.searchFile();
      }
    }

    ZButton {
      id: buttonClearFilter
      text: FA.icon(FA.fa_times) + Z.tr("Clear")
      font.family: FA.old

      anchors.right: parent.right
      width: root.buttonWidth

      height: parent.height/2
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: parent.height * 0.25

      enabled: searchResultData.count>0 || searchResultData.noSearchResults === true
      onClicked: {
        rectFilter.clearSearch()
      }
    }
  }
  RowLayout {
    id: buttonContainer
    anchors.top: rectFilter.bottom
    anchors.bottom: root.bottom
    width: root.width

    Item {
      //spacer
      Layout.fillWidth: true
    }
    Button {
      id: buttonClose
      text: Z.tr("Close")
      visible: !root.withOKButton
      onClicked: {
        cancel()
      }
    }
    Button {
      id: buttonOK
      text: Z.tr("OK")
      visible: root.withOKButton
      onClicked: {
        ok()
      }
    }
    Button {
      id: buttonCancel
      text: Z.tr("Cancel")
      visible: root.withOKButton
      onClicked: {
        cancel()
      }
    }
    Item {
      //spacer
      Layout.fillWidth: true
    }
  }
}
