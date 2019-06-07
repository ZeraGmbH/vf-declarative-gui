import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import "qrc:/qml/pages" as Pages

Item {
  id: root
  readonly property bool hasSEC1: ModuleIntrospection.hasDependentEntities(["SEC1Module1"])
  readonly property bool hasSEM1: ModuleIntrospection.hasDependentEntities(["SEM1Module1"])
  readonly property bool hasSPM1: ModuleIntrospection.hasDependentEntities(["SPM1Module1"])

  SwipeView {
    id: swipeView
    anchors.fill: parent
    anchors.topMargin: comparisonTabsBar.height
    currentIndex: comparisonTabsBar.currentIndex
    spacing: 20
  }

  TabBar {
    id: comparisonTabsBar
    width: parent.width
    currentIndex: swipeView.currentIndex
  }

  // TabButtons
  Component {
    id: tabPulse
    TabButton {
      text: ZTR["Pulse measurement"]
    }
  }
  Component {
    id: tabEnergy
    TabButton {
      text: ZTR["Energy register"]
    }
  }
  Component {
    id: tabPower
    TabButton {
      text: ZTR["Power register"]
    }
  }

  // Pages
  Component {
    id: pagePulse
    Pages.ErrorCalculatorModulePage {
    }
  }
  Component {
    id: pageEnergy
    Pages.EnergyRegisterModulePage {
    }
  }
  Component {
    id: pagePower
    Pages.PowerRegisterModulePage {
    }
  }

  // create tabs/pages dynamic
  Component.onCompleted: {
    if(hasSEC1) {
      comparisonTabsBar.addItem(tabPulse.createObject(comparisonTabsBar))
      swipeView.addItem(pagePulse.createObject(swipeView))
    }
    if(hasSEM1) {
      comparisonTabsBar.addItem(tabEnergy.createObject(comparisonTabsBar))
      swipeView.addItem(pageEnergy.createObject(swipeView))
    }
    if(hasSPM1) {
      comparisonTabsBar.addItem(tabPower.createObject(comparisonTabsBar))
      swipeView.addItem(pagePower.createObject(swipeView))
    }
  }
}


