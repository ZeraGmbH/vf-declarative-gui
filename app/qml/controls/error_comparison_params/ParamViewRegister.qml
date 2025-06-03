import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.14
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import PowerModuleVeinGetter 1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0
import "../settings"
import "../error_comparison_common"

Item {
    id: root
    // properties to set by parent
    property QtObject logicalParent;
    property var validatorRefInput
    property var validatorMeasTime
    property var validatorT0Input
    property var validatorT1Input
    property var validatorTxUnit
    property var validatorUpperLimit
    property var validatorLowerLimit
    readonly property var measModeModel: {
        if(usePower2)
            return ModuleIntrospection.p2m1Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data
        let moduleNo = PwrModVeinGetter.getPowerModuleNoFromDisplayedName(logicalParent.errCalEntity["PAR_RefInput"])
        return PwrModVeinGetter.getEntityJsonInfo(moduleNo).ComponentInfo.PAR_MeasuringMode.Validation.Data
    }
    readonly property bool canChangeRefInputOrMMode: validatorRefInput.Data.length > 1 || measModeModel.length > 1
    readonly property int rowsDisplayed: {
        let baseRows = 6
        if(canChangeRefInputOrMMode)
            baseRows++
        return baseRows
    }

    // hack to determine if we are in ced-session and have to use POWER2Module1
    // to get/set measurement-modes
    readonly property bool usePower2: validatorRefInput.Data.includes("+P") && validatorRefInput.Data.includes("-P")

    readonly property real rowHeight: height > 0 ? height/rowsDisplayed : 10
    readonly property real pointSize: rowHeight/2.5

    readonly property QtObject p2m1: usePower2 ? VeinEntity.getEntity("POWER2Module1") : QtObject

    readonly property real col1Width: 10/20
    readonly property real col2Width: 6/20
    readonly property real col3Width: 4/20

    SettingsView {
        anchors.fill: parent
        model: parameterModel
    }
    ObjectModel {
        id: parameterModel

        ParamLineRefInputAndMMode {
            active: canChangeRefInputOrMMode
        }
        Rectangle {
            color: Material.backgroundColor
            border.color: GC.dividerColor
            height: root.rowHeight
            width: root.width
            enabled: logicalParent.canStartMeasurement
            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Mode:")
                font.pointSize: root.pointSize
            }
            VFComboBox {
                id: cbMode
                arrayMode: true

                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_Targeted"
                entityIsIndex: true
                model: [Z.tr("Start/Stop"),Z.tr("Duration")]

                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize
            }
        }
        Rectangle {
            enabled: logicalParent.canStartMeasurement && cbMode.currentIndex !== 0
            color: Material.backgroundColor
            border.color: GC.dividerColor
            height: root.rowHeight
            width: root.width

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Duration:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_MeasTime"

                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize

                validator: ZDoubleValidator {
                    bottom: validatorMeasTime.Data[0];
                    top: validatorMeasTime.Data[1];
                    decimals: FT.ceilLog10Of1DividedByX(validatorMeasTime.Data[2]);
                }
            }
            Label {
                textFormat: Text.PlainText
                anchors.right: parent.right
                width: parent.width * col3Width - GC.standardTextHorizMargin
                anchors.verticalCenter: parent.verticalCenter
                text: "s"
                font.pointSize: root.pointSize
            }
        }
        Rectangle {
            color: Material.backgroundColor
            border.color: GC.dividerColor
            height: root.rowHeight * 2
            width: root.width
            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -parent.height * 0.25
                text: Z.tr("Start value:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_T0Input"

                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.top: parent.top
                height: parent.height * 0.5
                pointSize: root.pointSize

                validator: ZDoubleValidator {
                    bottom: validatorT0Input.Data[0];
                    top: validatorT0Input.Data[1];
                    decimals: FT.ceilLog10Of1DividedByX(validatorT0Input.Data[2]);
                }

            }
            // This is a line
            Rectangle {
                color: Material.backgroundColor
                border.color: GC.dividerColor
                height: 1
                width: parent.width*(col1Width+col2Width)
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height * 0.25
                text: Z.tr("End value:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_T1input"

                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.bottom: parent.bottom
                height: parent.height * 0.5
                pointSize: root.pointSize

                validator: ZDoubleValidator {
                    bottom: validatorT1Input.Data[0];
                    top: validatorT1Input.Data[1];
                    decimals: FT.ceilLog10Of1DividedByX(validatorT1Input.Data[2]);
                }
            }
            VFComboBox {
                arrayMode: true
                entity: logicalParent.errCalEntity

                controlPropertyName: "PAR_TXUNIT"
                model: validatorTxUnit.Data

                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: parent.width*col3Width
                pointSize: root.pointSize
            }
        }
        Rectangle {
            color: Material.backgroundColor
            border.color: GC.dividerColor
            height: root.rowHeight
            width: root.width

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Upper error limit:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_Uplimit"
                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize

                validator: ZDoubleValidator {
                    bottom: validatorUpperLimit.Data[0];
                    top: validatorUpperLimit.Data[1];
                    decimals: Math.min(FT.ceilLog10Of1DividedByX(validatorUpperLimit.Data[2]), GC.decimalPlaces);
                }
                function doApplyInput(newText) {
                    let value = parseInt(newText, 10)
                    entity[controlPropertyName] = value
                    if(value > 0)
                        lowLimit.entity[lowLimit.controlPropertyName] = -value
                    return false
                }
            }
            Label {
                textFormat: Text.PlainText
                anchors.right: parent.right
                width: parent.width*col3Width - GC.standardTextHorizMargin
                anchors.verticalCenter: parent.verticalCenter
                text: "%"
                font.pointSize: root.pointSize
            }
        }
        Rectangle {
            color: Material.backgroundColor
            border.color: GC.dividerColor
            height: root.rowHeight
            width: root.width

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Lower error limit:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
                id: lowLimit
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_Lolimit"
                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize

                validator: ZDoubleValidator {
                    bottom: validatorLowerLimit.Data[0];
                    top: validatorLowerLimit.Data[1];
                    decimals: Math.min(FT.ceilLog10Of1DividedByX(validatorLowerLimit.Data[2]), GC.decimalPlaces);
                }
            }
            Label {
                textFormat: Text.PlainText
                anchors.right: parent.right
                width: parent.width*col3Width - GC.standardTextHorizMargin
                anchors.verticalCenter: parent.verticalCenter
                text: "%"
                font.pointSize: root.pointSize
            }
        }
    }
}
