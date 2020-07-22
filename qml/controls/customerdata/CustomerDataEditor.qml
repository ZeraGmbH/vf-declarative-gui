import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0
import "qrc:/qml/controls" as CCMP
import ZeraFa 1.0

Item {
  id: dataEditor
  anchors.fill: parent
  readonly property real rowHeight: parent.height / 15

  property bool interactive: true

  Component.onCompleted: {
    initModel();
  }

  function updateDataObject(prop, text) {
    if(interactive === true && editableDataObject !== undefined)
    {
      editableDataObject[prop] = text;
    }
  }

  function initModel() {
    for(var gpIndex in generalProperties)
    {
      objModel.append({ propertyName: generalProperties[gpIndex], section: "" });
    }
    for(var cIndex in customerProperties)
    {
      objModel.append({ propertyName: customerProperties[cIndex], section: "Customer" });
    }
    for(var pIndex in powergridProperties)
    {
      objModel.append({ propertyName: powergridProperties[pIndex], section: "Power grid" });
    }
    for(var lIndex in locationProperties)
    {
      objModel.append({ propertyName: locationProperties[lIndex], section: "Location" });
    }
    for(var mIndex in meterProperties)
    {
      objModel.append({ propertyName: meterProperties[mIndex], section: "Meter information" });
    }
  }

  signal ok();
  signal cancel();

  ListModel {
    id: objModel
  }

  ListView {
    id: generalView
    model: objModel

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: buttonContainer.top

    focus: true
    clip: true
    Keys.onEscapePressed: cancel()

    //keep everything in the buffer to not lose input data
    cacheBuffer: model.count * dataEditor.rowHeight*1.2 //delegate height
    delegate: RowLayout {
      property string propName: propertyName;
      height: dataEditor.rowHeight*1.2
      Label {
        text: ZTR[propName];
        Layout.minimumWidth: dataEditor.width / 4;
        height: dataEditor.rowHeight
      }
      ZLineEdit {
        text: customerData[propName];
        Layout.fillWidth: true;
        height: dataEditor.rowHeight*1.2;
        Layout.minimumWidth: dataEditor.width*3/4-gvScrollBar.width*1.5;
        readOnly: !dataEditor.interactive;
        onTextChanged: updateDataObject(propName, text);
        textField.horizontalAlignment: Text.AlignLeft
      }
    }

    section.property: "section"
    section.criteria: ViewSection.FullString
    section.delegate: Label {
      height: dataEditor.rowHeight*1.5
      verticalAlignment: Text.AlignBottom
      text: ZTR[section]
      font.pointSize: 16
      font.bold: true
    }

    ScrollBar.vertical: ScrollBar {
      id: gvScrollBar
      Component.onCompleted: {
        if(QT_VERSION >= 0x050900) //policy was added after 5.7
        {
          policy = Qt.binding(function (){return generalView.contentHeight > generalView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff; });
        }
      }
    }
  }
  RowLayout {
    anchors.bottom: parent.bottom
    Layout.alignment: Qt.AlignHCenter
    id: buttonContainer
    height: parent.height / 10
    width: parent.width

    Item {
      //spacer
      Layout.fillWidth: true
    }
    Button {
      id: okButton
      text: ZTR["OK"]
      Layout.minimumWidth: cancelButton.width
      onClicked: {
        ok()
      }
    }
    Button {
      id: cancelButton
      text: ZTR["Cancel"]
      Layout.minimumWidth: okButton.width
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
