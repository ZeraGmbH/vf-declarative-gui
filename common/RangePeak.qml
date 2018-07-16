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
  property real minValue: 1e-6;
  property bool rangeGrouping: false

  BarChart {
    id: peakChart

    property var peakBars: []

    anchors.fill: parent
    anchors.bottomMargin: 16
    color: Material.backgroundColor
    leftAxisBars: peakBars
    leftAxisLogScale: GC.rangePeakVisualisation === GC.rangePeakVisualisationEnum.RPV_ABSOLUTE_LOGSCALE
    legendEnabled: false//root.legendEnabled
    bottomLabelsEnabled: root.bottomLabels
    leftScaleTransform: GC.rangePeakVisualisation === GC.rangePeakVisualisationEnum.RPV_RELATIVE_TO_LIMIT ? "%1%" : "%1";

    chartTitle: ZTR["Peak values"]
    leftAxisMinValue: GC.rangePeakVisualisation === GC.rangePeakVisualisationEnum.RPV_RELATIVE_TO_LIMIT ? 0 : root.minValue
    leftAxisMaxValue: GC.rangePeakVisualisation === GC.rangePeakVisualisationEnum.RPV_RELATIVE_TO_LIMIT ? 125 : root.maxValue
    textColor: Material.primaryTextColor
    Repeater {
      model: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
      delegate: Bar {
        title: ModuleIntrospection.rangeIntrospection.ComponentInfo["ACT_Channel"+(index+1)+"Peak"].ChannelName
        value: (GC.rangePeakVisualisation === GC.rangePeakVisualisationEnum.RPV_RELATIVE_TO_LIMIT ? relativeValue : rangeModule["ACT_Channel"+(index+1)+"Peak"]) + 1e-15; //0.0 is out of domain for logscale
        //toFixed(2) because of visual screen flickering of bars, bug in Qwt?
        //Math.sqrt(2) because peak value are compared with rms rejection
        property real relativeValue: (100 * rangeModule["ACT_Channel"+(index+1)+"Peak"] / (Math.sqrt(2) * rangeModule["INF_Channel"+(index+1)+"ActREJ"])).toFixed(2)
        color: GC.getColorByIndex(index+1, root.rangeGrouping)
        Component.onCompleted: {
          peakChart.peakBars.push(this);
          peakChart.peakBarsChanged();
        }
      }
    }
  }

  ComboBox {
    anchors.bottom: peakChart.bottom
    anchors.bottomMargin: -45
    width: parent.width*0.8
    anchors.right: parent.right
    readonly property var translatedModel: {
      var inputKeys = Object.keys(GC.rangePeakVisualisationEnum)
      var retVal = [];
      for(var i in inputKeys)
      {
        retVal.push(ZTR[inputKeys[i]]);
      }
      return retVal;
    }

    model: translatedModel
    currentIndex: GC.rangePeakVisualisation

    onActivated: {
      GC.setRangePeakVisualisation(index);
    }

    Label {
      text: "Scale visualisation:"
      anchors.right: parent.left
      anchors.rightMargin: 8
      font.pointSize: 14
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
