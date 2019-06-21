import QtQuick 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import GlobalConfig 1.0
import "qrc:/qml/controls" as CCMP

CCMP.ZLineEdit {
  id: root

  // entitiy/component settings
  property QtObject entity
  property string controlPropertyName

  // overrides
  function postApplyInput() {
    // Numerical?
    if(root.isNumeric)
    {
      if(root.isDouble)
        root.entity[root.controlPropertyName] = parseFloat(text)
      else
        root.entity[root.controlPropertyName] = parseInt(text, 10)
    }
    else
      root.entity[root.controlPropertyName] = text
  }

  // monitor entity/component changes
  Item {
    // make sure control works like ZLineEdit when controlPropertyName was not set
    property var intermediateValue: root.controlPropertyName !== "" ? root.entity[root.controlPropertyName] : root.text
    onIntermediateValueChanged: {
      if(intermediateValue !== undefined && !inApply)
        root.text = intermediateValue
    }
  }
}
