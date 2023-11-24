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
import "../helpers"

BaseTabPage {
    id: root

    EntityErrorMeasHelper {
        id: errMeasHelper
    }

    // TabButtons
    Component {
        id: tabPulse
        TabButton {
            id: tabButtonPulse
            font.pointSize: tabPointSize
            height: tabHeight

            readonly property var entity: errMeasHelper.sec1mod1Entity
            contentItem: Label {
                text: Z.tr("Meter test") + errMeasHelper.comparisonProgress(entity, errMeasHelper.sec1mod1Running && !checked)
                font.capitalization: Font.AllUppercase
                font.pointSize: tabPointSize
                height: tabHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Material.foreground: errMeasHelper.comparisonPass(entity) ? Material.White : Material.Red
            }
            AnimationActivity {
                targetItem: tabButtonPulse
                running: errMeasHelper.sec1mod1Running
            }
        }
    }
    Component {
        id: tabPulseEnergy
        TabButton {
            id: tabButtonPulseEnergy
            font.pointSize: tabPointSize
            height: tabHeight

            readonly property var entity: errMeasHelper.sec1mod2Entity
            contentItem: Label {
                text: Z.tr("Energy comparison") + errMeasHelper.comparisonProgress(entity, errMeasHelper.sec1mod2Running && !checked)
                font.capitalization: Font.AllUppercase
                font.pointSize: tabPointSize
                height: tabHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Material.foreground: errMeasHelper.comparisonPass(entity) ? Material.White : Material.Red
            }
            AnimationActivity {
                targetItem: tabButtonPulseEnergy
                running: errMeasHelper.sec1mod2Running
            }
        }
    }
    Component {
        id: tabEnergy
        TabButton {
            id: tabButtonEnergy
            font.pointSize: tabPointSize
            height: tabHeight

            readonly property var entity: errMeasHelper.sem1mod1Entity
            contentItem: Label {
                text: Z.tr("Energy register") + errMeasHelper.registerProgress(entity, errMeasHelper.sem1mod1Running && !checked)
                font.capitalization: Font.AllUppercase
                font.pointSize: tabPointSize
                height: tabHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Material.foreground: errMeasHelper.registerPass(entity, errMeasHelper.sem1mod1Running) ? Material.White : Material.Red
            }
            AnimationActivity {
                targetItem: tabButtonEnergy
                running: errMeasHelper.sem1mod1Running
            }
        }
    }
    Component {
        id: tabPower
        TabButton {
            id: tabButtonPower
            font.pointSize: tabPointSize
            height: tabHeight

            readonly property var entity: errMeasHelper.spm1mod1Entity
            contentItem: Label {
                text: Z.tr("Power register") + errMeasHelper.registerProgress(entity, errMeasHelper.spm1mod1Running && !checked)
                font.capitalization: Font.AllUppercase
                font.pointSize: tabPointSize
                height: tabHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Material.foreground: errMeasHelper.registerPass(entity, errMeasHelper.spm1mod1Running) ? Material.White : Material.Red
            }
            AnimationActivity {
                targetItem: tabButtonPower
                running: errMeasHelper.spm1mod1Running
            }
        }
    }

    // Pages
    Component {
        id: pagePulse
        ErrorCalculatorModulePage {
            errCalEntity: errMeasHelper.sec1mod1Entity
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
            errCalEntity: errMeasHelper.sec1mod2Entity
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
            errCalEntity: errMeasHelper.sem1mod1Entity
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
            errCalEntity: errMeasHelper.spm1mod1Entity
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
        if(errMeasHelper.hasSEC1) {
            tabBar.addItem(tabPulse.createObject(tabBar))
            swipeView.addItem(pagePulse.createObject(swipeView))
        }
        if(errMeasHelper.hasSEC1_2) {
            tabBar.addItem(tabPulseEnergy.createObject(tabBar))
            swipeView.addItem(pagePulseEnergy.createObject(swipeView))
        }
        if(errMeasHelper.hasSEM1) {
            tabBar.addItem(tabEnergy.createObject(tabBar))
            swipeView.addItem(pageEnergy.createObject(swipeView))
        }
        if(errMeasHelper.hasSPM1) {
            tabBar.addItem(tabPower.createObject(tabBar))
            swipeView.addItem(pagePower.createObject(swipeView))
        }
        finishInit()
    }
}
