import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/data/staticdata/FontAwesome.js" as FA

Item {
  id: dataEditor

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
    Keys.onEscapePressed: cancel()

    clip: true
    //keep everything in the buffer to not lose input data
    cacheBuffer: model.count * root.rowHeight*1.2 //delegate height
    delegate: RowLayout {
      property string propName: propertyName;
      height: root.rowHeight*1.2
      Label {
        text: ZTR[propName];
        Layout.minimumWidth: root.width / 4;
        height: root.rowHeight
      }
      TextField {
        text: customerData[propName];
        Layout.fillWidth: true;
        //Layout.maximumWidth: parent.width/1.3;
        height: root.rowHeight;
        Layout.minimumWidth: root.width*3/4-gvScrollBar.width*1.5;
        selectByMouse: true;
        readOnly: !dataEditor.interactive;
        onTextChanged: updateDataObject(propName, text);
        // TODO: is this working with virtual keyboard??
        //onAccepted: ok()
      }
    }

    section.property: "section"
    section.criteria: ViewSection.FullString
    section.delegate: Label {
      height: root.rowHeight*1.5
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
  Item {
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    id: buttonContainer
    height: parent.height / 10
    width: parent.width

    CCMP.ZButton {
      id: buttonOK
      text: ZTR["OK"]
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
