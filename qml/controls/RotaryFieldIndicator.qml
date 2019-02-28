import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

Item {
  id: root
  property QtObject dftModule: VeinEntity.getEntity("DFTModule1");
  property var rotaryField: []
  onDftModuleChanged: {
    rotaryField = Qt.binding(function(){return String(dftModule.ACT_RFIELD).split("");})
  }

  Rectangle {
    anchors.fill: parent
    color: Material.background
    opacity: 0.2
  }

  Repeater {
    model: rotaryField.length
    Text {
      text: rotaryField[index];
      color: GC.systemColorByIndex(parseInt(rotaryField[index]));
      font.pixelSize: root.height/1.8
      x: 2 + (root.width/3 * index)
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
