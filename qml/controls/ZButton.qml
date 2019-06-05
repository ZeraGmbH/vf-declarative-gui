import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0

Button {
  id: root

  // Button has special ideas - force our margins
  background.anchors.fill: root
  background.anchors.topMargin: GC.standardMargin
  background.anchors.bottomMargin: GC.standardMargin
  background.anchors.rightMargin: GC.standardMargin
}
