import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import QtQml.Models 2.14
import VeinEntity 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import TableEventDistributor 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0
import ZeraThemeConfig 1.0
import "../controls"
import "../controls/settings"

BaseTabPage {
    id: root
    readonly property bool hasVoltageBurden: VeinEntity.hasEntity("Burden1Module2")
    readonly property bool hasCurrentBurden: VeinEntity.hasEntity("Burden1Module1")

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
                            color: ZTC.tableHeaderColor
                            text: Name!==undefined ? Name : ""
                            font.bold: true
                        }
                        GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
                            text: valueText(L1, Name)
                            textColor: isVoltagePage ? CS.colorUL1 : CS.colorIL1
                            font.bold: index === 0
                        }
                        GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
                            text: valueText(L2, Name)
                            textColor: isVoltagePage ? CS.colorUL2 : CS.colorIL2
                            font.bold: index === 0
                        }
                        GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
                            text: valueText(L3, Name)
                            textColor: isVoltagePage ? CS.colorUL3 : CS.colorIL3
                            font.bold: index === 0
                        }
                        GridItem {
                            width: page.columnWidth/2
                            height: page.rowHeight
                            color: index === 0 ? ZTC.tableHeaderColor : Material.backgroundColor
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
                anchors.rightMargin: GC.standardTextHorizMargin
                anchors.leftMargin: GC.standardTextHorizMargin
                height: page.height*model.count/page.rowCount
                anchors.bottom: parent.bottom
                readonly property real editWidth: page.width * 0.88
                readonly property real descWidth: page.width * 0.5
                readonly property real unitWidth: page.width * 0.08

                model: ObjectModel {
                    VFLineEdit {
                        id: parNominalBurden
                        height: page.rowHeight;
                        width: settingsView.editWidth

                        description.text: Z.tr("Nominal burden:")
                        description.width: settingsView.descWidth
                        entity: page.burdenModule
                        controlPropertyName: "PAR_NominalBurden"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
                        unit.width: settingsView.unitWidth

                        validator: ZDoubleValidator {
                            bottom: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[0];
                            top: burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[2]);
                        }
                    }
                    VFLineEdit {
                        id: parNominalRange
                        height: page.rowHeight;
                        width: settingsView.editWidth

                        description.text: Z.tr("Nominal range:")
                        description.width: settingsView.descWidth
                        entity: page.burdenModule
                        controlPropertyName: "PAR_NominalRange"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit + "   *"
                        unit.width: settingsView.unitWidth

                        validator: ZDoubleValidator {
                            bottom: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[0];
                            top: burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[2]);
                        }

                        ZComboBox {
                            anchors.left: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: page.width * 0.09
                            visible: page.isVoltagePage
                            arrayMode: true
                            model: ["1", "1/√3", "1/3"]
                            readonly property var veinValueModel: ["1", "1/sqrt(3)", "1/3"]
                            function getVeinVal() {
                                let index = model.indexOf(selectedText)
                                return veinValueModel[index]
                            }
                            currentIndex: {
                                let veinVal = burdenModule.PAR_NominalRangeFactor
                                let val = veinValueModel.indexOf(veinVal)
                                return val
                            }
                            onSelectedTextChanged: {
                                let veinVal = getVeinVal()
                                if(burdenModule.PAR_NominalRangeFactor !== veinVal)
                                    burdenModule.PAR_NominalRangeFactor = veinVal
                            }
                        }
                    }
                    VFLineEdit {
                        id: parWCrosssection
                        height: page.rowHeight;
                        width: settingsView.editWidth

                        description.text: Z.tr("Wire crosssection:")
                        description.width: settingsView.descWidth
                        entity: page.burdenModule
                        controlPropertyName: "PAR_WCrosssection"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
                        unit.width: settingsView.unitWidth

                        validator: ZDoubleValidator {
                            bottom: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[0];
                            top: burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[2]);
                        }
                    }
                    VFLineEdit {
                        id: parWireLength
                        height: page.rowHeight;
                        width: settingsView.editWidth

                        description.text: Z.tr("Wire length:")
                        description.width: settingsView.descWidth
                        entity: page.burdenModule
                        controlPropertyName: "PAR_WireLength"
                        unit.text: burdenIntrospection.ComponentInfo[controlPropertyName].Unit;
                        unit.width: settingsView.unitWidth

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
