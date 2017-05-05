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
  readonly property QtObject transformerModule: VeinEntity.getEntity("Transformer1Module1")
  readonly property var transformerIntrospection: ModuleIntrospection.transformer1Introspection
  readonly property int rowHeight: Math.floor(height/14)

  CCMP.SettingsView {
    anchors.left: parent.left
    anchors.right: parent.right
    height: root.height/3

    RegExpValidator {
      id: inputValidator
      //match floating point numbers with 7 decimal places between 1e-6 to 1e+6
      regExp: /\-?[0-9]+(\.[0-9]+)?([eE][\+\-]?[0-6])?/;
      readonly property int decimals: 15
      readonly property real top: 1.0e+6;
      readonly property real bottom: 1.0e-6;
    }


    model: VisualItemModel {
      Column {
        Item {
          width: root.width
          height: root.rowHeight*1.5


          RowLayout {
            height: root.rowHeight;
            width: root.width/2 - 8;
            spacing: 16
            Label {
              text: ZTR["Mp-Prim:"]
              height: root.rowHeight
              anchors.verticalCenter: parent.verticalCenter
              font.pixelSize: Math.max(height/2, 20)
              Layout.preferredWidth: 100
            }
            VFControls.VFLineEdit {
              height: root.rowHeight;
              Layout.fillWidth: true

              inputMethodHints: Qt.ImhPreferNumbers

              entity: root.transformerModule
              controlPropertyName: "PAR_PrimClampPrim"
              unit: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

              validator: inputValidator
            }
          }

          RowLayout {
            height: root.rowHeight;
            width: root.width/2 - 8;
            anchors.right: parent.right
            spacing: 16

            Label {
              text: ZTR["Mp-Sec:"]
              height: root.rowHeight
              anchors.verticalCenter: parent.verticalCenter
              font.pixelSize: Math.max(height/2, 20)
              Layout.preferredWidth: 100
            }
            VFControls.VFLineEdit {
              height: root.rowHeight;
              Layout.fillWidth: true

              inputMethodHints: Qt.ImhPreferNumbers

              entity: root.transformerModule
              controlPropertyName: "PAR_PrimClampSec"
              unit: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

              validator: inputValidator
            }
          }
        }
        Item {
          width: root.width
          height: root.rowHeight*1.5


          RowLayout {
            height: root.rowHeight;
            width: root.width/2 - 8;
            spacing: 16
            Label {
              text: ZTR["X-Prim:"]
              height: root.rowHeight
              anchors.verticalCenter: parent.verticalCenter
              font.pixelSize: Math.max(height/2, 20)
              Layout.preferredWidth: 100
            }

            VFControls.VFLineEdit {
              height: root.rowHeight;
              Layout.fillWidth: true

              inputMethodHints: Qt.ImhPreferNumbers

              entity: root.transformerModule
              controlPropertyName: "PAR_DutPrimary"
              unit: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

              validator: inputValidator

            }
          }

          RowLayout {
            height: root.rowHeight;
            width: root.width/2 - 8;
            anchors.right: parent.right
            spacing: 16

            Label {
              text: ZTR["X-Sec:"]
              height: root.rowHeight
              anchors.verticalCenter: parent.verticalCenter
              font.pixelSize: Math.max(height/2, 20)
              Layout.preferredWidth: 100
            }
            VFControls.VFLineEdit {
              height: root.rowHeight;
              Layout.fillWidth: true

              inputMethodHints: Qt.ImhPreferNumbers

              entity: root.transformerModule
              controlPropertyName: "PAR_DutSecondary"
              unit: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

              validator: inputValidator
            }
          }
        }
        Item {
          width: root.width
          height: root.rowHeight*1.5


          RowLayout {
            height: root.rowHeight;
            width: root.width/2 - 8;
            spacing: 16
            Label {
              text: ZTR["Ms-Prim:"]
              height: root.rowHeight
              anchors.verticalCenter: parent.verticalCenter
              font.pixelSize: Math.max(height/2, 20)
              Layout.preferredWidth: 100
            }

            VFControls.VFLineEdit {
              height: root.rowHeight;
              Layout.fillWidth: true

              inputMethodHints: Qt.ImhPreferNumbers

              entity: root.transformerModule
              controlPropertyName: "PAR_SecClampPrim"
              unit: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

              validator: inputValidator
            }
          }

          RowLayout {
            height: root.rowHeight;
            width: root.width/2 - 8;
            anchors.right: parent.right
            spacing: 16

            Label {
              text: ZTR["Ms-Sec:"]
              height: root.rowHeight
              anchors.verticalCenter: parent.verticalCenter
              font.pixelSize: Math.max(height/2, 20)
              Layout.preferredWidth: 100
            }
            VFControls.VFLineEdit {
              height: root.rowHeight;
              Layout.fillWidth: true

              inputMethodHints: Qt.ImhPreferNumbers

              entity: root.transformerModule
              controlPropertyName: "PAR_SecClampSec"
              unit: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

              validator: inputValidator
            }
          }
        }
      }
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    height: root.height*2/3
    width: root.width*0.7


    //Header
    Row {
      CCMP.GridItem {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "Name"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.35
        height: root.rowHeight
        color: GC.tableShadeColor
        text: "TR1"
        font.bold: true
      }
      CCMP.GridItem {
        width: root.width*0.15
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
        width: root.width*0.35
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Ratio1)
      }
      CCMP.GridRect {
        width: root.width*0.15
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
        width: root.width*0.35
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Error1)
      }
      CCMP.GridItem {
        width: root.width*0.15
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
        width: root.width*0.35
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Angle1)
      }
      CCMP.GridItem {
        width: root.width*0.15
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
        width: root.width*0.35
        height: root.rowHeight
        text: GC.formatNumber(100 * transformerModule.ACT_Angle1 * Math.PI/180)
      }
      CCMP.GridItem {
        width: root.width*0.15
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
        width: root.width*0.35
        height: root.rowHeight
        text: GC.formatNumber(transformerModule.ACT_Angle1*60)
      }
      CCMP.GridItem {
        width: root.width*0.15
        height: root.rowHeight
        text: ZTR["arcmin"];
      }
    }
  }
}
