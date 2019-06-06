import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/vf-controls" as VFControls
import "qrc:/data/staticdata/FontAwesome.js" as FA

Item {
  id: root
  //holds the state data
  property QtObject logicalParent;
  property real measurementResult;
  property alias progress: actProgressBar.value
  property alias progressTo: actProgressBar.to
  property string actualValue;

  Column {
    anchors.fill: parent
    Item {
      height: root.height*0.8
      width: root.width

      Item {
        height: parent.height
        width: 3*root.width/7
        anchors.left: parent.left
        readonly property int statusNotify: logicalParent.status;

        Label {
          width: parent.width
          textFormat: Text.PlainText
          font.pixelSize: 40
          fontSizeMode: Text.HorizontalFit
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          text: actualValue
        }
      }

      Item {
        visible: logicalParent.status === logicalParent.statusHolder.armed
        anchors.centerIn: parent
        height: parent.height*0.8
        width: root.width/7
        clip: true
        Image {
          source: "qrc:/data/staticdata/resources/Armed.svg"
          sourceSize.width: parent.width
          fillMode: Image.TileHorizontally
          height: parent.height
          width: parent.width
        }
      }

      Item {
        id: animatedReady
        visible: logicalParent.status & logicalParent.statusHolder.started
        anchors.centerIn: parent
        height: parent.height*0.8
        width: root.width/7
        clip: true
        Image {
          source: "qrc:/data/staticdata/resources/Ready.svg"
          sourceSize.width: parent.width
          fillMode: Image.TileHorizontally
          height: parent.height
          width: parent.width*2

          SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation {
              from: 0
              to: -animatedReady.width
              duration: 1000
            }
            NumberAnimation {
              to: 0
              duration: 0
            }
          }
        }
      }

      Item {
        height: parent.height
        width: 3*root.width/7
        anchors.right: parent.right
        readonly property int statusNotify: logicalParent.status;
        visible: false;
        onStatusNotifyChanged: {
          if(statusNotify & logicalParent.statusHolder.ready)
          {
            visible = true;
          }
          else if(statusNotify === logicalParent.statusHolder.aborted || statusNotify & logicalParent.statusHolder.started)
          {
            visible = false;
          }
        }

        Label {
          id: resultLabel
          width: parent.width
          textFormat: Text.PlainText
          horizontalAlignment: Text.AlignRight
          font.pixelSize: 40
          fontSizeMode: Text.HorizontalFit
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          text: GC.formatNumber(measurementResult)+"%"
        }
      }
    }
    Item { //spacer
      height: 8
      width: parent.width
    }
    ProgressBar {
      id: actProgressBar
      from: 0
      width: parent.width
      height: parent.height/20
      indeterminate: logicalParent.status === logicalParent.statusHolder.armed

      Label {
        visible: logicalParent.status !== logicalParent.statusHolder.ready
        textFormat: Text.PlainText
        anchors.bottom: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
        text: parseInt(actProgressBar.value / actProgressBar.to * 100)+"%"
      }
    }
  }
}
