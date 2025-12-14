import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import "../controls/harmonic_power_module"

BaseTabPage {
    id: root

    // TabButtons
    Component {
        id: tabChart
        ZTabButton {
            text: Z.tr("Harmonic power table")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    Component {
        id: tabEnergy
        ZTabButton {
            text: Z.tr("Harmonic power chart")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }

    // Pages
    Component {
        id: pageTable
        HarmonicPowerTable {
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_HARMONIC_POWER_TABLE
                }
            }
        }
    }
    Component {
        id: pageChart
        HarmonicPowerCharts {
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
