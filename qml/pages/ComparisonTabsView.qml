import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import FunctionTools 1.0

BaseTabPage {
    id: root
    readonly property bool hasSEC1: ModuleIntrospection.hasDependentEntities(["SEC1Module1"])
    readonly property bool hasSEC1_2: ModuleIntrospection.hasDependentEntities(["SEC1Module2"])
    readonly property bool hasSEM1: ModuleIntrospection.hasDependentEntities(["SEM1Module1"])
    readonly property bool hasSPM1: ModuleIntrospection.hasDependentEntities(["SPM1Module1"])

    // TabButtons
    Component {
        id: tabPulse
        TabButton {
            text: Z.tr("Meter test")
        }
    }
    Component {
        id: tabPulseEnergy
        TabButton {
            text: Z.tr("Energy comparison")
        }
    }
    Component {
        id: tabEnergy
        TabButton {
            text: Z.tr("Energy register")
        }
    }
    Component {
        id: tabPower
        TabButton {
            text: Z.tr("Power register")
        }
    }

    // Pages
    Component {
        id: pagePulse
        ErrorCalculatorModulePage {
            errCalEntity: VeinEntity.getEntity("SEC1Module1")
            moduleIntrospection: ModuleIntrospection.sec1m1Introspection
            validatorMrate: moduleIntrospection.ComponentInfo.PAR_MRate.Validation
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_METER_TEST
                }
            }
        }
    }
    Component {
        id: pagePulseEnergy
        ErrorCalculatorModulePage {
            errCalEntity: VeinEntity.getEntity("SEC1Module2")
            moduleIntrospection: ModuleIntrospection.sec1m2Introspection
            validatorEnergy: moduleIntrospection.ComponentInfo.PAR_Energy.Validation
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ENERGY_COMPARISON
                }
            }
        }
    }
    Component {
        id: pageEnergy
        ErrorRegisterModulePage {
            errCalEntity: VeinEntity.getEntity("SEM1Module1")
            moduleIntrospection: ModuleIntrospection.sem1Introspection
            actualValue: FT.formatNumber(errCalEntity.ACT_Energy) + " " + moduleIntrospection.ComponentInfo.ACT_Energy.Unit
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ENERGY_REGISTER
                }
            }
        }
    }
    Component {
        id: pagePower
        ErrorRegisterModulePage {
            errCalEntity: VeinEntity.getEntity("SPM1Module1")
            moduleIntrospection: ModuleIntrospection.spm1Introspection
            actualValue: FT.formatNumber(errCalEntity.ACT_Power) + " " + moduleIntrospection.ComponentInfo.ACT_Power.Unit
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_POWER_REGISTER
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        if(hasSEC1) {
            tabBar.addItem(tabPulse.createObject(tabBar))
            swipeView.addItem(pagePulse.createObject(swipeView))
        }
        if(hasSEC1_2) {
            tabBar.addItem(tabPulseEnergy.createObject(tabBar))
            swipeView.addItem(pagePulseEnergy.createObject(swipeView))
        }
        if(hasSEM1) {
            tabBar.addItem(tabEnergy.createObject(tabBar))
            swipeView.addItem(pageEnergy.createObject(swipeView))
        }
        if(hasSPM1) {
            tabBar.addItem(tabPower.createObject(tabBar))
            swipeView.addItem(pagePower.createObject(swipeView))
        }
        finishInit()
    }
}
