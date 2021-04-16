import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import "qrc:/qml/pages" as Pages

BaseTabPage {
    id: root

    // TabButtons
    Component {
        id: tabTable
        TabButton {
            text:Z.tr("Actual values")
        }
    }
    Component {
        id: tabVector
        TabButton {
            text: Z.tr("Vector diagram")
        }
    }
    Component {
        id: tabPower
        TabButton {
            text: Z.tr("Power values")
        }
    }
    Component {
        id: tabRms
        TabButton {
            text: Z.tr("RMS values")
        }
    }

    // Pages
    Component {
        id: pageTable
        Pages.ActualValuesPage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ACTUAL_VALUES
                }
            }
        }
    }
    Component {
        id: pageVector
        Pages.VectorModulePage {
            topMargin: 10
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_VECTOR_DIAGRAM
                }
            }
        }
    }
    Component {
        id: pagePower
        Pages.PowerModulePage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_POWER_VALUES
                }
            }
        }
    }
    Component {
        id: pageRms
        Pages.RMS4PhasePage {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_RMS_VALUES
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        tabBar.addItem(tabTable.createObject(tabBar))
        swipeView.addItem(pageTable.createObject(swipeView))

        tabBar.addItem(tabVector.createObject(tabBar))
        swipeView.addItem(pageVector.createObject(swipeView))

        tabBar.addItem(tabPower.createObject(tabBar))
        swipeView.addItem(pagePower.createObject(swipeView))

        tabBar.addItem(tabRms.createObject(tabBar))
        swipeView.addItem(pageRms.createObject(swipeView))

        finishInit()
    }
}
