import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import "qrc:/qml/pages" as Pages

Item {
    id: root

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.topMargin: actualValueTabsBar.height
        currentIndex: actualValueTabsBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: actualValueTabsBar
        width: parent.width
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: GC.setLastTabSelected(currentIndex)
        contentHeight: 32
    }

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
        let lastTabSelected = GC.lastTabSelected // keep - it is overwritten on page setup
        actualValueTabsBar.addItem(tabTable.createObject(actualValueTabsBar))
        swipeView.addItem(pageTable.createObject(swipeView))

        actualValueTabsBar.addItem(tabVector.createObject(actualValueTabsBar))
        swipeView.addItem(pageVector.createObject(swipeView))

        actualValueTabsBar.addItem(tabPower.createObject(actualValueTabsBar))
        swipeView.addItem(pagePower.createObject(swipeView))

        actualValueTabsBar.addItem(tabRms.createObject(actualValueTabsBar))
        swipeView.addItem(pageRms.createObject(swipeView))

        swipeView.currentIndex = lastTabSelected
        swipeView.currentIndex = Qt.binding(() => actualValueTabsBar.currentIndex);
    }
}
