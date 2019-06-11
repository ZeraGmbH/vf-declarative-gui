import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import SortFilterProxyModel 0.2
import GlobalConfig 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/data/staticdata/FontAwesome.js" as FA

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

    readonly property bool fileNameAlreadyExists: filenameField.text.length>0 && customerData.FileList !== undefined && customerData.FileList.indexOf(filenameField.text.toLowerCase()+".json") >= 0

    onOpened: filenameField.forceActiveFocus()
    onClosed: filenameField.clear()
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
      CCMP.ZButton {
        text: ZTR["OK"]
        width: newFileCancel.width
        enabled: filenameField.text.length>0 && addFilePopup.fileNameAlreadyExists === false
        //highlighted: true
        onClicked: {
          root.saveChanges()
        }
      }
      CCMP.ZButton {
        id: newFileCancel
        text: ZTR["Cancel"]
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
      text: ZTR["Customer data files:"]
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
            font.family: "Fontawesome"
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
    CCMP.ZButton {
      text: FA.icon(FA.fa_file)+ZTR["New"]
      font.family: "FontAwesome"

      anchors.right: parent.right
      width: root.buttonWidth

      anchors.top: parent.top
      anchors.topMargin: 1.5*rowHeight
      height: rowHeight

      onClicked: {
        addFilePopup.open()
      }
    }
    CCMP.ZButton {
      text: FA.icon(FA.fa_edit)+ZTR["Edit"]
      font.family: "FontAwesome"

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
    CCMP.ZButton {
      text: FA.icon(FA.fa_trash)+ZTR["Delete"]
      font.family: "FontAwesome"

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
      text: ZTR["Filter:"]
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

      displayText: ZTR[currentText]
      flat: false

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
      placeholderText: ZTR["Regex search"]
      selectByMouse: true
      anchors.left: searchFieldSelector.right
      anchors.leftMargin: GC.standardTextHorizMargin
      anchors.right: parent.right
      anchors.rightMargin: root.buttonWidth+GC.standardTextHorizMargin

      height: parent.height*1.3/2
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: parent.height * 0.25 + rectFilter.comboTextVertOffset
      onAccepted: root.searchFile();
      Keys.onEscapePressed: {
        rectFilter.clearSearch()
      }

      Rectangle {
        anchors.fill: parent
        color: "red"
        opacity: 0.2
        visible: searchResultData.noSearchResults === true
      }
    }

    CCMP.ZButton {
      text: FA.icon(FA.fa_search)+ZTR["Search"]
      font.family: "FontAwesome"

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

    CCMP.ZButton {
      id: buttonClearFilter
      text: FA.icon(FA.fa_times) + ZTR["Clear"]
      font.family: "FontAwesome"

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
  Item {
    id: buttonContainer
    anchors.top: rectFilter.bottom
    anchors.topMargin: root.rowHeight / 8
    height: root.rowHeight
    width: root.width

    CCMP.ZButton {
      id: buttonClose
      text: ZTR["Close"]
      visible: !root.withOKButton

      width: GC.standardButtonWidth // TODO fix binding loop
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        cancel()
      }
    }
    CCMP.ZButton {
      id: buttonOK
      text: ZTR["OK"]
      visible: root.withOKButton

      width: GC.standardButtonWidth // TODO fix binding loop
      anchors.right: parent.horizontalCenter
      anchors.rightMargin: GC.standardMarginMin
      anchors.verticalCenter: parent.verticalCenter
      onClicked: {
        ok()
      }
    }
    CCMP.ZButton {
      id: buttonCancel
      text: ZTR["Cancel"]
      visible: root.withOKButton

      width: GC.standardButtonWidth // TODO fix binding loop
      anchors.leftMargin: GC.standardMarginMin
      anchors.left: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      onClicked: {
        cancel()
      }
    }
  }
}
