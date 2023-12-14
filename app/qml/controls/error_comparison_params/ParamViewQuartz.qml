import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import QmlHelpers 1.0
import ZeraLocale 1.0
import "../settings"

Item {
    id: root
    // properties to set by parent
    property QtObject logicalParent;

    property var validatorDutInput
    property var validatorFrequency
    property var validatorUpperLimit
    property var validatorLowerLimit

    readonly property real rowHeight: height > 0 ? height/7 : 10
    readonly property real pointSize: rowHeight/2.5

    readonly property real col1Width: 10/20
    readonly property real col2Width: 6/20
    readonly property real col3Width: 4/20

    SettingsView {
        anchors.fill: parent
        model: parameterModel
    }
    VisualItemModel {
        id: parameterModel

        Rectangle {
            color: "transparent"
            border.color: Material.dividerColor
            height: root.rowHeight
            width: root.width
            enabled: logicalParent.canStartMeasurement

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Device input:")
                font.pointSize: root.pointSize
            }
            VFComboBox {
                arrayMode: true

                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_DutInput"
                model: validatorDutInput.Data;

                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize
            }
        }
        Rectangle {
            color: "transparent"
            border.color: Material.dividerColor
            height: root.rowHeight
            width: root.width
            enabled: logicalParent.canStartMeasurement

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Frequency:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_MRate"
                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize

                validator: ZDoubleValidator {
                    bottom: validatorFrequency.Data[0]
                    top: validatorFrequency.Data[1]
                    decimals: FT.ceilLog10Of1DividedByX(validatorFrequency.Data[2])
                }
            }
            Label {
                textFormat: Text.PlainText
                anchors.right: parent.right
                width: parent.width*col3Width - GC.standardTextHorizMargin
                anchors.verticalCenter: parent.verticalCenter
                text: "Hz"
                font.pointSize: root.pointSize
            }
        }
        Rectangle {
            color: "transparent"
            border.color: Material.dividerColor
            height: root.rowHeight
            width: root.width
            enabled: logicalParent.canStartMeasurement && errCalEntity.PAR_Continuous !== 1
            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Count / Pause:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
                id: multiCount
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_MeasCount"
                pointSize: root.pointSize
                x: parent.width*col1Width
                width: parent.width*col2Width * 0.45 - GC.standardMarginWithMin
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                validator: IntValidator {
                    bottom: moduleIntrospection.ComponentInfo.PAR_MeasCount.Validation.Data[0]
                    top: moduleIntrospection.ComponentInfo.PAR_MeasCount.Validation.Data[1]
                }
            }
            Label {
                id: multiSeparator
                text: "/"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: multiCount.right
                width: parent.width*col2Width * (1 - 2 * 0.45) - GC.standardMarginWithMin
                font.pointSize: root.pointSize
                horizontalAlignment: Label.AlignHCenter
            }
            VFLineEdit {
                id: multiWait
                entity: logicalParent.errCalEntity
                enabled: logicalParent.errCalEntity.PAR_Continuous === 0 && !logicalParent.errCalEntity.PAR_DutInput.includes("HK")
                controlPropertyName: "PAR_MeasWait"
                pointSize: root.pointSize
                width: multiCount.width
                anchors.left: multiSeparator.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                validator: IntValidator {
                    bottom: moduleIntrospection.ComponentInfo.PAR_MeasWait.Validation.Data[0]
                    top: moduleIntrospection.ComponentInfo.PAR_MeasWait.Validation.Data[1]
                }
            }
            Label {
                enabled: multiWait.enabled
                anchors.right: parent.right
                width: parent.width*col3Width - GC.standardTextHorizMargin
                anchors.verticalCenter: parent.verticalCenter
                text: "s"
                font.pointSize: root.pointSize
            }
        }
        Rectangle {
            color: "transparent"
            border.color: Material.dividerColor
            height: root.rowHeight
            width: root.width
            enabled: logicalParent.canStartMeasurement

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
                text: logicalParent.errCalEntity.PAR_ResultUnit
                font.pointSize: root.pointSize
            }
        }
        Rectangle {
            color: "transparent"
            border.color: Material.dividerColor
            height: root.rowHeight
            width: root.width
            enabled: logicalParent.canStartMeasurement

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
                text: logicalParent.errCalEntity.PAR_ResultUnit
                font.pointSize: root.pointSize
            }
        }
    }
}
