import QtQuick 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0

CheckBox {
  id: root
  property QtObject entity
  property string controlPropertyName

  onClicked: {
    var check=!entity[controlPropertyName]
    entity[controlPropertyName] = check;
    //checked=check
  }

  onCheckedChanged: {
    if(checked !== entity[controlPropertyName])
    {
      checked = entity[controlPropertyName];
    }
  }

  QtObject {
    readonly property bool intermediate: entity[controlPropertyName]
    onIntermediateChanged: {
      if(root.checked !== intermediate)
      {
        root.checked = intermediate
      }
    }
  }
}
