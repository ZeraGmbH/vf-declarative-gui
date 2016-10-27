import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/ccmp/common" as CCMP
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import QwtChart 1.0
import Com5003Translation  1.0

Item {
  id: root

  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

  property bool bottomLabels: true
  property real maxValue: VeinEntity.getEntity("_System").Session !== "1_ref-session.json" ? 1000 : 20
  property real minValue: Math.pow(10,-3)

  property bool rangeGrouping: false

  function getColorByIndex(rangIndex) {
    var retVal;
    if(rangeGrouping === true)
    {
      var channelName = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+rangIndex+"Range"].ChannelName;
      if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup1.indexOf(channelName)>-1)
      {
        retVal = GC.groupColorVoltage
      }
      else if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup2.indexOf(channelName)>-1)
      {
        retVal = GC.groupColorCurrent
      }
      else if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup3.indexOf(channelName)>-1)
      {
        retVal = GC.groupColorReference
      }
    }
    else
    {
      retVal = GC.systemColorByIndex(rangIndex)
    }
    return retVal;
  }

  BarChart {
    id: peakChart

    anchors.fill: parent
    anchors.bottomMargin: 16

    color: Material.backgroundColor
    leftAxisBars: [barUL1, barUL2, barUL3, barIL1, barIL2, barIL3]
    leftAxisLogScale: GC.showRangePeakAsLogAxis
    legendEnabled: false//root.legendEnabled
    bottomLabelsEnabled: root.bottomLabels

    chartTitle: ZTR["Peak values"]
    leftAxisMinValue: root.minValue
    leftAxisMaxValue: root.maxValue
    textColor: Material.primaryTextColor
    Bar {
      id: barUL1
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel1Peak.ChannelName
      value: rangeModule.ACT_Channel1Peak
      color: getColorByIndex(1)
    }
    Bar {
      id: barUL2
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel2Peak.ChannelName
      value: rangeModule.ACT_Channel2Peak
      color: getColorByIndex(2)
    }
    Bar {
      id: barUL3
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel3Peak.ChannelName
      value: rangeModule.ACT_Channel3Peak
      color: getColorByIndex(3)
    }
    Bar {
      id: barIL1
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel4Peak.ChannelName
      value: rangeModule.ACT_Channel4Peak
      color: getColorByIndex(4)
    }
    Bar {
      id: barIL2
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel5Peak.ChannelName
      value: rangeModule.ACT_Channel5Peak
      color: getColorByIndex(5)
    }
    Bar {
      id: barIL3
      title: ModuleIntrospection.rangeIntrospection.ComponentInfo.ACT_Channel6Peak.ChannelName
      value: rangeModule.ACT_Channel6Peak
      color: getColorByIndex(6)
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
