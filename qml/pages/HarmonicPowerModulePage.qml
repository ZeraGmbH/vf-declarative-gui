import QtQuick 2.0
import GlobalConfig 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/controls/harmonic_power_module" as D


CCMP.ModulePage {
  Component {
    id: chartComponent
    D.HarmonicPowerCharts {
      anchors.fill: parent
    }
  }

  Component {
    id: tableComponent
    D.HarmonicPowerTable {
      anchors.fill: parent
    }
  }

  Loader {
    anchors.fill: parent
    sourceComponent: GC.showFftAsTable ? tableComponent : chartComponent
  }
}
