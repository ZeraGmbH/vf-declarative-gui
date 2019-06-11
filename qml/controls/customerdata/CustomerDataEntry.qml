import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/data/staticdata/FontAwesome.js" as FA

Popup {
  id: root

  readonly property QtObject customerData: VeinEntity.getEntity("CustomerData");

  readonly property var generalProperties: ["PAR_DatasetIdentifier", "PAR_DatasetComment"];
  readonly property var customerProperties: ["PAR_CustomerNumber", "PAR_CustomerFirstName", "PAR_CustomerLastName",
    "PAR_CustomerCountry", "PAR_CustomerCity", "PAR_CustomerPostalCode", "PAR_CustomerStreet", "PAR_CustomerComment"];
  readonly property var locationProperties: ["PAR_LocationNumber", "PAR_LocationFirstName", "PAR_LocationLastName",
    "PAR_LocationCountry", "PAR_LocationCity", "PAR_LocationPostalCode", "PAR_LocationStreet", "PAR_LocationComment"];
  readonly property var meterProperties: ["PAR_MeterFactoryNumber", "PAR_MeterManufacturer", "PAR_MeterOwner", "PAR_MeterComment"];
  readonly property var powergridProperties: ["PAR_PowerGridOperator", "PAR_PowerGridSupplier", "PAR_PowerGridComment"];

  property bool editActive: false

  property var editableDataObject: ({});

  readonly property string currentFile: customerData.FileSelected
  onCurrentFileChanged: {
    //data becomes irrelevant if the file switches
    editableDataObject = ({});
  }

  Connections {
    target: dataBrowserLoader.item
    onSwitchToEditMode: {
      editActive = true
    }
    onCancel: {
        root.close()
    }
    onOk: {
        // TODO send signal to my caller
        root.close()
    }
  }

  Connections {
    target: dataEditorLoader.item
    onOk: {
      for(var prop in editableDataObject)
      {
        customerData[prop] = editableDataObject[prop];
      }
      editActive = false
    }
    onCancel: {
      editActive = false
    }
  }

  StackLayout {
    id: stackLayout
    currentIndex: 0
    anchors.fill: parent

    Loader {
      id: dataBrowserLoader
      active: !editActive
      sourceComponent: CustomerDataBrowser {
        searchableProperties: generalProperties.concat(customerProperties, locationProperties, meterProperties, powergridProperties);
      }
      onLoaded: stackLayout.currentIndex = 0
    }
    Loader {
      id: dataEditorLoader
      active: editActive
      sourceComponent: CustomerDataEditor {
        interactive: true
      }
      onLoaded: stackLayout.currentIndex = 1
    }
  }
}
