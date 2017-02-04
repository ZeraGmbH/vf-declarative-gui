import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import GlobalConfig 1.0

CCMP.ModulePage {
  id: root

  property bool sUnit : true;
  readonly property QtObject glueLogic: VeinEntity.getEntity("Local.GlueLogic");

  property int rowHeight: Math.floor(height/14) * 0.95
  property int columnWidth: width/5.25

  Item {
    width: root.columnWidth*5.25
    height: root.height*0.95
    anchors.centerIn: parent
    ListView {
      anchors.fill: parent
      model: glueLogic.ActualValueModel
      boundsBehavior: Flickable.StopAtBounds

      delegate: Component {
        Row {
          width: root.columnWidth*5.2
          height: root.rowHeight
          CCMP.GridRect {
            width: root.columnWidth*0.7
            height: root.rowHeight
            color: GC.tableShadeColor
            Label {
              text: Name ? Name : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              font.pixelSize: height*0.7
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
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            Text {
              text: L1 ? GC.formatNumber(L1) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system1ColorDark
              font.pixelSize: height*0.7
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
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            Text {
              text: L2 ? GC.formatNumber(L2) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system2ColorDark
              font.pixelSize: height*0.7
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
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            Text {
              text: L3 ? GC.formatNumber(L3) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system3ColorDark
              font.pixelSize: height*0.7
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
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            Label {
              text: Sum ? GC.formatNumber(Sum) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              font.pixelSize: height*0.7
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              textFormat: Text.PlainText
            }
          }
          CCMP.GridRect {
            width: root.columnWidth/2
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            Label {
              text: Unit ? Unit : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              font.pixelSize: height*0.7
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Label.AlignRight
              verticalAlignment: Label.AlignVCenter
              textFormat: Text.PlainText
            }
          }
        }
      }
    }
  }
}
