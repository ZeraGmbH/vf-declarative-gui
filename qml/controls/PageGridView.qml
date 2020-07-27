import QtQuick 2.5
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP

/**
  * @b A selection of the available pages/views laid out in an elliptic path
  * @todo split grid and page view into separate qml files then use a loader to switch between them
  */
Item {
  id: root

  property var model;
  readonly property double scaleFactor: Math.min(width/1024, height/600);

  //negative for no element
  signal elementSelected(var elementValue)

  Component {
    id: gridDelegate

    Rectangle {
      id: gridWrapper
      property string itemName: name
      border.color: Qt.darker(Material.frameColor, 1.3)
      border.width: 3
      width: root.width/2 - 12
      height: 64*scaleFactor+6
      color: "#11ffffff" //Material.backgroundColor
      radius: 4

      MouseArea {
        anchors.fill: parent
        onClicked: {
          GC.pageViewLastSelectedIndex = index
          root.elementSelected({"elementIndex": index, "value": elementValue})
        }
      }
      Image {
        id: listImage
        width: height*1.83 //image form factor
        height: parent.height-8
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 4
        source: icon
        mipmap: true
      }
      Label {
        text: Z.tr(name)
        textFormat: Text.PlainText
        anchors.left: listImage.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Label.Wrap
        font.pointSize: 14
        color: (gridView.currentItem === gridWrapper ? Material.accentColor : Material.primaryTextColor)
      }
    }
  }


  GridView {
    id: gridView
    model: root.model
    flow: GridView.FlowTopToBottom
    boundsBehavior: Flickable.StopAtBounds
    cellHeight: 64*scaleFactor+12
    cellWidth: width/2
    anchors.fill: parent
    // Center one in case of one column
    // This is a hack - but it works and a better solution was not yet found
    anchors.leftMargin: 8 + (model.count <= 6 ? root.width/4 : 0)
    anchors.topMargin: root.height/10
    anchors.bottomMargin: root.height/10
    clip: true
    onCurrentItemChanged: {
      //untranslated raw text
      GC.currentViewName = currentItem.itemName;
    }

    ScrollBar.horizontal: ScrollBar { policy: gridView.contentWidth>gridView.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff; }

    delegate: gridDelegate
    currentIndex: GC.pageViewLastSelectedIndex
  }
}
