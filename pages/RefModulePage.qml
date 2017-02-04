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
  property int wideRowWidth: width/7

  readonly property QtObject dftModule: VeinEntity.getEntity("DFTModule1")

  Row {
    id: heardersRow
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: root.top
    anchors.topMargin: root.height/2-rowHeight
    CCMP.GridRect {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor

      Label {
        text: "REF1"
        font.bold: true
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        font.pixelSize: height*0.3
      }
    }
    CCMP.GridRect {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor

      Label {
        text: "REF2"
        font.bold: true
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        font.pixelSize: height*0.3
      }
    }
    CCMP.GridRect {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor

      Label {
        text: "REF3"
        font.bold: true
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        font.pixelSize: height*0.3
      }
    }
    CCMP.GridRect {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor

      Label {
        text: "REF4"
        font.bold: true
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        font.pixelSize: height*0.3
      }
    }
    CCMP.GridRect {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor

      Label {
        text: "REF5"
        font.bold: true
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        font.pixelSize: height*0.3
      }
    }
    CCMP.GridRect {
      width: wideRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor

      Label {
        text: "REF6"
        font.bold: true
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        font.pixelSize: height*0.3
      }
    }
    CCMP.GridRect {
      width: basicRowWidth
      height: root.rowHeight
      color: GC.tableShadeColor

      Label {
        text: "[ ]"
        font.bold: true
        anchors.fill: parent
        anchors.rightMargin: 8
        horizontalAlignment: Label.AlignRight
        verticalAlignment: Label.AlignVCenter
        font.pixelSize: height*0.3
      }
    }
  }

  ListView {
    anchors.top: heardersRow.bottom
    anchors.left: heardersRow.left
    height: root.rowHeight*count
    width: parent.width
    //used number as model since the ListModel cannot use scripted values
    model: 1
    boundsBehavior: ListView.StopAtBounds
    interactive: false

    delegate: Component {
      Row {
        CCMP.GridRect {
          //ref1
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          Label {
            text: GC.formatNumber(dftModule.ACT_DFTPN1[0], 6); //these values are RE,IM vectors of a measured DC quantity, so only the RE part is relevant
            anchors.fill: parent
            anchors.rightMargin: 8
            horizontalAlignment: Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            color: GC.groupColorReference
            font.pixelSize: height*0.3
          }
        }
        CCMP.GridRect {
          //ref2
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          Label {
            text: GC.formatNumber(dftModule.ACT_DFTPN2[0], 6);
            anchors.fill: parent
            anchors.rightMargin: 8
            horizontalAlignment: Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            color: GC.groupColorReference
            font.pixelSize: height*0.3
          }
        }
        CCMP.GridRect {
          //ref3
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          Label {
            text: GC.formatNumber(dftModule.ACT_DFTPN3[0], 6);
            anchors.fill: parent
            anchors.rightMargin: 8
            horizontalAlignment: Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            color: GC.groupColorReference
            font.pixelSize: height*0.3
          }
        }
        CCMP.GridRect {
          //ref4
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          Label {
            text: GC.formatNumber(dftModule.ACT_DFTPN4[0], 6);
            anchors.fill: parent
            anchors.rightMargin: 8
            horizontalAlignment: Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            color: GC.groupColorReference
            font.pixelSize: height*0.3
          }
        }
        CCMP.GridRect {
          //ref5
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          Label {
            text: GC.formatNumber(dftModule.ACT_DFTPN5[0], 6);
            anchors.fill: parent
            anchors.rightMargin: 8
            horizontalAlignment: Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            color: GC.groupColorReference
            font.pixelSize: height*0.3
          }
        }
        CCMP.GridRect {
          //ref6
          width: wideRowWidth
          height: root.rowHeight
          clip: true
          Label {
            text: GC.formatNumber(dftModule.ACT_DFTPN6[0], 6);
            anchors.fill: parent
            anchors.rightMargin: 8
            horizontalAlignment: Label.AlignRight
            verticalAlignment: Label.AlignVCenter
            color: GC.groupColorReference
            font.pixelSize: height*0.3
          }
        }
        CCMP.GridRect {
          //unit
          width: basicRowWidth
          height: root.rowHeight
          Label {
            text: "V"
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
