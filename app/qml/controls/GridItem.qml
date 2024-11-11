import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0

/**
  * @b used to display text in table like structures such as the ActualValuesPage
  */
GridRect {
    property alias text: itemLabel.text
    property alias textColor: itemLabel.color
    property alias textFormat: itemLabel.textFormat
    property alias textHorizontalAlignment: itemLabel.horizontalAlignment
    property alias font: itemLabel.font
    Label {
        id: itemLabel
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        textFormat: Label.PlainText //Label.AutoText has a big performance cost and is not wanted in this context
        font.pixelSize: height*0.65
        fontSizeMode: Text.HorizontalFit
        font.family: "Droid Sans Mono"
        elide: Text.ElideRight
    }
}
