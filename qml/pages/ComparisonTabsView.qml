import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0

Item {
    id: root
    readonly property bool hasSEC1: ModuleIntrospection.hasDependentEntities(["SEC1Module1"])
    readonly property bool hasSEC1_2: ModuleIntrospection.hasDependentEntities(["SEC1Module2"])
    readonly property bool hasSEM1: ModuleIntrospection.hasDependentEntities(["SEM1Module1"])
    readonly property bool hasSPM1: ModuleIntrospection.hasDependentEntities(["SPM1Module1"])

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.topMargin: comparisonTabsBar.height
        currentIndex: comparisonTabsBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: comparisonTabsBar
        width: parent.width
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: GC.setLastTabSelected(currentIndex)
        contentHeight: 32
    }

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
            actualValue: GC.formatNumber(errCalEntity.ACT_Energy) + " " + moduleIntrospection.ComponentInfo.ACT_Energy.Unit
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
            actualValue: GC.formatNumber(errCalEntity.ACT_Power) + " " + moduleIntrospection.ComponentInfo.ACT_Power.Unit
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_POWER_REGISTER
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        let lastTabSelected = GC.lastTabSelected // keep - it is overwritten on page setup
        if(hasSEC1) {
            comparisonTabsBar.addItem(tabPulse.createObject(comparisonTabsBar))
            swipeView.addItem(pagePulse.createObject(swipeView))
        }
        if(hasSEC1_2) {
            comparisonTabsBar.addItem(tabPulseEnergy.createObject(comparisonTabsBar))
            swipeView.addItem(pagePulseEnergy.createObject(swipeView))
        }
        if(hasSEM1) {
            comparisonTabsBar.addItem(tabEnergy.createObject(comparisonTabsBar))
            swipeView.addItem(pageEnergy.createObject(swipeView))
        }
        if(hasSPM1) {
            comparisonTabsBar.addItem(tabPower.createObject(comparisonTabsBar))
            swipeView.addItem(pagePower.createObject(swipeView))
        }

        swipeView.currentIndex = lastTabSelected
        swipeView.currentIndex = Qt.binding(() => comparisonTabsBar.currentIndex);
    }
}
