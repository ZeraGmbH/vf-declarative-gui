import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/vf-controls" as VFControls
import "qrc:/qml/controls/settings" as SettingsControls

CCMP.ModulePage {
  id: root

  readonly property QtObject burdenModule: modeTabBar.currentItem.isVoltageBurden ? VeinEntity.getEntity("Burden1Module2") : VeinEntity.getEntity("Burden1Module1")
  readonly property var burdenIntrospection: modeTabBar.currentItem.isVoltageBurden ? ModuleIntrospection.burden2Introspection : ModuleIntrospection.burden1Introspection
  readonly property int rowCount: settingsView.model.count + burdenValueView.model.rowCount();
  readonly property int rowHeight: Math.floor(height/rowCount)
  readonly property int columnWidth: width/4.2 //0.7 + 3 + 0.5

  SettingsControls.SettingsView {
    id: settingsView
    anchors.left: parent.left
    anchors.right: parent.right
    height: root.height*model.count/root.rowCount

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
      VFControls.VFLineEdit {
        id: parNominalBurden
        height: root.rowHeight;
        width: root.width*0.9;

        description.text: ZTR["Nominal burden:"]
        description.width: root.width/4
        entity: root.burdenModule
        controlPropertyName: "PAR_NominalBurden"
        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
        unit.width: root.rowHeight*1.5

        validator: CCMP.ZDoubleValidator {
          bottom: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[0];
          top: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[2]);
        }
      }
      VFControls.VFLineEdit {
        id: parNominalRange
        height: root.rowHeight;
        width: root.width*0.9;

        description.text: ZTR["Nominal range:"]
        description.width: root.width/4
        entity: root.burdenModule
        controlPropertyName: "PAR_NominalRange"
        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
        unit.width: root.rowHeight*1.5

        validator: CCMP.ZDoubleValidator {
          bottom: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[0];
          top: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[2]);
        }
        CCMP.ZVisualComboBox {
          model: burdenIntrospection.ComponentInfo.PAR_NominalRangeFactor.Validation.Data
          imageModel: ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_sqrt_3.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png"]
          property int intermediate: model.indexOf(burdenModule.PAR_NominalRangeFactor);
          automaticIndexChange: true
          onIntermediateChanged: {
            if(currentIndex !== intermediate)
            {
              currentIndex = intermediate
            }
          }

          onSelectedTextChanged: {
            if(burdenModule.PAR_NominalRangeFactor !== selectedText)
            {
              burdenModule.PAR_NominalRangeFactor = selectedText
            }
          }

          anchors.left: parent.right
          anchors.leftMargin: 8
          anchors.top: parent.top
          //anchors.topMargin: root.rowHeight*0.1
          anchors.bottom: parent.bottom
          //anchors.bottomMargin: root.rowHeight*0.1
          width: root.width*0.09;
          contentRowHeight: height*1.2
          contentFlow: GridView.FlowTopToBottom
        }
      }
      VFControls.VFLineEdit {
        id: parWCrosssection
        height: root.rowHeight;
        width: root.width*0.9;

        description.text: ZTR["Wire crosssection:"]
        description.width: root.width/4
        entity: root.burdenModule
        controlPropertyName: "PAR_WCrosssection"
        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
        unit.width: root.rowHeight*1.5

        validator: CCMP.ZDoubleValidator {
          bottom: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[0];
          top: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[2]);
        }
      }
      VFControls.VFLineEdit {
        id: parWireLength
        height: root.rowHeight;
        width: root.width*0.9;

        description.text: ZTR["Wire length:"]
        description.width: root.width/4
        entity: root.burdenModule
        controlPropertyName: "PAR_WireLength"
        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
        unit.width: root.rowHeight*1.5

        validator: CCMP.ZDoubleValidator {
          bottom: burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[0];
          top: burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[1];
          decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[2]);
        }
      }
    }
  }
  ListView {
    id: burdenValueView
    height: root.rowHeight*model.rowCount()
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    model: modeTabBar.currentItem.isVoltageBurden ? ZGL.BurdenModelU : ZGL.BurdenModelI
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
