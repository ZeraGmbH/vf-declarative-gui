import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import "../controls"
import "qrc:/qml/controls/settings" as SettingsControls

Item {
    id: root

    readonly property QtObject transformerModule: VeinEntity.getEntity("Transformer1Module1")
    readonly property var transformerIntrospection: ModuleIntrospection.transformer1Introspection
    readonly property int rowHeight: Math.floor(height/12)

    // We are:
    // not part of swipe/tab combo
    // loaded on demand (see main.qml / pageLoader.source)
    Component.onCompleted: {
        GC.currentGuiContext = GC.guiContextEnum.GUI_INSTRUMENT_TRANSFORMER
    }

    // could be replaced by a VisualItemModel
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        height: root.height*9/12
        width: root.width

        //Header
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: ""
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                color: GC.tableShadeColor
                text: Z.tr("TR1")
                font.bold: true
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: "[ ]"
                font.bold: true
            }
        }

        // transformer primary
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: Z.tr("X-Prim");
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(transformerModule.ACT_IXPrimary1)
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                text: transformerIntrospection.ComponentInfo.ACT_IXPrimary1.Unit;
            }
        }

        // n secondary
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: Z.tr("N-Sec");
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(transformerModule.ACT_INSecondary1)
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                text: transformerIntrospection.ComponentInfo.ACT_INSecondary1.Unit;
            }
        }

        //transformer secondary
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: Z.tr("X-Sec");
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(transformerModule.ACT_IXSecondary1)
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                text: transformerIntrospection.ComponentInfo.ACT_IXSecondary1.Unit;
            }
        }

        // Transformer Ratio
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: Z.tr("X-Ratio")
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(transformerModule.ACT_Ratio1)
            }
            GridRect {
                width: root.width*0.2
                height: root.rowHeight
            }
        }

        // Transformer Error
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: "X-ε"
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(transformerModule.ACT_Error1)
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                text: root.transformerIntrospection.ComponentInfo.ACT_Error1.Unit;
            }
        }

        // Transformer angle in degree
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: "X-δ"
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(transformerModule.ACT_Angle1)
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                text: transformerIntrospection.ComponentInfo.ACT_Angle1.Unit;
            }
        }

        // Transformer angle in centirad
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: "X-δ"
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(100 * transformerModule.ACT_Angle1 * Math.PI/180)
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                text: Z.tr("crad");
            }
        }

        // Transformer angle in arcminutes
        Row {
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                color: GC.tableShadeColor
                text: "X-δ"
                font.bold: true
            }
            GridItem {
                width: root.width*0.6
                height: root.rowHeight
                text: FT.formatNumber(transformerModule.ACT_Angle1*60)
            }
            GridItem {
                width: root.width*0.2
                height: root.rowHeight
                text: Z.tr("arcmin");
            }
        }
    }

    SettingsControls.SettingsView {
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.rowHeight * model.count
        anchors.bottom: parent.bottom

        model: VisualItemModel {
            Item {
                width: root.width
                height: root.rowHeight

                VFLineEdit {
                    id: parPrimClampPrim
                    description.text: Z.tr("Mp-Prim:")
                    description.width: root.width/10;
                    height: root.rowHeight;
                    width: root.width/2 - 8;

                    entity: root.transformerModule
                    controlPropertyName: "PAR_PrimClampPrim"
                    unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

                    validator: ZDoubleValidator {
                        bottom: transformerIntrospection.ComponentInfo[parPrimClampPrim.controlPropertyName].Validation.Data[0];
                        top: transformerIntrospection.ComponentInfo[parPrimClampPrim.controlPropertyName].Validation.Data[1];
                        decimals: FT.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parPrimClampPrim.controlPropertyName].Validation.Data[2]);
                    }
                }
                VFLineEdit {
                    id: parPrimClampSec
                    anchors.right: parent.right
                    description.text: Z.tr("Mp-Sec:")
                    description.width: root.width/10;
                    height: root.rowHeight;
                    width: root.width/2 - 8;

                    entity: root.transformerModule
                    controlPropertyName: "PAR_PrimClampSec"
                    unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

                    validator: ZDoubleValidator {
                        bottom: transformerIntrospection.ComponentInfo[parPrimClampSec.controlPropertyName].Validation.Data[0];
                        top: transformerIntrospection.ComponentInfo[parPrimClampSec.controlPropertyName].Validation.Data[1];
                        decimals:  FT.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parPrimClampSec.controlPropertyName].Validation.Data[2]);
                    }
                }
            }
            Item {
                width: root.width
                height: root.rowHeight

                VFLineEdit {
                    id: parDutPrimary
                    description.text: Z.tr("X-Prim:")
                    description.width: root.width/10;
                    height: root.rowHeight;
                    width: root.width/2 - 8;

                    entity: root.transformerModule
                    controlPropertyName: "PAR_DutPrimary"
                    unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

                    validator: ZDoubleValidator {
                        bottom: transformerIntrospection.ComponentInfo[parDutPrimary.controlPropertyName].Validation.Data[0];
                        top: transformerIntrospection.ComponentInfo[parDutPrimary.controlPropertyName].Validation.Data[1];
                        decimals: FT.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parDutPrimary.controlPropertyName].Validation.Data[2]);
                    }
                }
                VFLineEdit {
                    id: parDutSecondary
                    anchors.right: parent.right
                    description.text: Z.tr("X-Sec:")
                    description.width: root.width/10;
                    height: root.rowHeight;
                    width: root.width/2 - 8;

                    entity: root.transformerModule
                    controlPropertyName: "PAR_DutSecondary"
                    unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

                    validator: ZDoubleValidator {
                        bottom: transformerIntrospection.ComponentInfo[parDutSecondary.controlPropertyName].Validation.Data[0];
                        top: transformerIntrospection.ComponentInfo[parDutSecondary.controlPropertyName].Validation.Data[1];
                        decimals: FT.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parDutSecondary.controlPropertyName].Validation.Data[2]);
                    }
                }
            }
            Item {
                width: root.width
                height: root.rowHeight

                VFLineEdit {
                    id: parSecClampPrim
                    description.text: Z.tr("Ms-Prim:")
                    description.width: root.width/10;
                    height: root.rowHeight;
                    width: root.width/2 - 8;

                    entity: root.transformerModule
                    controlPropertyName: "PAR_SecClampPrim"
                    unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

                    validator: ZDoubleValidator {
                        bottom: transformerIntrospection.ComponentInfo[parSecClampPrim.controlPropertyName].Validation.Data[0];
                        top: transformerIntrospection.ComponentInfo[parSecClampPrim.controlPropertyName].Validation.Data[1];
                        decimals:  FT.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parSecClampPrim.controlPropertyName].Validation.Data[2]);
                    }
                }
                VFLineEdit {
                    id: parSecClampSec
                    description.text: Z.tr("Ms-Sec:")
                    description.width: root.width/10;
                    height: root.rowHeight;
                    width: root.width/2 - 8;
                    anchors.right: parent.right

                    entity: root.transformerModule
                    controlPropertyName: "PAR_SecClampSec"
                    unit.text: transformerIntrospection.ComponentInfo[controlPropertyName].Unit

                    validator: ZDoubleValidator {
                        bottom: transformerIntrospection.ComponentInfo[parSecClampSec.controlPropertyName].Validation.Data[0];
                        top: transformerIntrospection.ComponentInfo[parSecClampSec.controlPropertyName].Validation.Data[1];
                        decimals: FT.ceilLog10Of1DividedByX(transformerIntrospection.ComponentInfo[parSecClampSec.controlPropertyName].Validation.Data[2]);
                    }
                }
            }
        }
    }
}
