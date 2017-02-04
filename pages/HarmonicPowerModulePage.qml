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

      CCMP.GridRect {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "P1"
          anchors.centerIn: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system1ColorDark
          horizontalAlignment: Label.AlignRight
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "P2"
          anchors.centerIn: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system2ColorDark
          horizontalAlignment: Label.AlignRight
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "P3"
          anchors.centerIn: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system3ColorDark
          horizontalAlignment: Label.AlignRight
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
    }

    Row {
      id: harmonicHeaders
      anchors.bottom: lvHarmonics.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: root.rowHeight

      CCMP.GridRect {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "n"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: Material.primaryTextColor
          horizontalAlignment: Label.AlignHCenter
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: ZTR["Real"]
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system1ColorDark
          horizontalAlignment: Label.AlignHCenter
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: ZTR["Imaginary"]
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system1ColorDark
          horizontalAlignment: Label.AlignHCenter
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: ZTR["Real"]
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system2ColorDark
          horizontalAlignment: Label.AlignHCenter
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: ZTR["Imaginary"]
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system2ColorDark
          horizontalAlignment: Label.AlignHCenter
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: ZTR["Real"]
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system3ColorDark
          horizontalAlignment: Label.AlignHCenter
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.columnWidth
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: ZTR["Imaginary"]
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system3ColorDark
          horizontalAlignment: Label.AlignHCenter
          verticalAlignment: Label.AlignVCenter
          textFormat: Text.PlainText
        }
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
          CCMP.GridRect {
            width: root.columnWidth
            height: root.rowHeight
            color: Qt.lighter(GC.tableShadeColor, 1.0+(index/150))
            Label {
              text: index
              anchors.fill: parent
              anchors.rightMargin: 8
              font.pixelSize: rowHeight*0.5
              font.family: "Droid Sans Mono"
              font.bold: true
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              textFormat: Text.PlainText
            }
          }
          CCMP.GridRect {
            width: root.columnWidth
            height: root.rowHeight
            color: Material.backgroundColor
            Text {
              text: GC.formatNumber(power3Module1.ACT_HPW1[index*2])
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Text.AlignRight
              verticalAlignment: Text.AlignVCenter
              textFormat: Text.PlainText
            }
          }
          CCMP.GridRect {
            width: root.columnWidth
            height: root.rowHeight
            color: Material.backgroundColor
            Text {
              text: GC.formatNumber(power3Module1.ACT_HPW1[index*2+1])
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system1ColorDark
              font.pixelSize: rowHeight*0.5
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Text.AlignRight
              verticalAlignment: Text.AlignVCenter
              textFormat: Text.PlainText
            }
          }
          CCMP.GridRect {
            width: root.columnWidth
            height: root.rowHeight
            color: Material.backgroundColor
            Text {
              text: GC.formatNumber(power3Module1.ACT_HPW2[index*2])
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Text.AlignRight
              verticalAlignment: Text.AlignVCenter
              textFormat: Text.PlainText
            }
          }
          CCMP.GridRect {
            width: root.columnWidth
            height: root.rowHeight
            color: Material.backgroundColor
            Text {
              text: GC.formatNumber(power3Module1.ACT_HPW2[index*2+1])
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system2ColorDark
              font.pixelSize: rowHeight*0.5
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Text.AlignRight
              verticalAlignment: Text.AlignVCenter
              textFormat: Text.PlainText
            }
          }
          CCMP.GridRect {
            width: root.columnWidth
            height: root.rowHeight
            color: Material.backgroundColor
            Text {
              text: GC.formatNumber(power3Module1.ACT_HPW3[index*2])
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Text.AlignRight
              verticalAlignment: Text.AlignVCenter
              textFormat: Text.PlainText
            }
          }
          CCMP.GridRect {
            width: root.columnWidth
            height: root.rowHeight
            color: Material.backgroundColor
            Text {
              text: GC.formatNumber(power3Module1.ACT_HPW3[index*2+1])
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system3ColorDark
              font.pixelSize: rowHeight*0.5
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Text.AlignRight
              verticalAlignment: Text.AlignVCenter
              textFormat: Text.PlainText
            }
          }
        }
      }
    }
  }
}
