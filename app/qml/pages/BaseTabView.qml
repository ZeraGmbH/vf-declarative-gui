import QtQuick 2.14
import QtQuick.Controls 2.14

SwipeView {
    id: swipeViewBaseItem
    visible: initialized
    anchors { top: tabBar.bottom; bottom: root.bottom; left: root.left; right: root.right }
    currentIndex: tabBar.currentIndex
    spacing: 20
}
