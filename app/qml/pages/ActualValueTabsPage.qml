import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0

Item {
    id: root
    readonly property real tabPointSize: height * 0.0225
    readonly property real tabHeight: tabBar.count > 1 ? height * 0.08 : 0

    function finishInit() {
        var lastTabSelected = getLastTabSelected()
        if(lastTabSelected >= swipeView.count)
            lastTabSelected = 0
        swipeView.setCurrentIndex(lastTabSelected)
        initTimer.start()
    }
    // We default to what most views (measurement pages) do. Other type
    // of views can override getLastTabSelected and setLastTabSelected
    function getLastTabSelected() {
        return GC.lastTabSelected
    }
    function setLastTabSelected(tabNo) {
        GC.setLastTabSelected(tabNo)
    }
    property bool initialized: false
    Timer {
        id: initTimer
        interval: 250
        onTriggered: {
            initialized = true
            tabBar.currentItem.forceActiveFocus() // for arrow key navigation
        }
    }
    TabBar {
        id: tabBar
        anchors { top: root.top; left: root.left; right: root.right }
        contentHeight: tabHeight
        currentIndex: swipeView.currentIndex
        visible: tabHeight>0
        onCurrentIndexChanged: {
            if(initialized)
                setLastTabSelected(currentIndex)
        }
        ZTabButton {
            id: tabTable
            text:Z.tr("Actual values")
            font.pointSize: tabPointSize
            height: tabHeight
        }
        ZTabButton {
            id: tabVector
            text: Z.tr("Vector diagram")
            font.pointSize: tabPointSize
            height: tabHeight
        }
        ZTabButton {
            id: tabPower
            text: Z.tr("Power values")
            font.pointSize: tabPointSize
            height: tabHeight
        }
        ZTabButton {
            id: tabRms
            text: Z.tr("RMS values")
            font.pointSize: tabPointSize
            height: tabHeight
        }
    }
    SwipeView {
        id: swipeView
        visible: initialized
        anchors { top: tabBar.bottom; bottom: root.bottom; left: root.left; right: root.right }
        currentIndex: tabBar.currentIndex
        spacing: 20
        ActualValuesPage {
            id: pageTable
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_ACTUAL_VALUES
                }
            }
        }
        VectorModulePage {
            id: pageVector
            topMargin: 10
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_VECTOR_DIAGRAM
                }
            }
        }
        PowerModulePage {
            id: pagePower
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_POWER_VALUES
                }
            }
        }
        RMS4PhasePage {
            id: pageRms
            SwipeView.onIsCurrentItemChanged: {
                if(SwipeView.isCurrentItem) {
                    GC.currentGuiContext = GC.guiContextEnum.GUI_RMS_VALUES
                }
            }
        }
    }

    Component.onCompleted: {
        finishInit()
    }
}
