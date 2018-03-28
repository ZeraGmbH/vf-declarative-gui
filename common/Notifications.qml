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

  ListModel {
    id: dummyModel
  }

  Label {
    id: titleText
    text: ZTR["Device notifications"]
    font.pixelSize: 20
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
    delegate: Label {
      id: currentElement
      width: root.width
      textFormat: Label.RichText
      font.pointSize: 11
      font.family: "Monospace"
      wrapMode: Label.WordWrap
      text: String("<small>%1</small> <b>%2:</b> %3").arg(model.Time).arg(model.ModuleName).arg(ZTR[model.Error] !== undefined ? ZTR[model.Error] : model.Error);
    }
  }
}
