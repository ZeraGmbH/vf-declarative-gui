import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0

Item {
    id: root
    readonly property real tabPointSize: height * 0.0225
    readonly property real tabHeight: height * 0.07

    property alias swipeView: swipeView
    property alias tabBar: tabBar
    property alias initTimer: initTimer
    // We default to what most views (measurement pages) do. Other type
    // of views can override getLastTabSelected and setLastTabSelected
    function getLastTabSelected() {
        return GC.lastTabSelected
    }
    function setLastTabSelected(tabNo) {
        GC.setLastTabSelected(tabNo)
    }
    function finishInit() {
        let lastTabSelected = getLastTabSelected()
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

    // pass focus to swipeView
    onFocusChanged: {
        if(focus) {
            swipeView.forceActiveFocus()
        }
    }
    onInitializedChanged: forceActiveFocus()

    SwipeView {
        id: swipeView
        visible: initialized
        anchors.fill: parent
        anchors.topMargin: tabBar.height
        currentIndex: tabBar.currentIndex
        spacing: 20
    }

    TabBar {
        id: tabBar
        width: parent.width
        contentHeight: tabHeight
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: {
            if(initialized) {
                setLastTabSelected(currentIndex)
                swipeView.forceActiveFocus()
            }
        }
    }

    property bool initialized: false
    Timer {
        id: initTimer
        interval: 250
        onTriggered: {
            initialized = true
        }
    }


}
