import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import SessionState 1.0
import VeinEntity 1.0
import Vf_Recorder 1.0
import "../controls/error_comparison_common"

BaseTabPage {
    id: root
    // TabButtons
    Component {
        id: tabTable
        TabButton {
            text:Z.tr("Actual values")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    Component {
        id: tabVector
        TabButton {
            text: Z.tr("Vector diagram")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    Component {
        id: tabPulse
        TabButtonComparison {
            entity: errMeasHelper.sec1mod1Entity
            baseLabel: Z.tr("Meter test")
            running: errMeasHelper.sec1mod1Running
        }
    }
    Component {
        id: tabEnergy
        TabButtonComparison {
            entity: errMeasHelper.sem1mod1Entity
            baseLabel: Z.tr("Energy register")
            running: errMeasHelper.sem1mod1Running
        }
    }
    Component {
        id: tabGraph
        TabButton {
            id: tabButton
            font.pointSize: tabPointSize
            height: tabHeight
            contentItem: Label {
                text: "Energy graphs"
                font.capitalization: Font.AllUppercase
                font.pointSize: tabPointSize
                height: tabHeight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Material.foreground: Material.White
            }
        }
    }

    // Pages
    Component {
        id: pageTable
        EMOBActualValuesPageAC {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ACTUAL_VALUES
                }
            }
        }
    }
    Component {
        id: pageVector
        VectorModulePage {
            topMargin: 10
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_VECTOR_DIAGRAM
                }
            }
        }
    }
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
        id: pageGraph
        EnergyGraphs {
            id: energyChart
            graphHeight: root.height
            graphWidth: root.width
            componentsList: SessionState.emobSession && SessionState.dcSession ? extractComponents(jsonEnergyDC) : extractComponents(jsonEnergyAC)
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        tabBar.addItem(tabTable.createObject(tabBar))
        swipeView.addItem(pageTable.createObject(swipeView))

        tabBar.addItem(tabVector.createObject(tabBar))
        swipeView.addItem(pageVector.createObject(swipeView))

        tabBar.addItem(tabPulse.createObject(tabBar))
        swipeView.addItem(pagePulse.createObject(swipeView))

        tabBar.addItem(tabEnergy.createObject(tabBar))
        swipeView.addItem(pageEnergy.createObject(swipeView))

        tabBar.addItem(tabGraph.createObject(tabBar))
        swipeView.addItem(pageGraph.createObject(swipeView))

        finishInit()
    }
}
