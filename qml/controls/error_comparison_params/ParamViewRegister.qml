import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraFa 1.0
import "qrc:/qml/controls/settings" as SettingsControls
import "qrc:/qml/controls" as CCMP

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

    // hack to determine if we are in ced-session and have to use POWER2Module1
    // to get/set measurement-modes
    readonly property bool usePower2: validatorRefInput.Data.includes("+P") && validatorRefInput.Data.includes("-P")

    readonly property real rowHeight: height/7
    readonly property real pointSize: rowHeight/2.5

    readonly property QtObject p1m1: !usePower2 ? VeinEntity.getEntity("POWER1Module1") : QtObject
    readonly property QtObject p1m2: !usePower2 ? VeinEntity.getEntity("POWER1Module2") : QtObject
    readonly property QtObject p1m3: !usePower2 ? VeinEntity.getEntity("POWER1Module3") : QtObject
    readonly property QtObject p2m1: usePower2 ? VeinEntity.getEntity("POWER2Module1") : QtObject

    readonly property real col1Width: 10/20
    readonly property real col2Width: 6/20
    readonly property real col3Width: 4/20

    SettingsControls.SettingsView {
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
                width: parent.width * col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Reference input:")
                font.pointSize: root.pointSize
            }
            VFComboBox {
                id: cbRefInput

                arrayMode: true

                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_RefInput"
                model: validatorRefInput.Data

                x: parent.width*col1Width
                width: parent.width*col2Width - GC.standardMarginWithMin

                anchors.top: parent.top
                anchors.bottom: parent.bottom

                currentIndex: 0
                contentRowWidth: width
                contentRowHeight: height*GC.standardComboContentScale
                contentFlow: GridView.FlowTopToBottom

            }
            VFComboBox {
                id: cbRefMeasMode
                arrayMode: true
                controlPropertyName: "PAR_MeasuringMode"
                model: {
                    if(usePower2) {
                        return ModuleIntrospection.p2m1Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
                    }
                    switch(cbRefInput.currentText) {
                    case "P":
                        return ModuleIntrospection.p1m1Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
                    case "Q":
                        return ModuleIntrospection.p1m2Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
                    case "S":
                        return ModuleIntrospection.p1m3Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
                    default:
                        console.assert("Unhandled condition")
                        return undefined;
                    }
                }

                entity: {
                    if(usePower2) {
                        return root.p2m1
                    }
                    switch(cbRefInput.currentText) {
                    case "P":
                        return root.p1m1
                    case "Q":
                        return root.p1m2
                    case "S":
                        return root.p1m3
                    default:
                        console.assert("Unhandled condition")
                        return undefined;
                    }
                }

                anchors.right: parent.right
                width: parent.width*col3Width

                anchors.top: parent.top
                anchors.bottom: parent.bottom

                contentRowHeight: height*GC.standardComboContentScale
                contentFlow: GridView.FlowTopToBottom
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

                currentIndex: 0
                contentRowHeight: height*GC.standardComboContentScale
                contentFlow: GridView.FlowTopToBottom
            }
        }
        Rectangle {
            enabled: logicalParent.canStartMeasurement && cbMode.currentIndex !== 0
            color: "transparent"
            border.color: Material.dividerColor
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
            color: "transparent"
            border.color: Material.dividerColor
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
                color: "transparent"
                border.color: Material.dividerColor
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
                fontSize: 16
                entity: logicalParent.errCalEntity

                controlPropertyName: "PAR_TXUNIT"
                model: validatorTxUnit.Data

                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                contentRowHeight: height*0.5*GC.standardComboContentScale
                contentFlow: GridView.FlowTopToBottom
                anchors.right: parent.right
                width: parent.width*col3Width
            }
        }
        Rectangle {
            color: "transparent"
            border.color: Material.dividerColor
            height: root.rowHeight
            width: root.width

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Upper error margin:")
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
            color: "transparent"
            border.color: Material.dividerColor
            height: root.rowHeight
            width: root.width

            Label {
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Lower error margin:")
                font.pointSize: root.pointSize
            }
            VFLineEdit {
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
