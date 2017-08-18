import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0
import Com5003GlueLogic 1.0
import Com5003Translation  1.0
import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root

  readonly property QtObject glueLogic: ZGL;
  readonly property QtObject burdenModule: modeTabBar.currentItem.isVoltageBurden ? VeinEntity.getEntity("Burden1Module2") : VeinEntity.getEntity("Burden1Module1")
  readonly property var burdenIntrospection: modeTabBar.currentItem.isVoltageBurden ? ModuleIntrospection.burden2Introspection : ModuleIntrospection.burden1Introspection
  property int rowHeight: Math.floor(height/14) * 0.95
  property int columnWidth: width/5.2

  CCMP.SettingsView {
    anchors.left: parent.left
    anchors.right: parent.right
    height: root.height*0.5


    model: VisualItemModel {
      TabBar {
        id: modeTabBar
        width: parent.width
        currentIndex: 0
        TabButton {
          text: ZTR["Voltage-Burden"]
          property bool isVoltageBurden: true
        }
        TabButton {
          text: ZTR["Current-Burden"]
          property bool isVoltageBurden: false
        }
      }

      Column {
        VFControls.VFSpinBox {
          height: root.rowHeight*1.5;
          width: root.width;

          intermediateValue: burdenModule.PAR_NominalBurden
          text: ZTR["Nominal burden:"]
          onOutValueChanged: {
            burdenModule.PAR_NominalBurden = Number(outValue)
          }

          CCMP.SpinBoxIntrospection {
            unit: burdenIntrospection.ComponentInfo.PAR_NominalBurden.Unit;
            upperBound: burdenIntrospection.ComponentInfo.PAR_NominalBurden.Validation.Data[1];
            lowerBound: burdenIntrospection.ComponentInfo.PAR_NominalBurden.Validation.Data[0];
            stepSize: burdenIntrospection.ComponentInfo.PAR_NominalBurden.Validation.Data[2];
            Component.onCompleted: parent.introspection = this
          }
        }
        VFControls.VFSpinBox {
          height: root.rowHeight*1.5;
          width: root.width;

          intermediateValue: burdenModule.PAR_NominalRange
          text: ZTR["Nominal range:"]
          onOutValueChanged: {
            burdenModule.PAR_NominalRange = Number(outValue)
          }

          CCMP.SpinBoxIntrospection {
            unit: burdenIntrospection.ComponentInfo.PAR_NominalRange.Unit;
            upperBound: burdenIntrospection.ComponentInfo.PAR_NominalRange.Validation.Data[1];
            lowerBound: burdenIntrospection.ComponentInfo.PAR_NominalRange.Validation.Data[0];
            stepSize: burdenIntrospection.ComponentInfo.PAR_NominalRange.Validation.Data[2];
            Component.onCompleted: parent.introspection = this
          }
        }
        VFControls.VFSpinBox {
          height: root.rowHeight*1.5;
          width: root.width;

          intermediateValue: burdenModule.PAR_WCrosssection
          text: ZTR["Wire crosssection:"]
          onOutValueChanged: {
            burdenModule.PAR_WCrosssection = Number(outValue)
          }

          CCMP.SpinBoxIntrospection {
            unit: burdenIntrospection.ComponentInfo.PAR_WCrosssection.Unit;
            upperBound: burdenIntrospection.ComponentInfo.PAR_WCrosssection.Validation.Data[1];
            lowerBound: burdenIntrospection.ComponentInfo.PAR_WCrosssection.Validation.Data[0];
            stepSize: burdenIntrospection.ComponentInfo.PAR_WCrosssection.Validation.Data[2];
            Component.onCompleted: parent.introspection = this
          }
        }
        VFControls.VFSpinBox {
          height: root.rowHeight*1.5;
          width: root.width;

          intermediateValue: burdenModule.PAR_WireLength
          text: ZTR["Wire length:"]
          onOutValueChanged: {
            burdenModule.PAR_WireLength = Number(outValue)
          }

          CCMP.SpinBoxIntrospection {
            unit: burdenIntrospection.ComponentInfo.PAR_WireLength.Unit;
            upperBound: burdenIntrospection.ComponentInfo.PAR_WireLength.Validation.Data[1];
            lowerBound: burdenIntrospection.ComponentInfo.PAR_WireLength.Validation.Data[0];
            stepSize: burdenIntrospection.ComponentInfo.PAR_WireLength.Validation.Data[2];
            Component.onCompleted: parent.introspection = this
          }
        }
      }
    }
  }

  Item {
    width: root.width
    anchors.left: parent.left
    height: root.height*0.5
    anchors.bottom: parent.bottom
    ListView {
      height: parent.height
      width: root.columnWidth*5.2 //0.7 + 4 + 0.5
      model: modeTabBar.currentItem.isVoltageBurden ? glueLogic.BurdenModelU : glueLogic.BurdenModelI
      boundsBehavior: Flickable.StopAtBounds

      delegate: Component {
        Row {
          width: root.width
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
            font.bold: index === 0
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L2!==undefined ? GC.formatNumber(L2) : ""
            textColor: GC.system2ColorDark
            font.bold: index === 0
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L3!==undefined ? GC.formatNumber(L3) : ""
            textColor: GC.system3ColorDark
            font.bold: index === 0
          }
          CCMP.GridItem {
            width: root.columnWidth
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: L4!==undefined ? GC.formatNumber(L4) : ""
            textColor: GC.system4ColorDark
            font.bold: index === 0
          }
          CCMP.GridItem {
            width: root.columnWidth/2
            height: root.rowHeight
            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
            text: Unit ? Unit : ""
            font.bold: index === 0
          }
        }
      }
    }
  }
}
