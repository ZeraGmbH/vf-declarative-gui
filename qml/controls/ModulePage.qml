import QtQuick 2.0

Item {
  MouseArea {
    anchors.fill: parent
    //to remove focus from input elements, obviously doesn't work with the virtual keyboard fullscreenMode=1
    onClicked: focus = true
  }
}
