import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import "qrc:/vf-controls/common" as VF
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0


Item {
  id: root
  property var errorDataModel;
  onErrorDataModelChanged: {
    if(errorDataModel !== undefined)
    {
      dummyModel.clear();
      for(var i=0; i<errorDataModel.length; ++i)
      {
        dummyModel.append(errorDataModel[i]);
      }
    }
  }

  ListModel{
    id: dummyModel
  }

  Label {
    id: titleText
    text: ZTR["Device notifications"]
    font.pixelSize: 24
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    horizontalAlignment: Text.AlignHCenter
  }



  ListView {
    id: lvErrorView
    anchors.fill: parent
    anchors.topMargin: titleText.height*2
    model: dummyModel
    boundsBehavior: ListView.StopAtBounds
    delegate: Item {
      id: currentElement
      width: root.width
      height: dataColumn.height+16

      Column {
        id: dataColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 0

        RowLayout {
          width: parent.width
          Label { text: model.ModuleName; font.pixelSize: 20; }
          Item { Layout.fillWidth: true; } //spacer
          Label { text: model.Time; font.pixelSize: 20; }
        }
        Label { text: ZTR[model.Error] !== undefined ? ZTR[model.Error] : model.Error; font.pixelSize: 20; }
        Item { height: 8; width: parent.width } //spacer
        Frame { height: 1; width: parent.width }
      }
    }
  }
}
