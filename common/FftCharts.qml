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

Item {
  id: root

  readonly property QtObject fftModule: VeinEntity.getEntity("FFTModule1")
  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")


  Repeater {
    model: 3
    FftBarChart {
      id: harmonicChart
      height: root.height/3
      width: root.width

      y: index*height

      rightAxisEnabled: true

      color: Material.backgroundColor
      borderColor: Material.backgroundColor
      legendEnabled: false
      bottomLabelsEnabled: true
      logScaleLeftAxis: false
      logScaleRightAxis: false
      colorLeftAxis: GC.systemColorByIndex(index+1)
      colorRightAxis: GC.systemColorByIndex(index+4)

      leftValue: fftModule[String("ACT_FFT%1").arg(index+1)]
      rightValue: fftModule[String("ACT_FFT%1").arg(index+4)]


      maxValueLeftAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+1)] * 1.5
      minValueLeftAxis: 0
      maxValueRightAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+4)] * 1.5
      minValueRightAxis: 0
      textColor: Material.primaryTextColor

      titleLeftAxis: ModuleIntrospection.rangeIntrospection.ComponentInfo[String("INF_Channel%1ActOVLREJ").arg(index+1)].ChannelName
      titleRightAxis: ModuleIntrospection.rangeIntrospection.ComponentInfo[String("INF_Channel%1ActOVLREJ").arg(index+4)].ChannelName
    }
  }
}
