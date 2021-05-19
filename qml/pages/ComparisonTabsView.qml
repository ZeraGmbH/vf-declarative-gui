import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import "../controls"

BaseTabPage {
    id: root
    readonly property bool hasSEC1: ModuleIntrospection.hasDependentEntities(["SEC1Module1"])
    readonly property bool hasSEC1_2: ModuleIntrospection.hasDependentEntities(["SEC1Module2"])
    readonly property bool hasSEM1: ModuleIntrospection.hasDependentEntities(["SEM1Module1"])
    readonly property bool hasSPM1: ModuleIntrospection.hasDependentEntities(["SPM1Module1"])

    readonly property var sec1mod1Entity: hasSEC1 ? VeinEntity.getEntity("SEC1Module1") : null
    readonly property var sec1mod2Entity: hasSEC1_2 ? VeinEntity.getEntity("SEC1Module2") : null
    readonly property var sem1mod1Entity: hasSEM1 ? VeinEntity.getEntity("SEM1Module1") : null
    readonly property var spm1mod1Entity: hasSPM1 ? VeinEntity.getEntity("SPM1Module1") : null

    readonly property int aborted: (1<<3)

    function comparisonProgress(entity, show) {
        let ret = ""
        if(show) {
            let progress = parseInt(entity.ACT_Progress)
            let measCount = entity.PAR_MeasCount
            let continuous = entity.PAR_Continuous === 1
            if(measCount > 1 || continuous) {
                let measNum = entity.ACT_MeasNum + 1
                if(continuous) {
                    ret = ` ${progress}% (${measNum})`
                }
                else {
                    ret = ` ${progress}% (${measNum}/${measCount})`
                }
            }
            else {
                ret = ` ${progress}%`
            }
        }
        return ret
    }
    function registerProgress(entity, show) {
        let ret = ""
        if(show) {
            let progress = parseInt(entity.ACT_Time / entity.PAR_MeasTime * 100)
            ret = ` ${progress}%`
        }
        return ret
    }
    function comparisonPass(entity) {
        let pass = false
        let jsonResults = JSON.parse(entity.ACT_MulResult)
        if(jsonResults.values.length === 1) {
            pass = entity.ACT_Rating !== 0
        }
        else {
            pass = jsonResults.countPass === jsonResults.values.length
        }
        return pass
    }
    function registerPass(entity, running) {
        let pass = false
        let abortFlag = (1<<3)
        let aborted = entity.ACT_Status & root.aborted
        pass = entity.ACT_Rating !== 0 || running || aborted
        return pass
    }

    // TabButtons
    Component {
        id: tabPulse
        TabButton {
            id: tabButtonPulse
            readonly property var entity: sec1mod1Entity
            readonly property bool running: entity.PAR_StartStop === 1
            text: Z.tr("Meter test") + comparisonProgress(entity, running && !checked)
            Material.foreground: comparisonPass(entity) ? Material.White : Material.Red
            ActivityAnimation {
                targetItem: tabButtonPulse
                running: tabButtonPulse.running && !tabButtonPulse.checked
            }
        }
    }
    Component {
        id: tabPulseEnergy
        TabButton {
            id: tabButtonPulseEnergy
            readonly property var entity: sec1mod2Entity
            readonly property bool running: entity.PAR_StartStop === 1
            text: Z.tr("Energy comparison") + comparisonProgress(entity, running && !checked)
            Material.foreground: comparisonPass(entity) ? Material.White : Material.Red
            ActivityAnimation {
                targetItem: tabButtonPulseEnergy
                running: tabButtonPulseEnergy.running && !tabButtonPulseEnergy.checked
            }
        }
    }
    Component {
        id: tabEnergy
        TabButton {
            id: tabButtonEnergy
            readonly property var entity: sem1mod1Entity
            readonly property bool running: entity.PAR_StartStop === 1
            text: Z.tr("Energy register") + registerProgress(entity, running && !checked)
            Material.foreground: registerPass(entity, running) ? Material.White : Material.Red
            ActivityAnimation {
                targetItem: tabButtonEnergy
                running: tabButtonEnergy.running && !tabButtonEnergy.checked
            }
        }
    }
    Component {
        id: tabPower
        TabButton {
            id: tabButtonPower
            readonly property var entity: spm1mod1Entity
            readonly property bool running: entity.PAR_StartStop === 1
            text: Z.tr("Power register") + registerProgress(entity, running && !checked)
            Material.foreground: registerPass(entity, running) ? Material.White : Material.Red
            ActivityAnimation {
                targetItem: tabButtonPower
                running: tabButtonPower.running && !tabButtonPower.checked
            }
        }
    }

    // Pages
    Component {
        id: pagePulse
        ErrorCalculatorModulePage {
            errCalEntity: sec1mod1Entity
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
            errCalEntity: sec1mod2Entity
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
            errCalEntity: sem1mod1Entity
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
            errCalEntity: spm1mod1Entity
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
