import QtQuick 2.0
import GlobalConfig 1.0
import QtQuick.Controls 2.4
import ZeraTranslation  1.0
import "qrc:/qml/controls/harmonic_power_module" as Pages

Item {
  id: root

  SwipeView {
    id: swipeView
    anchors.fill: parent
    anchors.topMargin: harmonicsTabsBar.height
    currentIndex: harmonicsTabsBar.currentIndex
    spacing: 20
  }

  TabBar {
    id: harmonicsTabsBar
    width: parent.width
    contentHeight: 32
    currentIndex: swipeView.currentIndex
  }

  // TabButtons
  Component {
    id: tabChart
    TabButton {
      text: ZTR["Harmonic power table"]
    }
  }
  Component {
    id: tabEnergy
    TabButton {
      text: ZTR["Harmonic power chart"]
    }
  }

  // Pages
  Component {
    id: pageTable
    Pages.HarmonicPowerTable {
    }
  }
  Component {
    id: pageChart
    Pages.HarmonicPowerCharts {
    }
  }

  // create tabs/pages dynamic
  Component.onCompleted: {
    // Tabs can be disabled e.g for licence or mdule enabled  - see ComparisonTabsView.qml
    harmonicsTabsBar.addItem(tabChart.createObject(harmonicsTabsBar))
    swipeView.addItem(pageTable.createObject(swipeView))

    harmonicsTabsBar.addItem(tabEnergy.createObject(harmonicsTabsBar))
    swipeView.addItem(pageChart.createObject(swipeView))
  }
}
