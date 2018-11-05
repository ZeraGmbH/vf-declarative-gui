import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import "qrc:/components/common" as CCMP
import "qrc:/vf-controls/common" as VFControls
import "qrc:/data/staticdata/FontAwesome.js" as FA
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0

Rectangle {
  //holds the state data
  property QtObject logicalParent;

  border.color: Material.dividerColor
  color: "transparent"

  BarChart {
    id: errorMarginChart
    anchors.fill: parent

    color: errorBar.isInMargins ? Material.backgroundColor :  Qt.darker("darkred", 2.5)
    property var barModel: []
    leftAxisBars: barModel
    leftBaseline: (GC.errorMarginUpperValue+GC.errorMarginLowerValue)/2;
    legendEnabled: false
    bottomLabelsEnabled: false

    property real maxValue: GC.errorMarginUpperValue
    onMaxValueChanged: setMarkers(minValue, maxValue)
    property real minValue: GC.errorMarginLowerValue
    onMinValueChanged: setMarkers(minValue, maxValue)

    markersEnabled: true
    leftAxisMaxValue: maxValue!==0 ? maxValue+minMaxOffset : (minMaxOffset!==0 ? minMaxOffset : 0.25)
    leftAxisMinValue: minValue!==0 ? minValue-minMaxOffset : (minMaxOffset!==0 ? -minMaxOffset : -0.25)

    readonly property real minMaxOffset: Math.max(Math.abs(maxValue), Math.abs(minValue)) *0.25
    textColor: Material.primaryTextColor
    Component.onCompleted: setMarkers(minValue, maxValue);
    Bar {
      id: errorBar
      value: logicalParent.errorCalculator.ACT_Result
      readonly property bool isInMargins: value.toFixed(GC.decimalPlaces) >= errorMarginChart.minValue && value.toFixed(GC.decimalPlaces) <= errorMarginChart.maxValue
      color: isInMargins ? "green" : "red"

      Component.onCompleted: {
        errorMarginChart.barModel.push(this);
        errorMarginChart.barModelChanged();
      }
    }
  }
}
