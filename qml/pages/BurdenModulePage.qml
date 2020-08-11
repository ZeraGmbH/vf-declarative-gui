import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0 as VFControls
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/controls/settings" as SettingsControls

Item {
    id: root
    readonly property bool hasVoltageBurden: ModuleIntrospection.hasDependentEntities(["Burden1Module2"])
    readonly property bool hasCurrentBurden: ModuleIntrospection.hasDependentEntities(["Burden1Module1"])

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.topMargin: tabsBar.height
        currentIndex: tabsBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: tabsBar
        width: parent.width
        currentIndex: swipeView.currentIndex
        contentHeight: 32
    }

    // TabButtons
    Component {
        id: tabVoltage
        TabButton {
            text: Z.tr("Voltage Burden")
        }
    }
    Component {
        id: tabCurrent
        TabButton {
            text: Z.tr("Current Burden")
        }
    }

    // Page
    Component {
        id: pageComponent
        Item {
            id: page
            property bool isVoltagePage
            readonly property QtObject burdenModule: isVoltagePage ? VeinEntity.getEntity("Burden1Module2") : VeinEntity.getEntity("Burden1Module1")
            readonly property var burdenIntrospection: isVoltagePage ? ModuleIntrospection.burden2Introspection : ModuleIntrospection.burden1Introspection
            readonly property int rowCount: settingsView.model.count + burdenValueView.model.rowCount();
            readonly property int rowHeight: Math.floor(height/rowCount)
            readonly property int columnWidth: width/4.2 //0.7 + 3 + 0.5

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
                        CCMP.GridItem {
                            width: page.columnWidth*0.7
                            height: page.rowHeight
                            color: GC.tableShadeColor
                            text: Name!==undefined ? Name : ""
                            font.bold: true
                        }
                        CCMP.GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: L1!==undefined ? GC.formatNumber(L1) : ""
                            textColor: isVoltagePage ? GC.colorUL1 : GC.colorIL1
                            font.bold: index === 0
                        }
                        CCMP.GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: L2!==undefined ? GC.formatNumber(L2) : ""
                            textColor: isVoltagePage ? GC.colorUL2 : GC.colorIL2
                            font.bold: index === 0
                        }
                        CCMP.GridItem {
                            width: page.columnWidth
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: L3!==undefined ? GC.formatNumber(L3) : ""
                            textColor: isVoltagePage ? GC.colorUL3 : GC.colorIL3
                            font.bold: index === 0
                        }
                        CCMP.GridItem {
                            width: page.columnWidth/2
                            height: page.rowHeight
                            color: index === 0 ? GC.tableShadeColor : Material.backgroundColor
                            text: Unit ? Unit : ""
                            font.bold: index === 0
                        }
                    }
                }
            }
            SettingsControls.SettingsView {
                id: settingsView
                anchors.left: parent.left
                anchors.right: parent.right
                height: page.height*model.count/page.rowCount
                anchors.bottom: parent.bottom

                model: VisualItemModel {
                    VFControls.VFLineEdit {
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
                            decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalBurden.controlPropertyName].Validation.Data[2]);
                        }
                    }
                    VFControls.VFLineEdit {
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
                            decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parNominalRange.controlPropertyName].Validation.Data[2]);
                        }
                        ZVisualComboBox {
                            anchors.left: parent.right
                            anchors.leftMargin: 8
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: page.width*0.09;
                            contentRowHeight: height*1.2
                            contentFlow: GridView.FlowTopToBottom

                            model: Z.tr(burdenIntrospection.ComponentInfo.PAR_NominalRangeFactor.Validation.Data)
                            imageModel: ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_sqrt_3.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png"]
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
                    VFControls.VFLineEdit {
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
                            decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parWCrosssection.controlPropertyName].Validation.Data[2]);
                        }
                    }
                    VFControls.VFLineEdit {
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
                            decimals: GC.ceilLog10Of1DividedByX(burdenIntrospection.ComponentInfo[parWireLength.controlPropertyName].Validation.Data[2]);
                        }
                    }
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        if(hasVoltageBurden) {
            tabsBar.addItem(tabVoltage.createObject(tabsBar))
            swipeView.addItem(pageComponent.createObject(swipeView, {"isVoltagePage" : true}))
        }
        if(hasCurrentBurden) {
            tabsBar.addItem(tabCurrent.createObject(tabsBar))
            swipeView.addItem(pageComponent.createObject(swipeView, {"isVoltagePage" : false}))
        }
    }
}
