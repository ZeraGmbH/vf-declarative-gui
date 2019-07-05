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

  // overridable
  function transformIncoming(t_incoming) { return t_incoming; }

  // overrides
  function doApplyInput(newText) {
    // Numerical?
    if(root.isNumeric)
    {
      if(root.isDouble)
        root.entity[root.controlPropertyName] = parseFloat(newText)
      else
        root.entity[root.controlPropertyName] = parseInt(newText, 10)
    }
    else
      root.entity[root.controlPropertyName] = newText
    // wait to be applied
    return false
  }

  // monitor entity/component changes
  Item {
    // make sure control works like ZLineEdit when controlPropertyName was not set
    property var intermediateValue: transformIncoming(root.controlPropertyName !== "" ? root.entity[root.controlPropertyName] : root.text)
    onIntermediateValueChanged: {
      if(intermediateValue !== undefined && !inApply)
        root.text = intermediateValue
    }
  }
}
