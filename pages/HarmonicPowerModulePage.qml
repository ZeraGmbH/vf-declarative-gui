import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import GlobalConfig 1.0
import Com5003Translation  1.0

import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root
  readonly property QtObject power3Module1: VeinEntity.getEntity("Power3Module1")

  property int rowHeight: Math.floor(height/20)
  property int columnWidth: width/7

  Item {
    width: root.width
    height: root.height
    anchors.centerIn: parent
    Row {
      anchors.bottom: harmonicHeaders.top
      anchors.left: parent.left
      anchors.right: parent.right

      height: root.rowHeight
      Item {
        //spacer
        width: root.columnWidth
        height: root.rowHeight
      }

      CCMP.GridItem {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "P1"
        textColor: GC.system1ColorDark
        textHorizontalAlignment: Label.AlignHCenter
        font.pixelSize: rowHeight
        font.bold: true
      }
      CCMP.GridItem {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "P2"
        textHorizontalAlignment: Label.AlignHCenter
        textColor: GC.system2ColorDark
        font.pixelSize: rowHeight
        font.bold: true
      }
      CCMP.GridItem {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "P3"
        textHorizontalAlignment: Label.AlignHCenter
        textColor: GC.system3ColorDark
        font.pixelSize: rowHeight
        font.bold: true
      }
    }

    Row {
      id: harmonicHeaders
      anchors.bottom: lvHarmonics.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: root.rowHeight

      CCMP.GridItem {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "n"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        font.bold: true
        text: ZTR["Real"]
        textColor: GC.system1ColorDark
        textHorizontalAlignment: Label.AlignHCenter
      }
      CCMP.GridItem {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        font.bold: true
        text: ZTR["Imaginary"]
        textColor: GC.system1ColorDark
        textHorizontalAlignment: Label.AlignHCenter
      }
      CCMP.GridItem {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        font.bold: true
        text: ZTR["Real"]
        textColor: GC.system2ColorDark
        textHorizontalAlignment: Label.AlignHCenter
      }
      CCMP.GridItem {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        font.bold: true
        text: ZTR["Imaginary"]
        textColor: GC.system2ColorDark
        textHorizontalAlignment: Label.AlignHCenter
      }
      CCMP.GridItem {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        font.bold: true
        text: ZTR["Real"]
        textColor: GC.system3ColorDark
        textHorizontalAlignment: Label.AlignHCenter
      }
      CCMP.GridItem {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        font.bold: true
        text: ZTR["Imaginary"]
        textColor: GC.system3ColorDark
        textHorizontalAlignment: Label.AlignHCenter
      }
    }

    ListView {
      id: lvHarmonics
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 4
      height: root.rowHeight*18

      model: 40
      boundsBehavior: Flickable.StopAtBounds
      cacheBuffer: root.rowHeight*4
      clip: true

      delegate: Component {
        Row {
          width: root.columnWidth
          height: root.rowHeight
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: Qt.lighter(GC.tableShadeColor, 1.0+(index/150))
            text: index
            font.bold: true
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: GC.formatNumber(power3Module1.ACT_HPW1[index*2])
            textColor: GC.system1ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: GC.formatNumber(power3Module1.ACT_HPW1[index*2+1])
            textColor: GC.system1ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: GC.formatNumber(power3Module1.ACT_HPW2[index*2])
            textColor: GC.system2ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: GC.formatNumber(power3Module1.ACT_HPW2[index*2+1])
            textColor: GC.system2ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: GC.formatNumber(power3Module1.ACT_HPW3[index*2])
            textColor: GC.system3ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            text: GC.formatNumber(power3Module1.ACT_HPW3[index*2+1])
            textColor: GC.system3ColorDark
          }
        }
      }
    }
  }
}
