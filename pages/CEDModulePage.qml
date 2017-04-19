import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0

import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root

  property int rowHeight: Math.floor(height/8)
  property int basicRowWidth: width/10
  property int wideRowWidth: width/5

  readonly property QtObject power2Module1: VeinEntity.getEntity("POWER2Module1")

  function getProperty(index) {
    var retVal=String("");
    switch(index) {
    case 0:
      retVal = "ACT_PP%1";
      break;
    case 1:
      retVal = "ACT_PM%1";
      break;
    case 2:
      retVal = "ACT_P%1";
      break;
    }
    return retVal;
  }

  function getIntrospection(index) {
    var retVal;
    switch(index) {
    case 0:
      retVal = ModuleIntrospection.p2m1Introspection.ComponentInfo.ACT_PP1;
      break;
    case 1:
      retVal = ModuleIntrospection.p2m1Introspection.ComponentInfo.ACT_PM1;
      break;
    case 2:
      retVal = ModuleIntrospection.p2m1Introspection.ComponentInfo.ACT_P1;
      break;
    }
    return retVal;
  }
  Item {
    anchors.fill: parent
    Row {
      id: heardersRow
      CCMP.GridRect {
        width: basicRowWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        //spacer
      }
      CCMP.GridItem {
        width: wideRowWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "L1"
        textColor: GC.system1ColorDark
        font.pixelSize: height*0.3
        font.bold: true
      }
      CCMP.GridItem {
        width: wideRowWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "L2"
        textColor: GC.system2ColorDark
        font.pixelSize: height*0.3
        font.bold: true
      }
      CCMP.GridItem {
        width: wideRowWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "L3"
        textColor: GC.system3ColorDark
        font.pixelSize: height*0.3
        font.bold: true
      }
      CCMP.GridItem {
        width: wideRowWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "Σ"
        textColor: GC.system3ColorDark
        font.pixelSize: height*0.3
        font.bold: true
      }
      CCMP.GridItem {
        width: basicRowWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "[ ]"
        font.pixelSize: height*0.3
        font.bold: true
      }
    }

    ListView {
      anchors.top: heardersRow.bottom
      height: root.rowHeight*count
      width: parent.width
      //used number as model since the ListModel cannot use scripted values
      model: 3
      boundsBehavior: ListView.StopAtBounds
      interactive: false

      delegate: Component {
        Row {
          CCMP.GridRect {
            //title
            width: basicRowWidth
            height: root.rowHeight
            color: GC.tableShadeColor

            Label {
              //text: root.getIntrospection(index).ChannelName;
              text: {
                var retVal = "";
                switch(index) {
                case 0:
                  retVal = "+P";
                  break;
                case 1:
                  retVal = "-P";
                  break;
                case 2:
                  retVal = "P";
                  break;
                }
                return retVal;
              }

              font.bold: true
              anchors.fill: parent
              anchors.rightMargin: 8
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              font.pixelSize: height*0.3
            }
          }
          CCMP.GridRect {
            //l1
            width: wideRowWidth
            height: root.rowHeight
            clip: true
            Label {
              text: GC.formatNumber(root.power2Module1[String(root.getProperty(index)).arg(1)]);
              anchors.fill: parent
              anchors.rightMargin: 8
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              color: GC.system1ColorDark
              font.pixelSize: height*0.3
            }
          }
          CCMP.GridRect {
            //l2
            width: wideRowWidth
            height: root.rowHeight
            clip: true
            Label {
              text: GC.formatNumber(root.power2Module1[String(root.getProperty(index)).arg(2)]);
              anchors.fill: parent
              anchors.rightMargin: 8
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              color: GC.system2ColorDark
              font.pixelSize: height*0.3
            }
          }
          CCMP.GridRect {
            //l3
            width: wideRowWidth
            height: root.rowHeight
            clip: true
            Label {
              text: GC.formatNumber(root.power2Module1[String(root.getProperty(index)).arg(3)]);
              anchors.fill: parent
              anchors.rightMargin: 8
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              color: GC.system3ColorBright
              font.pixelSize: height*0.3
            }
          }
          CCMP.GridRect {
            //pSum
            width: wideRowWidth
            height: root.rowHeight
            clip: true
            Label {
              text: GC.formatNumber(root.power2Module1[String(root.getProperty(index)).arg(4)]);
              anchors.fill: parent
              anchors.rightMargin: 8
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              font.pixelSize: height*0.3
            }
          }
          CCMP.GridRect {
            //unit
            width: basicRowWidth
            height: root.rowHeight

            Label {
              text: root.getIntrospection(index).Unit;
              anchors.fill: parent
              anchors.rightMargin: 8
              font.bold: true
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              font.pixelSize: height*0.3
            }
          }
        }
      }
    }
  }
}
