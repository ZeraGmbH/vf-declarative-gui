import QtQuick 2.14
import QtQuick.Controls 2.14
import GlobalConfig 1.0

Item {
    id: root
    property alias swipeView: swipeView
    property alias tabBar: tabBar
    property alias initTimer: initTimer

    function finishInit() {
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

    onInitializedChanged: forceActiveFocus()
    Keys.onRightPressed: {
        if(swipeView.currentIndex < swipeView.count-1) {
            swipeView.setCurrentIndex(swipeView.currentIndex+1)
        }
    }
    Keys.onLeftPressed: {
        if(swipeView.currentIndex > 0) {
            swipeView.setCurrentIndex(swipeView.currentIndex-1)
        }
    }

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
        contentHeight: 32
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: {
            if(initialized) {
                GC.setLastTabSelected(currentIndex)
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
