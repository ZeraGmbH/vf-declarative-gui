import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import ZeraTranslation  1.0

Item {
    id: root
    focus: true

    readonly property real tabPointSize: height * 0.0225
    readonly property real tabHeight: height * 0.08

    property alias swipeView: swipeView
    property alias tabBar: tabBar
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

    TabBar {
        id: tabBar
        width: root.width
        contentHeight: tabHeight
        anchors { top: root.top; left: root.left; right: root.right }
        currentIndex: swipeView.currentIndex
        onCurrentIndexChanged: {
            if(initialized) {
                setLastTabSelected(currentIndex)
                swipeView.forceActiveFocus()
            }
        }
    }

    SwipeView {
        id: swipeView
        visible: initialized
        anchors { top: tabBar.bottom; bottom: root.bottom; left: root.left; right: root.right }
        currentIndex: tabBar.currentIndex
        spacing: 20
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
