import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import QwtChart 1.0
import ZeraTranslation  1.0

Item {
  id: root

  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

  property bool bottomLabels: true
  property real maxValue: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json" ? 1000 : 20
  property real minValue: Math.pow(10,-6)

  property bool rangeGrouping: false

  BarChart {
    id: peakChart

    anchors.fill: parent
    anchors.bottomMargin: 16


    color: Material.backgroundColor
    property var peakBars: []
    leftAxisBars: peakBars
    leftAxisLogScale: GC.showRangePeakAsLogAxis
    legendEnabled: false//root.legendEnabled
    bottomLabelsEnabled: root.bottomLabels

    chartTitle: ZTR["Peak values"]
    leftAxisMinValue: root.minValue
    leftAxisMaxValue: root.maxValue
    textColor: Material.primaryTextColor
    Repeater {
      model: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
      delegate: Bar {
        title: ModuleIntrospection.rangeIntrospection.ComponentInfo["ACT_Channel"+(index+1)+"Peak"].ChannelName
        value: rangeModule["ACT_Channel"+(index+1)+"Peak"]
        color: GC.getColorByIndex(index+1, root.rangeGrouping)
        Component.onCompleted: {
          peakChart.peakBars.push(this);
          peakChart.peakBarsChanged();
        }
      }
    }
  }

  CheckBox {
    anchors.bottom: peakChart.bottom
    anchors.bottomMargin: -45
    anchors.right: parent.right
    text: ZTR["Logarithmic scale"]
    checked: GC.showRangePeakAsLogAxis
    onCheckedChanged: {
      if(checked !== GC.showRangePeakAsLogAxis)
      {
        GC.setShowRangePeakAsLogAxis(checked);
      }
    }
  }
}
