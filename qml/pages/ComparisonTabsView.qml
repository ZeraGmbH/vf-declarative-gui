import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import VeinEntity 1.0
import ModuleIntrospection 1.0
import "qrc:/qml/pages" as Pages

Item {
  id: root
  readonly property bool hasSEC1: ModuleIntrospection.hasDependentEntities(["SEC1Module1"])
  readonly property bool hasSEC1_2: ModuleIntrospection.hasDependentEntities(["SEC1Module2"])
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
    contentHeight: 32
  }

  // TabButtons
  Component {
    id: tabPulse
    TabButton {
      text: ZTR["Pulse measurement"]
    }
  }
  Component {
    id: tabPulseEnergy
    TabButton {
      text: ZTR["Energy comparison"]
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
      errCalEntity: VeinEntity.getEntity("SEC1Module1")
    }
  }
  Component {
    id: pagePulseEnergy
    Pages.ErrorCalculatorModulePage {
      errCalEntity: VeinEntity.getEntity("SEC1Module2")
    }
  }
  Component {
    id: pageEnergy
    Pages.ErrorRegisterModulePage {
      errCalEntity: VeinEntity.getEntity("SEM1Module1")
      moduleIntrospection: ModuleIntrospection.sem1Introspection
    }
  }
  Component {
    id: pagePower
    Pages.ErrorRegisterModulePage {
      errCalEntity: VeinEntity.getEntity("SPM1Module1")
      moduleIntrospection: ModuleIntrospection.spm1Introspection
    }
  }

  // create tabs/pages dynamic
  Component.onCompleted: {
    if(hasSEC1) {
      comparisonTabsBar.addItem(tabPulse.createObject(comparisonTabsBar))
      swipeView.addItem(pagePulse.createObject(swipeView))
    }
    if(hasSEC1_2) {
      comparisonTabsBar.addItem(tabPulse.createObject(comparisonTabsBar))
      swipeView.addItem(pagePulseEnergy.createObject(swipeView))
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


