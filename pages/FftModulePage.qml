import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/ccmp/common/" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0

import ModuleIntrospection 1.0

CCMP.ModulePage {
  readonly property QtObject glueLogic: VeinEntity.getEntity("Local.GlueLogic")
  readonly property QtObject fftModule: VeinEntity.getEntity("FFTModule1")

  Loader {
    anchors.fill: parent
    source: GC.showFftAsTable ? "qrc:/ccmp/common/FftTable.qml" : "qrc:/ccmp/common/FftCharts.qml"
  }
}
