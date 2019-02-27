import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import "qrc:/data/staticdata/FontAwesome.js" as FA
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0

Item {
  id: root
  //holds the state data
  property QtObject logicalParent;

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
        visible: false;
        onStatusNotifyChanged: {
          if(statusNotify & logicalParent.statusHolder.ready)
          {
            visible = true;
          }
          else if(statusNotify === logicalParent.statusHolder.aborted)
          {
            visible = false;
          }
        }

        Label {
          width: parent.width
          textFormat: Text.PlainText
          font.pixelSize: 40
          fontSizeMode: Text.HorizontalFit
          anchors.bottom: parent.bottom
          anchors.bottomMargin: parent.height/10
          anchors.right: parent.right
          text: GC.formatNumber(logicalParent.errorCalculator.ACT_Energy) + " " + ModuleIntrospection.sec1Introspection.ComponentInfo.ACT_Energy.Unit
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
              duration: 1050
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
          else if(statusNotify === logicalParent.statusHolder.aborted)
          {
            visible = false;
          }
        }

        Label {
          width: parent.width
          textFormat: Text.PlainText
          horizontalAlignment: Text.AlignRight
          font.pixelSize: 40
          fontSizeMode: Text.HorizontalFit
          anchors.bottom: parent.bottom
          anchors.bottomMargin: parent.height/10
          anchors.right: parent.right
          text: GC.formatNumber(logicalParent.errorCalculator.ACT_Result)+"%"
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
      to: 100
      width: parent.width
      height: parent.height/20
      value: errorCalculator.ACT_Progress
      indeterminate: logicalParent.status === logicalParent.statusHolder.armed


      Label {
        visible: logicalParent.status !== logicalParent.statusHolder.ready
        textFormat: Text.PlainText
        anchors.bottom: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
        text: parseInt(actProgressBar.value)+"%"
      }
    }
  }
}
