import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import "qrc:/components/common" as CCMP
import GlobalConfig 1.0
import ZeraGlueLogic 1.0

CCMP.ModulePage {
  id: root

  readonly property QtObject glueLogic: ZGL;
  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1");

  ChartView {
    id: chartS1
    anchors.top: root.top
    height: root.height/2.5
    width: root.width

    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      rotation: -90
      text: "UL1"
      color: GC.system1ColorDark
    }
    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      rotation: 90
      text: "IL1"
      color: GC.system1ColorBright
    }

    antialiasing: false
    backgroundColor: Material.backgroundColor
    legend.visible:false

    ValueAxis {
      id: xAxisC1
      min: 0
      max: 127
      labelsVisible: false
      gridVisible: true
      tickCount: 2
      minorGridVisible: false
      gridLineColor: Material.frameColor
      color: "transparent"
    }
    ValueAxis {
      id: yAxisLeftC1

      property real minMax: root.rangeModule.INF_Channel1ActREJ*1.5

      min: -minMax
      max: minMax
      tickCount: 3

      minorGridLineColor: Material.dividerColor
      gridLineColor: Material.frameColor
      labelsColor: Material.primaryTextColor
      color: Material.frameColor
    }
    ValueAxis {
      id: yAxisRightC1

      property real minMax: root.rangeModule.INF_Channel4ActREJ*1.5

      min: -minMax
      max: minMax
      tickCount: 3

      minorGridLineColor: Material.dividerColor
      gridLineColor: Material.frameColor
      labelsColor: Material.primaryTextColor
      color: Material.frameColor
    }

    LineSeries {
      id: ul1Series
      axisX: xAxisC1
      axisY: yAxisLeftC1
      color: GC.system1ColorDark
      width: 2
      useOpenGL: true
    }

    LineSeries {
      id: il1Series
      axisX: xAxisC1
      axisYRight: yAxisRightC1
      color: GC.system1ColorBright
      width: 2
      useOpenGL: true
    }
    HXYModelMapper {
      model: root.glueLogic.OSCIP1Model
      series: ul1Series
      xRow: 0
      yRow: 1
    }
    HXYModelMapper {
      model: root.glueLogic.OSCIP1Model
      series: il1Series
      xRow: 0
      yRow: 2
    }
  }


  ChartView {
    id: chartS2
    anchors.top: chartS1.bottom
    anchors.topMargin: -height/5
    height: root.height/2.5
    width: root.width

    antialiasing: false
    backgroundColor: Material.backgroundColor
    legend.visible:false

    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      rotation: -90
      text: "UL2"
      color: GC.system2ColorDark
    }
    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      rotation: 90
      text: "IL2"
      color: GC.system2ColorBright
    }


    ValueAxis {
      id: xAxisC2
      min: 0
      max: 127
      labelsVisible: false
      gridVisible: true
      tickCount: 2
      minorGridVisible: false
      gridLineColor: Material.frameColor
      color: "transparent"
    }
    ValueAxis {
      id: yAxisLeftC2

      property real minMax: root.rangeModule.INF_Channel2ActREJ*1.5

      min: -minMax
      max: minMax
      tickCount: 3

      minorGridLineColor: Material.dividerColor
      gridLineColor: Material.frameColor
      labelsColor: "white"
      color: Material.frameColor
    }
    ValueAxis {
      id: yAxisRightC2

      property real minMax: root.rangeModule.INF_Channel5ActREJ*1.5

      min: -minMax
      max: minMax
      tickCount: 3

      minorGridLineColor: Material.dividerColor
      gridLineColor: Material.frameColor
      labelsColor: Material.primaryTextColor
      color: Material.frameColor
    }

    LineSeries {
      id: ul2Series
      axisX: xAxisC2
      axisY: yAxisLeftC2
      color: GC.system2ColorDark
      width: 2
      useOpenGL: true
    }

    LineSeries {
      id: il2Series
      axisX: xAxisC2
      axisYRight: yAxisRightC2
      color: GC.system2ColorBright
      width: 2
      useOpenGL: true
    }
    HXYModelMapper {
      model: root.glueLogic.OSCIP2Model
      series: ul2Series
      xRow: 0
      yRow: 1
    }
    HXYModelMapper {
      model: root.glueLogic.OSCIP2Model
      series: il2Series
      xRow: 0
      yRow: 2
    }
  }


  ChartView {
    id: chartS3
    anchors.top: chartS2.bottom
    anchors.topMargin: -height/5
    height: root.height/2.5
    width: root.width

    antialiasing: false
    backgroundColor: Material.backgroundColor
    legend.visible:false

    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      rotation: -90
      text: "UL3"
      color: GC.system3ColorDark
    }
    Label {
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      rotation: 90
      text: "IL3"
      color: GC.system3ColorBright
    }


    ValueAxis {
      id: xAxisC3
      min: 0
      max: 127
      labelsVisible: false
      gridVisible: true
      tickCount: 2
      minorGridVisible: false
      gridLineColor: Material.frameColor
      color: "transparent"
    }
    ValueAxis {
      id: yAxisLeftC3

      property real minMax: root.rangeModule.INF_Channel3ActREJ*1.5

      min: -minMax
      max: minMax
      tickCount: 3

      minorGridLineColor: Material.dividerColor
      gridLineColor: Material.frameColor
      labelsColor: Material.primaryTextColor
      color: Material.frameColor
    }
    ValueAxis {
      id: yAxisRightC3

      property real minMax: root.rangeModule.INF_Channel6ActREJ*1.5

      min: -minMax
      max: minMax
      tickCount: 3

      minorGridLineColor: Material.dividerColor
      gridLineColor: Material.frameColor
      labelsColor: Material.primaryTextColor
      color: Material.frameColor
    }

    LineSeries {
      id: ul3Series
      axisX: xAxisC3
      axisY: yAxisLeftC3
      color: GC.system3ColorDark
      width: 2
      useOpenGL: true
    }

    LineSeries {
      id: il3Series
      axisX: xAxisC3
      axisYRight: yAxisRightC3
      color: GC.system3ColorBright
      width: 2
      useOpenGL: true
    }
    HXYModelMapper {
      model: root.glueLogic.OSCIP3Model
      series: ul3Series
      xRow: 0
      yRow: 1
    }
    HXYModelMapper {
      model: root.glueLogic.OSCIP3Model
      series: il3Series
      xRow: 0
      yRow: 2
    }
  }
}
