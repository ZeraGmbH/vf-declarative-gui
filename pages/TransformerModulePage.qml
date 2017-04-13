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


    model: VisualItemModel {
      Column {
        Item {
          width: root.width
          height: root.rowHeight*1.5
          VFControls.VFSpinBox {
            height: root.rowHeight*1.5;
            width: root.width/2 - 8;
            anchors.left: parent.left

            intermediateValue: transformerModule.PAR_PrimClampPrim
            text: ZTR["Mp-Prim:"]
            onOutValueChanged: {
              transformerModule.PAR_PrimClampPrim = Number(outValue)
            }

            CCMP.SpinBoxIntrospection {
              unit: transformerIntrospection.ComponentInfo.PAR_PrimClampPrim.Unit;
              upperBound: transformerIntrospection.ComponentInfo.PAR_PrimClampPrim.Validation.Data[1];
              lowerBound: transformerIntrospection.ComponentInfo.PAR_PrimClampPrim.Validation.Data[0];
              stepSize: transformerIntrospection.ComponentInfo.PAR_PrimClampPrim.Validation.Data[2];
              Component.onCompleted: parent.introspection = this
            }
          }
          VFControls.VFSpinBox {
            height: root.rowHeight*1.5;
            width: root.width/2;
            anchors.right: parent.right

            intermediateValue: transformerModule.PAR_PrimClampSec
            text: ZTR["Mp-Sec:"]
            onOutValueChanged: {
              transformerModule.PAR_PrimClampSec = Number(outValue)
            }

            CCMP.SpinBoxIntrospection {
              unit: transformerIntrospection.ComponentInfo.PAR_PrimClampSec.Unit;
              upperBound: transformerIntrospection.ComponentInfo.PAR_PrimClampSec.Validation.Data[1];
              lowerBound: transformerIntrospection.ComponentInfo.PAR_PrimClampSec.Validation.Data[0];
              stepSize: transformerIntrospection.ComponentInfo.PAR_PrimClampSec.Validation.Data[2];
              Component.onCompleted: parent.introspection = this
            }
          }
        }
        Item {
          width: root.width
          height: root.rowHeight*1.5
          VFControls.VFSpinBox {
            height: root.rowHeight*1.5;
            width: root.width/2 - 8;
            anchors.left: parent.left

            intermediateValue: transformerModule.PAR_DutPrimary
            text: ZTR["X-Prim:"]
            onOutValueChanged: {
              transformerModule.PAR_DutPrimary = Number(outValue)
            }

            CCMP.SpinBoxIntrospection {
              unit: transformerIntrospection.ComponentInfo.PAR_DutPrimary.Unit;
              upperBound: transformerIntrospection.ComponentInfo.PAR_DutPrimary.Validation.Data[1];
              lowerBound: transformerIntrospection.ComponentInfo.PAR_DutPrimary.Validation.Data[0];
              stepSize: transformerIntrospection.ComponentInfo.PAR_DutPrimary.Validation.Data[2];
              Component.onCompleted: parent.introspection = this
            }
          }

          VFControls.VFSpinBox {
            height: root.rowHeight*1.5;
            width: root.width/2 - 8;
            anchors.right: parent.right

            intermediateValue: transformerModule.PAR_DutSecondary
            text: ZTR["X-Sec:"]
            onOutValueChanged: {
              transformerModule.PAR_DutSecondary = Number(outValue)
            }

            CCMP.SpinBoxIntrospection {
              unit: transformerIntrospection.ComponentInfo.PAR_DutSecondary.Unit;
              upperBound: transformerIntrospection.ComponentInfo.PAR_DutSecondary.Validation.Data[1];
              lowerBound: transformerIntrospection.ComponentInfo.PAR_DutSecondary.Validation.Data[0];
              stepSize: transformerIntrospection.ComponentInfo.PAR_DutSecondary.Validation.Data[2];
              Component.onCompleted: parent.introspection = this
            }
          }
        }
        Item {
          width: root.width
          height: root.rowHeight*1.5
          VFControls.VFSpinBox {
            height: root.rowHeight*1.5;
            width: root.width/2 - 8;
            anchors.left: parent.left

            intermediateValue: transformerModule.PAR_SecClampPrim
            text: ZTR["Ms-Prim:"]
            onOutValueChanged: {
              transformerModule.PAR_SecClampPrim = Number(outValue)
            }

            CCMP.SpinBoxIntrospection {
              unit: transformerIntrospection.ComponentInfo.PAR_SecClampPrim.Unit;
              upperBound: transformerIntrospection.ComponentInfo.PAR_SecClampPrim.Validation.Data[1];
              lowerBound: transformerIntrospection.ComponentInfo.PAR_SecClampPrim.Validation.Data[0];
              stepSize: transformerIntrospection.ComponentInfo.PAR_SecClampPrim.Validation.Data[2];
              Component.onCompleted: parent.introspection = this
            }
          }
          VFControls.VFSpinBox {
            height: root.rowHeight*1.5;
            width: root.width/2 - 8;
            anchors.right: parent.right

            intermediateValue: transformerModule.PAR_SecClampSec
            text: ZTR["Ms-Sec:"]
            onOutValueChanged: {
              transformerModule.PAR_SecClampSec = Number(outValue)
            }

            CCMP.SpinBoxIntrospection {
              unit: transformerIntrospection.ComponentInfo.PAR_SecClampSec.Unit;
              upperBound: transformerIntrospection.ComponentInfo.PAR_SecClampSec.Validation.Data[1];
              lowerBound: transformerIntrospection.ComponentInfo.PAR_SecClampSec.Validation.Data[0];
              stepSize: transformerIntrospection.ComponentInfo.PAR_SecClampSec.Validation.Data[2];
              Component.onCompleted: parent.introspection = this
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
      CCMP.GridRect {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "Name"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.35
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "TR1"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.15
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "[ ]"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
    }

    //Transformer Ratio
    Row {
      CCMP.GridRect {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "X-Ratio"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.35
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: GC.formatNumber(transformerModule.ACT_Ratio1)
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.15
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: ""
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
    }

    //Transformer Error
    Row {
      CCMP.GridRect {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "X-ε"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.35
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: GC.formatNumber(transformerModule.ACT_Error1)
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.15
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: "%"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
    }

    //Transformer angle in degree
    Row {
      CCMP.GridRect {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "X-δ"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.35
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: GC.formatNumber(transformerModule.ACT_Angle1)
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.15
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: transformerIntrospection.ComponentInfo.ACT_Angle1.Unit;
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
    }

    //Transformer angle in centirad
    Row {
      CCMP.GridRect {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "X-δ"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.35
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: GC.formatNumber(100 * transformerModule.ACT_Angle1 * Math.PI/180)
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.15
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: ZTR["crad"];
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
    }

    //Transformer angle in arcminutes
    Row {
      CCMP.GridRect {
        width: root.width*0.2
        height: root.rowHeight
        color: GC.tableShadeColor
        Label {
          text: "X-δ"
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.bold: true
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.35
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: GC.formatNumber(transformerModule.ACT_Angle1*60)
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
      CCMP.GridRect {
        width: root.width*0.15
        height: root.rowHeight
        color: Material.backgroundColor
        Label {
          text: ZTR["arcmin"];
          anchors.fill: parent
          anchors.rightMargin: 8
          font.pixelSize: height*0.65
          fontSizeMode: Text.HorizontalFit
          font.family: "Droid Sans Mono"
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          textFormat: Text.PlainText
        }
      }
    }
  }
}
