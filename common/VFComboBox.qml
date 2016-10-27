import QtQuick 2.0
import QtQuick.Controls 2.0
import "qrc:/ccmp/common" as CCMP

CCMP.ZComboBox {
  id: root
  property QtObject entity
  property string controlPropertyName

  automaticIndexChange: true

  QtObject {
    property int intermediate: model.indexOf(root.entity[root.controlPropertyName]);
    onIntermediateChanged: {
      if(root.currentIndex !== intermediate)
      {
        root.currentIndex = intermediate
      }
    }
  }

  onModelChanged: {
    currentIndex = model.indexOf(entity[controlPropertyName]);
  }
  onSelectedTextChanged: {
    if(entity[controlPropertyName] !== selectedText)
    {
      entity[controlPropertyName] = selectedText
    }
  }
}
