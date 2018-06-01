import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ZeraTranslation 1.0
import QmlFileIO 1.0
import GlobalConfig 1.0

Item {
  id: root
  readonly property var licenseList: QmlFileIO.readJsonFile(":/data/staticdata/license_index.json")
  readonly property string selectedFileName: licenseList[licenseLV.currentIndex].license
  Item {
    anchors.fill: parent

    ListView {
      id: licenseLV
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.top: parent.top
      width: root.width/4
      model: licenseList
      currentIndex: 0
      onCurrentIndexChanged: {
        licenseFlickable.cancelFlick();
        licenseFlickable.contentY = 0; //scroll up to the beginning
      }

      delegate: ToolButton {
        width: licenseLV.width
        text: modelData.title
        font.pointSize: 10
        onClicked: licenseLV.currentIndex = index
        highlighted: licenseLV.currentIndex === index
      }
      boundsBehavior: height>=contentHeight ?  Flickable.StopAtBounds  : Flickable.DragAndOvershootBounds
    }
    ColumnLayout {
      id: contentLayout
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.top: parent.top
      width: root.width * 3/4

      Flickable {
        id: licenseFlickable
        Layout.fillHeight: true
        width: parent.width
        contentHeight: licenseText.contentHeight
        clip: true
        boundsBehavior: licenseFlickable.height>=licenseText.contentHeight ?  Flickable.StopAtBounds  : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar {
          width: 16
          Component.onCompleted: {
            if(QT_VERSION >= 0x050900) //policy was added after 5.7
            {
              policy = Qt.binding(function (){ return licenseFlickable.height>=licenseText.contentHeight ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn; });
            }
          }
        }

        Label {
          id: licenseText
          //readOnly: true
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.rightMargin: 24
          height: contentHeight
          text: QmlFileIO.readTextFile(selectedFileName)
          textFormat: Text.AutoText
          font.pointSize: 10
          wrapMode: Label.Wrap
        }
      }
    }
  }
}
