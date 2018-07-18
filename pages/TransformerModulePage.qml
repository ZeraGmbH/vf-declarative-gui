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
  readonly property QtObject transformerModule: VeinEntity.getEntity("Transformer1Module1")
  readonly property var transformerIntrospection: ModuleIntrospection.transformer1Introspection
  readonly property int rowHeight: Math.floor(height/9)

  CCMP.SettingsView {
    anchors.left: parent.left
    anchors.right: parent.right
    height: root.height*3/9

    model: VisualItemModel {
      Column {
        width: root.width
        Item {
          width: root.width
          height: root.rowHeight

          VFControls.VFLineEdit {
            id: parPrimClampPrim
            description.text: ZTR["Mp-Prim:"]
            description.width: root.width/10;
            height: root.rowHeight;
            width: root.width/2 - 8;

            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.transformerModule
            controlPropertyName: "PAR_PrimClampPrim"
            unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

            validator: CCMP.ZDoubleValidator {
              bottom: transformerIntrospection.ComponentInfo[parPrimClampPrim.controlPropertyName].Validation.Data[0];
              top: transformerIntrospection.ComponentInfo[parPrimClampPrim.controlPropertyName].Validation.Data[1];
              decimals: GC.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parPrimClampPrim.controlPropertyName].Validation.Data[2]);
            }
          }
          VFControls.VFLineEdit {
            id: parPrimClampSec
            anchors.right: parent.right
            description.text: ZTR["Mp-Sec:"]
            description.width: root.width/10;
            height: root.rowHeight;
            width: root.width/2 - 8;

            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.transformerModule
            controlPropertyName: "PAR_PrimClampSec"
            unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

            validator: CCMP.ZDoubleValidator {
              bottom: transformerIntrospection.ComponentInfo[parPrimClampSec.controlPropertyName].Validation.Data[0];
              top: transformerIntrospection.ComponentInfo[parPrimClampSec.controlPropertyName].Validation.Data[1];
              decimals:  GC.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parPrimClampSec.controlPropertyName].Validation.Data[2]);
            }
          }
        }
        Item {
          width: root.width
          height: root.rowHeight

          VFControls.VFLineEdit {
            id: parDutPrimary
            description.text: ZTR["X-Prim:"]
            description.width: root.width/10;
            height: root.rowHeight;
            width: root.width/2 - 8;

            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.transformerModule
            controlPropertyName: "PAR_DutPrimary"
            unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

            validator: CCMP.ZDoubleValidator {
              bottom: transformerIntrospection.ComponentInfo[parDutPrimary.controlPropertyName].Validation.Data[0];
              top: transformerIntrospection.ComponentInfo[parDutPrimary.controlPropertyName].Validation.Data[1];
              decimals: GC.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parDutPrimary.controlPropertyName].Validation.Data[2]);
            }
          }
          VFControls.VFLineEdit {
            id: parDutSecondary
            anchors.right: parent.right
            description.text: ZTR["X-Sec:"]
            description.width: root.width/10;
            height: root.rowHeight;
            width: root.width/2 - 8;

            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.transformerModule
            controlPropertyName: "PAR_DutSecondary"
            unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

            validator: CCMP.ZDoubleValidator {
              bottom: transformerIntrospection.ComponentInfo[parDutSecondary.controlPropertyName].Validation.Data[0];
              top: transformerIntrospection.ComponentInfo[parDutSecondary.controlPropertyName].Validation.Data[1];
              decimals: GC.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parDutSecondary.controlPropertyName].Validation.Data[2]);
            }
          }
        }
        Item {
          width: root.width
          height: root.rowHeight

          VFControls.VFLineEdit {
            id: parSecClampPrim
            description.text: ZTR["Ms-Prim:"]
            description.width: root.width/10;
            height: root.rowHeight;
            width: root.width/2 - 8;

            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.transformerModule
            controlPropertyName: "PAR_SecClampPrim"
            unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

            validator: CCMP.ZDoubleValidator {
              bottom: transformerIntrospection.ComponentInfo[parSecClampPrim.controlPropertyName].Validation.Data[0];
              top: transformerIntrospection.ComponentInfo[parSecClampPrim.controlPropertyName].Validation.Data[1];
              decimals:  GC.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parSecClampPrim.controlPropertyName].Validation.Data[2]);
            }
          }
          VFControls.VFLineEdit {
            id: parSecClampSec
            description.text: ZTR["Ms-Sec:"]
            description.width: root.width/10;
            height: root.rowHeight;
            width: root.width/2 - 8;
            anchors.right: parent.right

            inputMethodHints: Qt.ImhPreferNumbers

            entity: root.transformerModule
            controlPropertyName: "PAR_SecClampSec"
            unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

            validator: CCMP.ZDoubleValidator {
              bottom: transformerIntrospection.ComponentInfo[parSecClampSec.controlPropertyName].Validation.Data[0];
              top: transformerIntrospection.ComponentInfo[parSecClampSec.controlPropertyName].Validation.Data[1];
              decimals: GC.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parSecClampSec.controlPropertyName].Validation.Data[2]);
            }
          }
        }
      }
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    height: root.height*6/9
    width: root.width


    //Header
    Row {
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: ""
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.6
        height: root.rowHeight
        color: GC.tableShadeColor
        text: ZTR["TR1"]
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "[ ]"
        font.bold: true
      }
    }

    //Transformer Ratio
    Row {
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "X-Ratio"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.6
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Ratio1)
      }
      CCMP.GridRect {
        width: root.width*0.2
        height: root.rowHeight
      }
    }

    //Transformer Error
    Row {
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "X-ε"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.6
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Error1)
      }
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        text: "%"
      }
    }

    //Transformer angle in degree
    Row {
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "X-δ"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.6
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Angle1)
      }
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        text: transformerIntrospection.ComponentInfo.ACT_Angle1.Unit;
      }
    }

    //Transformer angle in centirad
    Row {
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "X-δ"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.6
        height: root.rowHeight
        text: GC.formatNumber(100 * transformerModule.ACT_Angle1 * Math.PI/180)
      }
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        text: ZTR["crad"];
      }
    }

    //Transformer angle in arcminutes
    Row {
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "X-δ"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.6
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Angle1*60)
      }
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        text: ZTR["arcmin"];
      }
    }
  }
}
