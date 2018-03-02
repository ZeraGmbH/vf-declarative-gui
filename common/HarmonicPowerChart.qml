import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import "qrc:/data/staticdata/FontAwesome.js" as FA

Item {
  id: root

  readonly property QtObject power3Module: VeinEntity.getEntity("Power3Module1");
  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1");

  Repeater {
    model: 3
    HpwBarChart {
      id: harmonicChart
      height: root.height/3
      width: root.width

      y: index*height

      color: Material.backgroundColor
      borderColor: Material.backgroundColor
      legendEnabled: false
      bottomLabelsEnabled: true
      colorLeftAxis: GC.systemColorByIndex(index+1)

      leftValue: power3Module[String("ACT_HPW%1").arg(index+1)]


      maxValueLeftAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+1)] * rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+4)]
      minValueLeftAxis: -rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+1)] * rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+4)]
      textColor: Material.primaryTextColor

      titleLeftAxis: ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPW%1").arg(index+1)].ChannelName
    }
  }
}
