import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import SortFilterProxyModel 0.2
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP

CCMP.ModulePage {
  id: root

  readonly property int channelCount: ModuleIntrospection.rmsIntrospection.ModuleInfo.RMSPNCount;
  readonly property int row1stHeight: Math.floor(height/8)
  readonly property int rowHeight: Math.floor((height-row1stHeight)/4)
  readonly property int columnWidth: width/4.7

  SortFilterProxyModel {
    id: filteredActualValueModel
    sourceModel: ZGL.ActualValueModel

    filters: [
      RegExpFilter {
        //match all that have data for UN and IN
        roleName: channelCount > 6 ? "AUX" : "L1"
        pattern: "[^()]"
        caseSensitivity: Qt.CaseInsensitive
      }
    ]
  }

  Item {
    anchors.fill: parent
    ListView {
      anchors.fill: parent
      model: filteredActualValueModel //ZGL.ActualValueModel
      boundsBehavior: Flickable.StopAtBounds

      delegate: Component {
        Row {
          width: root.columnWidth*5.2
          height: index === 0 ? root.row1stHeight : root.rowHeight
          CCMP.GridItem {
            width: root.columnWidth*0.5
            height: parent.height
            color: GC.tableShadeColor
            text: Name!==undefined ? Name : ""
            font.pixelSize: root.rowHeight*0.35
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: parent.height
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L1!==undefined ? GC.formatNumber(L1) : ""
            textColor: GC.system1ColorDark
            font.pixelSize: root.rowHeight*0.35
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: parent.height
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L2!==undefined ? GC.formatNumber(L2) : ""
            textColor: GC.system2ColorDark
            font.pixelSize: root.rowHeight*0.35
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: parent.height
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L3!==undefined ? GC.formatNumber(L3) : ""
            textColor: GC.system3ColorDark
            font.pixelSize: root.rowHeight*0.35
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: parent.height
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: AUX!==undefined ? GC.formatNumber(AUX) : ""
            textColor: GC.system4ColorDark
            font.pixelSize: root.rowHeight*0.35
          }
          CCMP.GridItem {
            width: root.columnWidth/5
            height: parent.height
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: Unit ? Unit : ""
            font.pixelSize: root.rowHeight*0.35
          }
        }
      }
    }
  }
}
