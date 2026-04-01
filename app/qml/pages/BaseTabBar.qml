import QtQuick 2.14
import QtQuick.Controls 2.14

TabBar {
    anchors { top: root.top; left: root.left; right: root.right }
    contentHeight: tabHeight
    currentIndex: swipeView.currentIndex
    visible: tabHeight>0
    onCurrentIndexChanged: {
        if(initialized)
            setLastTabSelected(currentIndex)
    }
}
