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
  text: transformIncoming(controlPropertyName !== "" ? entity[controlPropertyName] : text)

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
}
