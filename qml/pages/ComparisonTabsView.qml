import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0
import ZeraTranslation  1.0
import ModuleIntrospection 1.0
import "qrc:/qml/pages" as Pages

Item {
  id: root

  TabBar {
    id: comparisonTabsView
    width: parent.width
    TabButton {
      text: ZTR["Pulse Measurement"]
      visible: ModuleIntrospection.hasDependentEntities(["SEC1Module1"])
    }
    TabButton {
      text: ZTR["Energy Register"]
      visible: ModuleIntrospection.hasDependentEntities(["SEM1Module1"])
    }
  }

  StackLayout {
    id: stackLayout
    anchors.fill: parent
    anchors.topMargin: comparisonTabsView.height
    currentIndex: comparisonTabsView.currentIndex
    Pages.ErrorCalculatorModulePage {
      id: errorCalculator
    }
    Pages.EnergyRegisterModulePage {
      id: energyRegister
    }
  }
}


