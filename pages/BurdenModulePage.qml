import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root

  readonly property QtObject glueLogic: ZGL;
  readonly property QtObject burdenModule: modeTabBar.currentItem.isVoltageBurden ? VeinEntity.getEntity("Burden1Module2") : VeinEntity.getEntity("Burden1Module1")
  readonly property var burdenIntrospection: modeTabBar.currentItem.isVoltageBurden ? ModuleIntrospection.burden2Introspection : ModuleIntrospection.burden1Introspection
  property int rowHeight: Math.floor(height/12)
  property int columnWidth: width/4.2 //0.7 + 3 + 0.5

  CCMP.SettingsView {
    anchors.left: parent.left
    anchors.right: parent.right
    height: root.height*5/12


    model: VisualItemModel {
      TabBar {
        id: modeTabBar
        width: parent.width
        height: rowHeight
        currentIndex: 0
        TabButton {
          text: ZTR["Voltage-Burden"]
          property bool isVoltageBurden: true
          height: rowHeight
        }
        TabButton {
          text: ZTR["Current-Burden"]
          property bool isVoltageBurden: false
          height: rowHeight
        }
      }

      Column {
        VFControls.VFLineEdit {
          id: parNominalBurden
          height: root.rowHeight;
          width: root.width*0.9;

          description.text: ZTR["Nominal burden:"]
          description.width: root.width/4.5
          entity: root.burdenModule
          controlPropertyName: "PAR_NominalBurden"
          inputMethodHints: Qt.ImhPreferNumbers
          unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
          unit.width: root.rowHeight*1.5

          validator: DoubleValidator {
            bottom: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[0];
            top: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[1];
            decimals: 15//burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[2];
          }
        }
        VFControls.VFLineEdit {
          id: parNominalRange
          height: root.rowHeight;
          width: root.width*0.9;

          description.text: ZTR["Nominal range:"]
          description.width: root.width/4.5
          entity: root.burdenModule
          controlPropertyName: "PAR_NominalRange"
          inputMethodHints: Qt.ImhPreferNumbers
          unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
          unit.width: root.rowHeight*1.5

          validator: DoubleValidator {
            bottom: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[0];
            top: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[1];
            decimals: 15//burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[2];
          }
          CCMP.ZVisualComboBox {
            arrayMode: true
            model: ["x_1", "x_sqrt_3", "x_1_over_sqrt_3"];
            imageModel: ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_sqrt_3.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png"]
            anchors.left: parent.right
            anchors.leftMargin: 8
            anchors.top: parent.top
            //anchors.topMargin: root.rowHeight*0.1
            anchors.bottom: parent.bottom
            //anchors.bottomMargin: root.rowHeight*0.1
            width: root.width*0.09;
          }
        }
        VFControls.VFLineEdit {
          id: parWCrosssection
          height: root.rowHeight;
          width: root.width*0.9;

          description.text: ZTR["Wire crosssection:"]
          description.width: root.width/4.5
          entity: root.burdenModule
          controlPropertyName: "PAR_WCrosssection"
          inputMethodHints: Qt.ImhPreferNumbers
          unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
          unit.width: root.rowHeight*1.5

          validator: DoubleValidator {
            bottom: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[0];
            top: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[1];
            decimals: 15//burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[2];
          }
        }
        VFControls.VFLineEdit {
          id: parWireLength
          height: root.rowHeight;
          width: root.width*0.9;

          description.text: ZTR["Wire length:"]
          description.width: root.width/4.5
          entity: root.burdenModule
          controlPropertyName: "PAR_WireLength"
          inputMethodHints: Qt.ImhPreferNumbers
          unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
          unit.width: root.rowHeight*1.5

          validator: DoubleValidator {
            bottom: burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[0];
            top: burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[1];
            decimals: 15//burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[2];
          }
        }
      }
    }
  }

  Item {
    width: root.width
    height: root.height*7/12
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    ListView {
      anchors.bottom: parent.bottom
      height: parent.height
      width: root.columnWidth*4.2 //0.7 + 3 + 0.5
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
