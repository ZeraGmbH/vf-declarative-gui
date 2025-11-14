import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import GlobalConfig 1.0
import ZeraTranslation  1.0

BaseTabPageEmpty {
    property alias swipeView: swipeView
    property alias tabBar: tabBar

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
}
