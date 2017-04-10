import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0
import Com5003Translation  1.0
import ModuleIntrospection 1.0

CCMP.ModulePage {
  id: root

  readonly property QtObject glueLogic: VeinEntity.getEntity("Local.GlueLogic");
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
          text: ZTR["U-Burden"]
          property bool isVoltageBurden: true
        }
        TabButton {
          text: ZTR["I-Burden"]
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

          CCMP.ComboBoxIntrospection {
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

          CCMP.ComboBoxIntrospection {
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

          CCMP.ComboBoxIntrospection {
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

          CCMP.ComboBoxIntrospection {
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
      width: root.columnWidth*4.2 //0.7 + 3 + 0.5
      model: modeTabBar.currentItem.isVoltageBurden ? glueLogic.BurdenModelU : glueLogic.BurdenModelI
      boundsBehavior: Flickable.StopAtBounds

      delegate: Component {
        Row {
          width: root.width
          height: root.rowHeight
          CCMP.GridRect {
            width: root.columnWidth*0.7
            height: root.rowHeight
            color: GC.tableShadeColor
            Label {
              text: Name ? Name : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              font.pixelSize: height*0.65
              fontSizeMode: Text.HorizontalFit
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
              font.pixelSize: height*0.65
              fontSizeMode: Text.HorizontalFit
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
              font.pixelSize: height*0.65
              fontSizeMode: Text.HorizontalFit
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
              font.pixelSize: height*0.65
              fontSizeMode: Text.HorizontalFit
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
              text: L4 ? GC.formatNumber(L4) : ""
              anchors.fill: parent
              anchors.rightMargin: 8
              color: GC.system4ColorDark
              font.pixelSize: height*0.65
              fontSizeMode: Text.HorizontalFit
              font.bold: index === 0
              font.family: "Droid Sans Mono"
              horizontalAlignment: Text.AlignRight
              verticalAlignment: Text.AlignVCenter
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
              font.pixelSize: height*0.65
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
