import QtQuick 2.0
import QtQuick.Controls 2.0
import "qrc:/components/common" as CCMP

CCMP.ZComboBox {
  id: root
  property QtObject entity
  property string controlPropertyName
  function setInitialIndex() {
    if(entity && model) {
      currentIndex = model.indexOf(entity[controlPropertyName]);
    }
  }

  automaticIndexChange: true

  onEntityChanged: setInitialIndex();
  onModelChanged: setInitialIndex();
  onSelectedTextChanged: {
    if(entity[controlPropertyName] !== selectedText)
    {
      entity[controlPropertyName] = selectedText
    }
  }

  QtObject {
    property int intermediate: model.indexOf(root.entity[root.controlPropertyName]);
    onIntermediateChanged: {
      if(root.currentIndex !== intermediate)
      {
        root.currentIndex = intermediate
      }
    }
  }
}
