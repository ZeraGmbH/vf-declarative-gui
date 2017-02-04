import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import GlobalConfig 1.0


import ModuleIntrospection 1.0

Item {
  id: root

  readonly property QtObject glueLogic: VeinEntity.getEntity("Local.GlueLogic")
  readonly property QtObject fftModule: VeinEntity.getEntity("FFTModule1")

  property int rowHeight: Math.floor(height/20)
  property int columnWidth: width/13

  Item {
    width: root.columnWidth*13
    height: root.height
    anchors.centerIn: parent
    Row {
      anchors.bottom: harmonicHeaders.top
      anchors.left: parent.left
      anchors.right: parent.right

      height: root.rowHeight
      Item {
        width: root.columnWidth
        height: root.rowHeight
      }

      CCMP.GridRect {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "UL1"
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
          text: "UL2"
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
          text: "UL3"
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
      CCMP.GridRect {
        width: root.columnWidth*2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "IL1"
          anchors.centerIn: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system1ColorBright
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
          text: "IL2"
          anchors.centerIn: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system2ColorBright
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
          text: "IL3"
          anchors.centerIn: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system3ColorBright
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
          text: "Amp"
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
          text: "Phase"
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
          text: "Amp"
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
          text: "Phase"
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
          text: "Amp"
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
          text: "Phase"
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
          text: "Amp"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system1ColorBright
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
          text: "Phase"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system1ColorBright
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
          text: "Amp"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system2ColorBright
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
          text: "Phase"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system2ColorBright
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
          text: "Amp"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system3ColorBright
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
          text: "Phase"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: rowHeight*0.7
          font.family: "Droid Sans Mono"
          font.bold: true
          color: GC.system3ColorBright
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

      model: glueLogic.FFTTableModel
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
              text: AmplitudeL1 ? GC.formatNumber(AmplitudeL1, 3) : ""
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
              text: VectorL1 ? GC.formatNumber(VectorL1, 3) : ""
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
              text: AmplitudeL2 ? GC.formatNumber(AmplitudeL2, 3) : ""
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
              text: VectorL2 ? GC.formatNumber(VectorL2, 3) : ""
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
              text: AmplitudeL3 ? GC.formatNumber(AmplitudeL3, 3) : ""
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
              text: VectorL3 ? GC.formatNumber(VectorL3, 3) : ""
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
              text: AmplitudeL4 ? GC.formatNumber(AmplitudeL4, 3) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system1ColorBright
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
              text: VectorL4 ? GC.formatNumber(VectorL4, 3) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system1ColorBright
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
              text: AmplitudeL5 ? GC.formatNumber(AmplitudeL5, 3) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system2ColorBright
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
              text: VectorL5 ? GC.formatNumber(VectorL5, 3) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system2ColorBright
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
              text: AmplitudeL6 ? GC.formatNumber(AmplitudeL6, 3) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system3ColorBright
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
              text: VectorL6 ? GC.formatNumber(VectorL6, 3) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system3ColorBright
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
