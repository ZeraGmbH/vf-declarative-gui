import QtQuick 2.0
import GlobalConfig 1.0
import "qrc:/qml/controls" as CCMP
import "qrc:/qml/vf-controls" as VFControls
import "qrc:/qml/controls/fft_module" as D

CCMP.ModulePage {
  Component {
    id: chartComponent
    D.FftCharts {
      anchors.fill: parent
    }
  }

  Component {
    id: tableComponent
    D.FftTable {
      anchors.fill: parent
    }
  }

  Loader {
    anchors.fill: parent
    sourceComponent: GC.showFftAsTable ? tableComponent : chartComponent
  }
}
