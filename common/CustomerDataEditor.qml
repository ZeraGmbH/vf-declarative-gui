import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
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
      objModel.append({ propertyName: customerProperties[cIndex], section: ZTR["Customer"] });
    }
    for(var pIndex in powergridProperties)
    {
      objModel.append({ propertyName: powergridProperties[pIndex], section: ZTR["Power grid"] });
    }
    for(var lIndex in locationProperties)
    {
      objModel.append({ propertyName: locationProperties[lIndex], section: ZTR["Location"] });
    }
    for(var mIndex in meterProperties)
    {
      objModel.append({ propertyName: meterProperties[mIndex], section: ZTR["Meter information"] });
    }
  }

  ListModel {
    id: objModel
  }

  ListView {
    id: generalView
    width: root.width
    model: objModel
    anchors.fill: parent
    anchors.margins: 2
    clip: true
    //keep everything in the buffer to not lose input data
    cacheBuffer: model.count * root.rowHeight*1.2 //delegate height
    delegate: RowLayout {
      property string propName: propertyName;
      height: root.rowHeight*1.2
      width: root.width - root.padding*2 - gvScrollBar.width*1.5
      Label {
        text: ZTR[propName];
        width: contentWidth;
        height: root.rowHeight
      }
      //spacer
      Item {
        Layout.fillWidth: true;
        height: root.rowHeight
      }
      TextField {
        text: customerData[propName];
        Layout.fillWidth: true;
        Layout.maximumWidth: parent.width/1.3;
        height: root.rowHeight;
        selectByMouse: true;
        readOnly: !dataEditor.interactive;
        onTextChanged: updateDataObject(propName, text);
      }
    }
    //boundsBehavior: Flickable.StopAtBounds
    //orientation: ListView.Horizontal
    //spacing: root.padding*2

    section.property: "section"
    section.criteria: ViewSection.FullString
    section.delegate: Label {
      height: root.rowHeight*1.5
      verticalAlignment: Text.AlignBottom
      text: section
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
}
