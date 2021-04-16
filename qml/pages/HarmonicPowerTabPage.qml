import QtQuick 2.0
import GlobalConfig 1.0
import QtQuick.Controls 2.4
import ZeraTranslation  1.0
import "qrc:/qml/controls/harmonic_power_module" as Pages

Item {
    id: root

    SwipeView {
        id: swipeView
        visible: initialized
        anchors.fill: parent
        anchors.topMargin: harmonicsTabsBar.height
        currentIndex: harmonicsTabsBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: harmonicsTabsBar
        width: parent.width
        contentHeight: 32
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: {
            if(initialized) {
                GC.setLastTabSelected(currentIndex)
            }
        }
    }

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
    property bool initialized: false
    Timer {
        id: initTimer
        interval: 250
        onTriggered: {
            initialized = true
        }
    }

    Component.onCompleted: {
        harmonicsTabsBar.addItem(tabChart.createObject(harmonicsTabsBar))
        swipeView.addItem(pageTable.createObject(swipeView))

        harmonicsTabsBar.addItem(tabEnergy.createObject(harmonicsTabsBar))
        swipeView.addItem(pageChart.createObject(swipeView))

        let lastTabSelected = GC.lastTabSelected
        if(lastTabSelected >= swipeView.count) {
            lastTabSelected = 0
        }
        if(lastTabSelected) {
            swipeView.setCurrentIndex(lastTabSelected)
            initTimer.start()
        }
        else {
            initialized = true
        }
    }
}
