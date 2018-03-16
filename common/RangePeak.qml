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
/*
    Bar {
      id: barUL1
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel1Peak.ChannelName
      value: rangeModule.ACT_Channel1Peak
      color: GC.getColorByIndex(1, root.rangeGrouping)
    }
    Bar {
      id: barUL2
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel2Peak.ChannelName
      value: rangeModule.ACT_Channel2Peak
      color: GC.getColorByIndex(2, root.rangeGrouping)
    }
    Bar {
      id: barUL3
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel3Peak.ChannelName
      value: rangeModule.ACT_Channel3Peak
      color: GC.getColorByIndex(3, root.rangeGrouping)
    }
    Bar {
      id: barUN
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel7Peak.ChannelName
      value: rangeModule.ACT_Channel7Peak
      color: GC.getColorByIndex(7, root.rangeGrouping)
    }
    Bar {
      id: barIL1
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel4Peak.ChannelName
      value: rangeModule.ACT_Channel4Peak
      color: GC.getColorByIndex(4, root.rangeGrouping)
    }
    Bar {
      id: barIL2
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel5Peak.ChannelName
      value: rangeModule.ACT_Channel5Peak
      color: GC.getColorByIndex(5, root.rangeGrouping)
    }
    Bar {
      id: barIL3
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel6Peak.ChannelName
      value: rangeModule.ACT_Channel6Peak
      color: GC.getColorByIndex(6, root.rangeGrouping)
    }
    Bar {
      id: barIN
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel8Peak.ChannelName
      value: rangeModule.ACT_Channel8Peak
      color: GC.getColorByIndex(8, root.rangeGrouping)
    }
    */
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
