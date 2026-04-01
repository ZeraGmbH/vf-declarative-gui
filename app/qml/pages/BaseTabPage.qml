import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import ZeraTranslation  1.0

Item {
    id: root

    readonly property real tabPointSize: height * 0.0225
    readonly property real tabHeight: tabBar.count > 1 ? height * 0.08 : 0

    property QtObject swipeView: swipeViewBaseItem
    property QtObject tabBar: tabBarBaseItem

    BaseTabBar { id: tabBarBaseItem }
    BaseTabView { id: swipeViewBaseItem }

    // We default to what most views (measurement pages) do. Other type
    // of views can override getLastTabSelected and setLastTabSelected
    function getLastTabSelected() {
        return GC.lastTabSelected
    }
    function setLastTabSelected(tabNo) {
        GC.setLastTabSelected(tabNo)
    }
    function finishInit() {
        var lastTabSelected = getLastTabSelected()
        if(lastTabSelected >= swipeView.count)
            lastTabSelected = 0
        swipeView.setCurrentIndex(lastTabSelected)
        initTimer.start()
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
}
