import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import SortFilterProxyModel 0.2
import "qrc:/qml/controls" as CCMP

CCMP.ModulePage {
  id: root

  readonly property int rowCount: 10; //do not saturate the whole height with 5 rows
  readonly property int rowHeight: Math.floor(height/rowCount)
  readonly property int columnWidth: width/5.25

  SortFilterProxyModel {
    id: filteredActualValueModel
    sourceModel: ZGL.ActualValueModel

    filters: [
      RegExpFilter {
        //match all that have data for UN and IN
        roleName: "AUX"
        pattern: "[^()]"
        caseSensitivity: Qt.CaseInsensitive
      }
    ]
  }

  Item {
    width: root.columnWidth*5.25
    height: root.height*0.95
    anchors.centerIn: parent
    ListView {
      anchors.fill: parent
      model: filteredActualValueModel //glueLogic.ActualValueModel
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
            font.pixelSize: Math.min(height*0.65, width*0.2)
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L1!==undefined ? GC.formatNumber(L1) : ""
            textColor: GC.system1ColorDark
            font.pixelSize: Math.min(height*0.65, width*0.125)
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L2!==undefined ? GC.formatNumber(L2) : ""
            textColor: GC.system2ColorDark
            font.pixelSize: Math.min(height*0.65, width*0.125)
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L3!==undefined ? GC.formatNumber(L3) : ""
            textColor: GC.system3ColorDark
            font.pixelSize: Math.min(height*0.65, width*0.125)
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: AUX!==undefined ? GC.formatNumber(AUX) : ""
            textColor: GC.system4ColorDark
            font.pixelSize: Math.min(height*0.65, width*0.125)
          }
          CCMP.GridItem {
            width: root.columnWidth/2
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: Unit ? Unit : ""
            font.pixelSize: Math.min(height*0.65, width*0.25)
          }
        }
      }
    }
  }
}
