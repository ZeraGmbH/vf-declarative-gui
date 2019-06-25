import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
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
    contentHeight: 32
  }

  // TabButtons
  Component {
    id: tabTable
    TabButton {
      text: ZTR["Actual values"]
    }
  }
  Component {
    id: tabVector
    TabButton {
      text: ZTR["Vector diagram"]
    }
  }

  // Pages
  Component {
    id: pageTable
    Pages.ActualValuesPage {
    }
  }
  Component {
    id: pageVector
    Pages.DFTModulePage {
      topMargin: 10
    }
  }

  // create tabs/pages dynamic
  Component.onCompleted: {

    actualValueTabsBar.addItem(tabTable.createObject(actualValueTabsBar))
    swipeView.addItem(pageTable.createObject(swipeView))

    actualValueTabsBar.addItem(tabVector.createObject(actualValueTabsBar))
     swipeView.addItem(pageVector.createObject(swipeView))
  }
}


