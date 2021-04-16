import QtQuick 2.0
import GlobalConfig 1.0
import QtQuick.Controls 2.4
import ZeraTranslation  1.0
import "qrc:/qml/controls/harmonic_power_module" as Pages

BaseTabPage {
    id: root

    // TabButtons
    Component {
        id: tabChart
        TabButton {
            text: Z.tr("Harmonic power table")
        }
    }
    Component {
        id: tabEnergy
        TabButton {
            text: Z.tr("Harmonic power chart")
        }
    }

    // Pages
    Component {
        id: pageTable
        Pages.HarmonicPowerTable {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_HARMONIC_POWER_TABLE
                }
            }
        }
    }
    Component {
        id: pageChart
        Pages.HarmonicPowerCharts {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_HARMONIC_POWER_CHART
                }
            }
        }
    }

    // create tabs/pages dynamic
    Component.onCompleted: {
        tabBar.addItem(tabChart.createObject(tabBar))
        swipeView.addItem(pageTable.createObject(swipeView))

        tabBar.addItem(tabEnergy.createObject(tabBar))
        swipeView.addItem(pageChart.createObject(swipeView))

        finishInit()
    }
}
