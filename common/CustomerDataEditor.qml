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

  function updateDataObject(prop, text) {
    if(interactive === true && editableDataObject !== undefined)
    {
      editableDataObject[prop] = text;
    }
  }

  Component {
    id: generalDelegate
    RowLayout {
      height: root.rowHeight
      width: root.width/2 - root.padding*2
      Label { text: ZTR[generalProperties[index]]; width: contentWidth; height: root.rowHeight }
      Item { Layout.fillWidth: true; height: root.rowHeight } //spacer
      TextField { text: customerData[generalProperties[index]]; implicitWidth: parent.width/1.5; height: root.rowHeight; selectByMouse: true; readOnly: !dataEditor.interactive; onTextChanged: updateDataObject(generalProperties[index], text);
      }
    }
  }
  Component {
    id: customerDelegate
    RowLayout {
      height: root.rowHeight
      width: root.width/2 - root.padding*2
      Label { text: ZTR[customerProperties[index]]; width: contentWidth; height: root.rowHeight }
      Item { Layout.fillWidth: true; height: root.rowHeight } //spacer
      TextField { text: customerData[customerProperties[index]]; implicitWidth: parent.width/1.5; height: root.rowHeight; selectByMouse: true; readOnly: !dataEditor.interactive; onTextChanged: updateDataObject(customerProperties[index], text); }
    }
  }
  Component {
    id: powergridDelegate
    RowLayout {
      height: root.rowHeight
      width: root.width/2 - root.padding*2
      Label { text: ZTR[powergridProperties[index]]; width: contentWidth; height: root.rowHeight }
      Item { Layout.fillWidth: true; height: root.rowHeight } //spacer
      TextField { text: customerData[powergridProperties[index]]; implicitWidth: parent.width/1.5; height: root.rowHeight; selectByMouse: true; readOnly: !dataEditor.interactive; onTextChanged: updateDataObject(powergridProperties[index], text); }
    }
  }

  ListView {
    id: generalView
    width: root.width
    model: generalProperties.length
    delegate: generalDelegate
    anchors.top: parent.top
    anchors.left: parent.left
    height: count*rowHeight/2
    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal
    spacing: root.padding*2
  }

  ListView {
    id: customerView
    width: root.width/2 - root.padding*2
    model: customerProperties.length
    delegate: customerDelegate
    anchors.top: generalView.bottom
    anchors.topMargin: root.rowHeight-4
    anchors.left: parent.left
    height: count*rowHeight
    boundsBehavior: Flickable.StopAtBounds
    Label {
      anchors.bottom: parent.top
      anchors.bottomMargin: -8
      text: ZTR["Customer"]
      font.pointSize: 16
      font.bold: true
    }
  }
  ListView {
    id: powergridView
    width: root.width/2 - root.padding*2
    model: powergridProperties.length
    delegate: powergridDelegate
    anchors.top: customerView.bottom
    anchors.topMargin: root.rowHeight-4
    anchors.left: parent.left
    height: count*rowHeight
    boundsBehavior: Flickable.StopAtBounds
    Label {
      anchors.bottom: parent.top
      anchors.bottomMargin: -8
      text: ZTR["Power grid"]
      font.pointSize: 16
      font.bold: true
    }
  }


  Component {
    id: locationDelegate
    RowLayout {
      height: root.rowHeight
      width: root.width/2 - root.padding*2
      Label { text: ZTR[locationProperties[index]]; width: contentWidth; height: root.rowHeight }
      Item { Layout.fillWidth: true; height: root.rowHeight } //spacer
      TextField { text: customerData[locationProperties[index]]; implicitWidth: parent.width/1.5; height: root.rowHeight; selectByMouse: true; readOnly: !dataEditor.interactive; onTextChanged: updateDataObject(locationProperties[index], text); }
    }
  }
  Component {
    id: meterDelegate
    RowLayout {
      height: root.rowHeight
      width: root.width/2 - root.padding*2
      Label { text: ZTR[meterProperties[index]]; width: contentWidth; height: root.rowHeight }
      Item { Layout.fillWidth: true; height: root.rowHeight } //spacer
      TextField { text: customerData[meterProperties[index]]; implicitWidth: parent.width/1.5; height: root.rowHeight; selectByMouse: true; readOnly: !dataEditor.interactive; onTextChanged: updateDataObject(meterProperties[index], text); }
    }
  }

  ListView {
    id: locationView
    width: root.width/2 - root.padding*2
    model: locationProperties.length
    delegate: locationDelegate
    anchors.top: generalView.bottom
    anchors.topMargin: root.rowHeight-4
    anchors.left: customerView.right
    anchors.leftMargin: root.padding*2
    height: count*rowHeight
    boundsBehavior: Flickable.StopAtBounds
    Label {
      anchors.bottom: parent.top
      anchors.bottomMargin: -8
      text: ZTR["Location"]
      font.pointSize: 16
      font.bold: true
    }
  }
  ListView {
    id: meterView
    width: root.width/2 - root.padding*2
    model: meterProperties.length
    delegate: meterDelegate
    anchors.top: customerView.bottom
    anchors.topMargin: root.rowHeight-4
    anchors.left: powergridView.right
    anchors.leftMargin: root.padding*2
    height: count*rowHeight
    boundsBehavior: Flickable.StopAtBounds
    Label {
      anchors.bottom: parent.top
      anchors.bottomMargin: -8
      text: ZTR["Meter information"]
      font.pointSize: 16
      font.bold: true
    }
  }
}
