import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ZeraTranslation 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import PowerModuleVeinGetter 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import FontAwesomeQml 1.0
import QmlHelpers 1.0
import ZeraLocale 1.0
import "../settings"
import "../error_comparison_common"

Item {
    id: root
    // properties to set by parent
    property QtObject logicalParent;
    property var validatorRefInput
    property var validatorDutInput
    property var validatorDutConstant
    property var validatorDutConstUnit
    // either energy or mrate
    property var validatorEnergy
    property var validatorMrate
    readonly property bool isMeterTest: validatorMrate !== undefined
    readonly property bool isEnergyComparison: validatorEnergy !== undefined

    property var validatorUpperLimit
    property var validatorLowerLimit

    // hack to determine if we are in ced-session and have to use POWER2Module1
    // to get/set measurement-modes
    readonly property bool usePower2: validatorRefInput.Data.includes("+P") && validatorRefInput.Data.includes("-P")

    readonly property int rowsDisplayed: {
        let baseRows = 6
        if(isEnergyComparison)
            baseRows++
        return baseRows
    }
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
                text: Z.tr("Reference input:")
                font.pointSize: root.pointSize
            }
            VFComboBox {
                id: cbRefInput
                // override
                function translateText(text) {
                    return Z.tr(text)
                }
                arrayMode: true
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_RefInput"
                model: validatorRefInput.Data

                x: parent.width*col1Width
                width: parent.width*col2Width - GC.standardMarginWithMin
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize
            }

            VFComboBox {
                arrayMode: true
                controlPropertyName: "PAR_MeasuringMode"
                // override
                function translateText(text){
                    return Z.tr(text)
                }
                model: {
                    if(usePower2)
                        return ModuleIntrospection.p2m1Introspection.ComponentInfo.PAR_MeasuringMode.Validation.Data;
                    let moduleNo = PwrModVeinGetter.getPowerModuleNoFromDisplayedName(cbRefInput.currentText)
                    return PwrModVeinGetter.getEntityJsonInfo(moduleNo).ComponentInfo.PAR_MeasuringMode.Validation.Data
                }
                entity: {
                    if(usePower2)
                        return root.p2m1
                    let moduleNo = PwrModVeinGetter.getPowerModuleNoFromDisplayedName(cbRefInput.currentText)
                    return PwrModVeinGetter.getPowerModuleEntity(moduleNo)
                }

                anchors.right: parent.right
                width: parent.width*col3Width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize
            }
        }
        Rectangle {
            color: "transparent"
            border.color: Material.dividerColor
            height: isEnergyComparison ? root.rowHeight : 0
            width: root.width
            enabled: logicalParent.canStartMeasurement
            visible: isEnergyComparison

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
                id: meterConstLabel
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: GC.standardTextHorizMargin
                width: parent.width*col1Width
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("Constant") + ":"
                font.pointSize: root.pointSize
            }

            Button{
                id: popButton
                text: FAQ.fa_cogs
                anchors.right: autoDutButton.left
                anchors.verticalCenter: meterConstLabel.verticalCenter
                anchors.rightMargin: parent.width/240
                font.pointSize: pointSize
                width: parent.width/12
                Material.foreground: {
                    if(logicalParent.errCalEntity["PAR_DutTypeMeasurePoint"] === "CsIsUs"){
                        return "white";
                    }else{
                        return Material.color(Material.Amber) // show settings are not default
                    }
                }
                onPressed: {
                    meterConstSettings.open()
                }
            }
            Button{
                id: autoDutButton
                text: FAQ.fa_hand_point_right
                font.pointSize: pointSize
                width: parent.width/12
                anchors.right: meterConstLabel.right
                anchors.verticalCenter: meterConstLabel.verticalCenter
                anchors.rightMargin: 10
                enabled: (VeinEntity.getEntity("SEC1Module1").ACT_Energy !== 0)
                onPressed: {
                    VeinEntity.getEntity("SEC1Module1").PAR_DutConstantAuto = 1
                    enabled: false
                }
            }

            MeterConstantSettings {
                 id: meterConstSettings
                 parent: Overlay.overlay
                 width: parent.width
                 height: parent.height
                 modal: false
                 focus: true
                 visible: false
                 closePolicy: Popup.NoAutoClose
            }

            VFLineEdit {
                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_DutConstant"

                x: parent.width*col1Width
                width: parent.width*col2Width-GC.standardMarginWithMin

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                pointSize: root.pointSize

                validator: ZDoubleValidator {
                    bottom: validatorDutConstant.Data[0];
                    top: validatorDutConstant.Data[1];
                    decimals: FT.ceilLog10Of1DividedByX(validatorDutConstant.Data[2]);
                }
            }

            VFComboBox {
                arrayMode: true

                entity: logicalParent.errCalEntity
                controlPropertyName: "PAR_DUTConstUnit"
                model: validatorDutConstUnit.Data;

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: parent.width*col3Width
                pointSize: root.pointSize
            }
        }
        Loader {
            active: isEnergyComparison
            sourceComponent: Rectangle {
                enabled: logicalParent.canStartMeasurement
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
                    text: Z.tr("Energy:")
                    font.pointSize: root.pointSize
                }

                VFLineEdit {
                    id: energyVal
                    property alias currentFactor: unitCombo.currentFactor
                    entity: logicalParent.errCalEntity
                    controlPropertyName: "PAR_Energy"

                    x: parent.width*col1Width
                    width: parent.width*col2Width-GC.standardMarginWithMin

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    pointSize: root.pointSize

                    // scale adjusted validator
                    // Note: attempts to add scale functionality to ZLineEdit/ZSpinBox failed due
                    // to QML validator specifics:
                    // validator is a reference to object created above. Whatever we do
                    // * create a copy validator
                    // * adjust bottom/top/decimals by js
                    // breaks property bindings
                    validator: ZDoubleValidator {
                        // Hmm - we need full reference for currentFactor here
                        bottom: validatorEnergy.Data[0] / energyVal.currentFactor;
                        top: validatorEnergy.Data[1] / energyVal.currentFactor;
                        decimals: FT.ceilLog10Of1DividedByX(validatorEnergy.Data[2] / energyVal.currentFactor)
                    }
                    // overrides for scale
                    function doApplyInput(newText) {
                        var flt = parseFloat(newText) * currentFactor
                        entity[controlPropertyName] = flt
                        // wait to be applied
                        return false
                    }
                    // scale adjusted copies from TextHelper
                    function discardInput() {
                        var fltVal = parseFloat(text) / currentFactor
                        // * we cannot use validator.decimals - it is updated too late
                        // * multiple back and forth conversion to round value to digit (otherwise field remains red)
                        var strVal = String(Number(fltVal.toFixed(FT.ceilLog10Of1DividedByX(validatorEnergy.Data[2] / currentFactor))))
                        textField.text = strVal.replace(ZLocale.decimalPoint === "," ? "." : ",", ZLocale.decimalPoint)
                    }
                    function hasAlteredValue() {
                        var expVal = Math.pow(10, FT.ceilLog10Of1DividedByX(validatorEnergy.Data[2] / currentFactor))
                        var fieldVal = parseFloat(ZLocale.strToCLocale(textField.text, isNumeric, isDouble)) * expVal
                        var textVal = parseFloat(text) * expVal / currentFactor
                        return Math.abs(fieldVal-textVal) > 0.1
                    }
                    // scale change signal handler
                    onCurrentFactorChanged: {
                        discardInput()
                    }
                }
                ZUnitComboBox {
                    id: unitCombo
                    currentIndex: GC.energyScaleSelection
                    // entity base unit is kWh (maybe we add some magic later - for now use harcoding)
                    arrEntries: {
                        switch(cbRefInput.currentText) {
                        case "P":
                        case "+P":
                        case "-P":
                        case "P AC":
                        case "P DC":
                        case "P 1":
                        case "P 2":
                        case "P 3":
                        case "P AUX":
                            return [["Wh","kWh","MWh"],[1e-3,1e0,1e3]]
                        case "Q":
                            return [["VArh","kVArh","MVArh"],[1e-3,1e0,1e3]]
                        case "S":
                            return [["VAh","kVAh","MVAh"],[1e-3,1e0,1e3]]
                        }
                    }
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: parent.width*col3Width
                    pointSize: root.pointSize

                    onCurrentFactorChanged: {
                        // Hmm unitCombo does not fire onCurrentIndexChanged so use onCurrentFactorChanged...
                        GC.setEnergyScaleSelection(targetIndex)
                    }
                }
            }
        }
        Loader {
            active: isMeterTest
            sourceComponent: Rectangle {
                enabled: logicalParent.canStartMeasurement
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
                    text: Z.tr("MRate:")
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
                        bottom: validatorMrate.Data[0];
                        top: validatorMrate.Data[1];
                        decimals: FT.ceilLog10Of1DividedByX(validatorMrate.Data[2]);
                    }
                }
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
            enabled: logicalParent.canStartMeasurement || errCalEntity.PAR_Continuous !== 0

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
            enabled: logicalParent.canStartMeasurement || errCalEntity.PAR_Continuous !== 0

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
