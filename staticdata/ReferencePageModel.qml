import QtQuick 2.0

ListModel {
  readonly property string firstElement: "qrc:/pages/RefModulePage.qml"

  ListElement {
    name: "Reference values"
    icon: "qrc:/data/staticdata/resources/ref_values.png"
    elementValue: "qrc:/pages/RefModulePage.qml"
  }
}
