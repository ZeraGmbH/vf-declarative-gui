import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

GridRect {
  property alias text: itemLabel.text
  property alias textColor: itemLabel.color
  property alias textFormat: itemLabel.textFormat
  property alias textHorizontalAlignment: itemLabel.horizontalAlignment
  property alias font: itemLabel.font
  property alias fontSizeMode: itemLabel.fontSizeMode
  Label {
    id: itemLabel
    anchors.fill: parent
    anchors.rightMargin: 8
    horizontalAlignment: Label.AlignRight
    verticalAlignment: Label.AlignVCenter
    textFormat: Label.PlainText
    font.pixelSize: height*0.65
    fontSizeMode: Text.HorizontalFit
    font.family: "Droid Sans Mono"
  }
}
