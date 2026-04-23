import QtQuick 2.14
import QtQuick.Controls 2.14
import ZeraThemeConfig 1.0

/**
  * @b used to display text in table like structures such as the ActualValuesPage
  */
Rectangle {
    property alias text: itemLabel.text
    property alias textColor: itemLabel.color
    property alias textHorizontalAlignment: itemLabel.horizontalAlignment
    property alias font: itemLabel.font
    border.color: ZTC.dividerColor
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
    }
}
