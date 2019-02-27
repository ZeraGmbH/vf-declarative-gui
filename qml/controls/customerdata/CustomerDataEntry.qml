import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import "qrc:/data/staticdata/FontAwesome.js" as FA

Popup {
  id: root
  focus: true
  clip: true
  readonly property QtObject customerData: VeinEntity.getEntity("CustomerData");
  readonly property int rowHeight: 30
  readonly property int effectiveRowWidth: Math.floor(width-padding)

  readonly property var generalProperties: ["PAR_DatasetIdentifier", "PAR_DatasetComment"];
  readonly property var customerProperties: ["PAR_CustomerNumber", "PAR_CustomerFirstName", "PAR_CustomerLastName",
    "PAR_CustomerCountry", "PAR_CustomerCity", "PAR_CustomerPostalCode", "PAR_CustomerStreet", "PAR_CustomerComment"];
  readonly property var locationProperties: ["PAR_LocationNumber", "PAR_LocationFirstName", "PAR_LocationLastName",
    "PAR_LocationCountry", "PAR_LocationCity", "PAR_LocationPostalCode", "PAR_LocationStreet", "PAR_LocationComment"];
  readonly property var meterProperties: ["PAR_MeterFactoryNumber", "PAR_MeterManufacturer", "PAR_MeterOwner", "PAR_MeterComment"];
  readonly property var powergridProperties: ["PAR_PowerGridOperator", "PAR_PowerGridSupplier", "PAR_PowerGridComment"];

  property var editableDataObject: ({});
  readonly property string currentFile: customerData.FileSelected
  onCurrentFileChanged: {
    //data becomes irrelevant if the file switches
    editableDataObject = ({});
  }


  TabBar {
    id: bar
    height: root.rowHeight*1.4;
    width: root.width
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: -root.padding*2
    TabButton {
      id: browseButton
      width: root.effectiveRowWidth/3
      height: parent.height
      text: FA.fa_archive
      font.family: "FontAwesome"
      font.pixelSize: 20
    }
    TabButton {
      id: viewButton
      width: root.effectiveRowWidth/3
      text: FA.fa_eye
      font.family: "FontAwesome"
      font.pixelSize: 20
      height: parent.height
      enabled: currentFile.length>0
    }
    TabButton {
      id: editButton
      width: root.effectiveRowWidth/3
      height: parent.height
      text: FA.fa_edit
      font.family: "FontAwesome"
      font.pixelSize: 20
      enabled: currentFile.length>0
    }
  }

  Connections {
    target: dataBrowserLoader.item
    onSwitchToViewMode: bar.currentIndex = 1
    onSwitchToEditMode: bar.currentIndex = 2
  }

  StackLayout {
    id: stackLayout
    currentIndex: bar.currentIndex
    anchors.fill: parent
    anchors.topMargin: bar.height-root.padding*2
    anchors.bottomMargin: buttonContainer.height-root.padding

    Loader {
      id: dataBrowserLoader
      active: stackLayout.currentIndex === 0
      sourceComponent: CustomerDataBrowser {
        searchableProperties: generalProperties.concat(customerProperties, locationProperties, meterProperties, powergridProperties);
      }
    }
    Loader {
      active: stackLayout.currentIndex === 1
      sourceComponent: CustomerDataEditor {
        interactive: false
      }
    }
    Loader {
      active: stackLayout.currentIndex === 2
      sourceComponent: CustomerDataEditor {
        id: customerDataEditor
        interactive: true
      }
    }
  }

  Item {
    id: buttonContainer
    height: root.rowHeight*1.4;
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: -root.padding

    Button {
      text: ZTR["Save"];
      font.pixelSize: 20;
      anchors.top: buttonContainer.top;
      anchors.bottom: buttonContainer.bottom;
      width: root.width/4;
      highlighted: true;
      visible: bar.currentItem === editButton;
      onClicked: {
        for(var prop in editableDataObject)
        {
          customerData[prop] = editableDataObject[prop];
        }
      }
    }

    Button {
      text: ZTR["Close"]
      font.pixelSize: 20;
      anchors.top: buttonContainer.top;
      anchors.bottom: buttonContainer.bottom;
      anchors.right: parent.right;
      width: root.width/4;

      onClicked: {
        root.close();
      }
    }
  }
}
