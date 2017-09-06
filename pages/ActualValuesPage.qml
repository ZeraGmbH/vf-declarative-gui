import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import GlobalConfig 1.0
import ZeraGlueLogic 1.0

CCMP.ModulePage {
  id: root

  property bool sUnit : true;
  readonly property QtObject glueLogic: ZGL;

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
          CCMP.GridItem {
            width: root.columnWidth*0.7
            height: root.rowHeight
            color: GC.tableShadeColor
            text: Name!==undefined ? Name : ""
            font.bold: true
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L1!==undefined ? GC.formatNumber(L1) : ""
            textColor: GC.system1ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L2!==undefined ? GC.formatNumber(L2) : ""
            textColor: GC.system2ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L3!==undefined ? GC.formatNumber(L3) : ""
            textColor: GC.system3ColorDark
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: Sum ? GC.formatNumber(Sum) : ""
          }
          CCMP.GridItem {
            width: root.columnWidth/2
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: Unit ? Unit : ""
          }
        }
      }
    }
  }
}
