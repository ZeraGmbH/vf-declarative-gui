import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import "../controls"
import "../controls/settings"

BaseTabPage {
    id: root
    readonly property bool hasVoltageBurden: ModuleIntrospection.hasDependentEntities(["Burden1Module2"])
    readonly property bool hasCurrentBurden: ModuleIntrospection.hasDependentEntities(["Burden1Module1"])

    // TabButtons
    Component {
        id: tabVoltage
        TabButton {
            text: Z.tr("Voltage Burden")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    Component {
        id: tabCurrent
        TabButton {
            text: Z.tr("Current Burden")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }

    // Page
    Component {
        id: pageComponent
        Item {
            id: page
            property bool isVoltagePage
            readonly property QtObject burdenModule: isVoltagePage ? VeinEntity.getEntity("Burden1Module2") : VeinEntity.getEntity("Burden1Module1")
            readonly property var burdenIntrospection: isVoltagePage ? ModuleIntrospection.burdenUIntrospection : ModuleIntrospection.burdenIIntrospection
            readonly property int rowCount: settingsView.model.count + burdenValueView.model.rowCount();
            readonly property int rowHeight: Math.floor(height/rowCount)
            readonly property int columnWidth: width/4.2 //0.7 + 3 + 0.5
            onIsVoltagePageChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = isVoltagePage ? GC.guiContextEnum.GUI_VOLTAGE_BURDEN : GC.guiContextEnum.GUI_CURRENT_BURDEN
                }
            }
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = isVoltagePage ? GC.guiContextEnum.GUI_VOLTAGE_BURDEN : GC.guiContextEnum.GUI_CURRENT_BURDEN
                }
            }

            ListView {
                id: burdenValueView
                height: page.rowHeight*model.rowCount()
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                model: page.isVoltagePage ? ZGL.BurdenModelU : ZGL.BurdenModelI
                boundsBehavior: Flickable.StopAtBounds
                delegate: Component {
                    Row {
                        width: page.width
                        height: page.rowHeight
                        function valueText(value, name) {
                            if(name === "Sn")
                                return FT.formatNumber(value)
                            return FT.formatNumberForScaledValues(value)
                        }

                        GridItem {
                            width: page.columnWidth*0.7
                            height: page.rowHeight
                            color: GC.tableShadeColor
                            text: Name!==undefined ? Name : ""
                            font.bold: true
                        }
                        GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: valueText(L1, Name)
                            textColor: isVoltagePage ? GC.colorUL1 : GC.colorIL1
                            font.bold: index === 0
                        }
                        GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: valueText(L2, Name)
                            textColor: isVoltagePage ? GC.colorUL2 : GC.colorIL2
                            font.bold: index === 0
                        }
                        GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: valueText(L3, Name)
                            textColor: isVoltagePage ? GC.colorUL3 : GC.colorIL3
                            font.bold: index === 0
                        }
                        GridItem {
                            width: page.columnWidth/2
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: Unit ? Unit : ""
                            font.bold: index === 0
                        }
                    }
                }
            }
            SettingsView {
                id: settingsView
                anchors.left: parent.left
                anchors.right: parent.right
                height: page.height*model.count/page.rowCount
                anchors.bottom: parent.bottom

                model: VisualItemModel {
                    VFLineEdit {
                        id: parNominalBurden
                        height: page.rowHeight;
                        width: page.width*0.9;

                        description.text: Z.tr("Nominal burden:")
                        description.width: page.width/4
                        entity: page.burdenModule
                        controlPropertyName: "PAR_NominalBurden"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
                        unit.width: page.rowHeight*1.5

                        validator: ZDoubleValidator {
                            bottom: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[0];
                            top: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[2]);
                        }
                    }
                    VFLineEdit {
                        id: parNominalRange
                        height: page.rowHeight;
                        width: page.width*0.9;

                        description.text: Z.tr("Nominal range:")
                        description.width: page.width/4
                        entity: page.burdenModule
                        controlPropertyName: "PAR_NominalRange"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
                        unit.width: page.rowHeight*1.5

                        validator: ZDoubleValidator {
                            bottom: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[0];
                            top: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[2]);
                        }


                        // The current Burden does not need a Rangefactor
                        // Therefore it is always 1 and the box is invisible
                        ZVisualComboBox {
                            anchors.left: parent.right
                            anchors.leftMargin: 8
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: page.width*0.09;
                            visible: page.isVoltagePage
                            model: {
                                if(page.isVoltagePage)
                                    return ["1" , "1/sqrt(3)", "1/3"]
                                else
                                    return ["1"]
                            }
                            imageModel: {
                                if(page.isVoltagePage){
                                   return ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png", "qrc:/data/staticdata/resources/x_1_over_3.png"]
                                }else{
                                   return ["qrc:/data/staticdata/resources/x_1.png"]
                                }
                               }
                            property int intermediate: model.indexOf(burdenModule.PAR_NominalRangeFactor);
                            automaticIndexChange: true
                            onIntermediateChanged: {
                                if(currentIndex !== intermediate) {
                                    currentIndex = intermediate
                                }
                            }

                            onSelectedTextChanged: {
                                if(burdenModule.PAR_NominalRangeFactor !== selectedText) {
                                    burdenModule.PAR_NominalRangeFactor = selectedText
                                }
                            }
                        }
                    }
                    VFLineEdit {
                        id: parWCrosssection
                        height: page.rowHeight;
                        width: page.width*0.9;

                        description.text: Z.tr("Wire crosssection:")
                        description.width: page.width/4
                        entity: page.burdenModule
                        controlPropertyName: "PAR_WCrosssection"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
                        unit.width: page.rowHeight*1.5

                        validator: ZDoubleValidator {
                            bottom: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[0];
                            top: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[2]);
                        }
                    }
                    VFLineEdit {
                        id: parWireLength
                        height: page.rowHeight;
                        width: page.width*0.9;

                        description.text: Z.tr("Wire length:")
                        description.width: page.width/4
                        entity: page.burdenModule
                        controlPropertyName: "PAR_WireLength"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
                        unit.width: page.rowHeight*1.5

                        validator: ZDoubleValidator {
                            bottom: burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[0];
                            top: burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[2]);
                        }
                    }
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        if(hasVoltageBurden) {
            tabBar.addItem(tabVoltage.createObject(tabBar))
            swipeView.addItem(pageComponent.createObject(swipeView, {"isVoltagePage" : true}))
        }
        if(hasCurrentBurden) {
            tabBar.addItem(tabCurrent.createObject(tabBar))
            swipeView.addItem(pageComponent.createObject(swipeView, {"isVoltagePage" : false}))
        }
        finishInit()
    }
}
