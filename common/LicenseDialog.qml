import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ZeraTranslation 1.0
import QmlFileIO 1.0
import GlobalConfig 1.0

Popup {
  id: root
  modal: true
  dim: true
  closePolicy: Popup.NoAutoClose
  readonly property var licenseList: QmlFileIO.readJsonFile(":/data/staticdata/license_index.json")
  readonly property string selectedFileName: licenseList[licenseLV.currentIndex].license
  padding: 0
  Item {
    anchors.fill: parent
    Label {
      id: titleLabel
      anchors.horizontalCenter: parent.horizontalCenter
      text: "License agreement"
      font.pointSize: 24
    }
    ListView {
      id: licenseLV
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.top: titleLabel.bottom
      anchors.topMargin: 16
      width: root.width/4
      model: licenseList
      currentIndex: 0

      delegate: ToolButton {
        width: licenseLV.width
        text: modelData.title
        font.pointSize: 10
        onClicked: licenseLV.currentIndex = index
        highlighted: licenseLV.currentIndex === index
      }
    }
    ColumnLayout {
      id: contentLayout
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.top: titleLabel.bottom
      anchors.topMargin: 16
      width: root.width * 3/4

      Flickable {
        id: licenseFlickable
        Layout.fillHeight: true
        anchors.left: parent.left
        anchors.right: parent.right
        contentHeight: licenseText.contentHeight
        clip: true
        boundsBehavior: licenseFlickable.height>=licenseText.contentHeight ?  Flickable.StopAtBounds  : Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScrollBar {
          width: 8
          policy: licenseFlickable.height>=licenseText.contentHeight ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn
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
      Button {
        anchors.right: parent.right
        anchors.rightMargin: height/5
        text: ZTR["Accept"]
        highlighted: true
        onClicked: {
          GC.acceptLicenseAgreement();
          root.close();
        }
      }
    }
  }
}
