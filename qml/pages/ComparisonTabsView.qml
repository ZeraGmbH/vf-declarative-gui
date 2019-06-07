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
    anchors.topMargin: comparisonTabsView.height
    currentIndex: comparisonTabsView.currentIndex
    spacing: 20
    Pages.ErrorCalculatorModulePage {
      id: errorCalculator
    }
    Pages.EnergyRegisterModulePage {
      id: energyRegister
    }
    Pages.PowerRegisterModulePage {
      id: powerRegister
    }
  }

  TabBar {
    id: comparisonTabsView
    width: parent.width
    currentIndex: swipeView.currentIndex
    TabButton {
      text: ZTR["Pulse measurement"]
      //visible: ModuleIntrospection.hasDependentEntities(["SEC1Module1"])
    }
    TabButton {
      text: ZTR["Energy register"]
      //visible: ModuleIntrospection.hasDependentEntities(["SEM1Module1"])
    }
    TabButton {
      text: ZTR["Power register"]
      //visible: ModuleIntrospection.hasDependentEntities(["SPM1Module1"])
    }
  }
}


