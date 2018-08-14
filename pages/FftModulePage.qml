import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0
import ZeraGlueLogic 1.0
import ModuleIntrospection 1.0

CCMP.ModulePage {
  Loader {
    anchors.fill: parent
    source: GC.showFftAsTable ? "qrc:/components/common/FftTable.qml" : "qrc:/components/common/FftCharts.qml"
  }
}
