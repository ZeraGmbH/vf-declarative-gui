import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Controls.Material 2.0

ChartView {
  titleColor: Material.primaryTextColor
  antialiasing: true
  backgroundColor: Material.backgroundColor
  plotAreaColor: backgroundColor
  margins.top: 0
  margins.bottom: 0
  margins.left: 0
  margins.right: 0

  legend.labelColor: "white" //Material.primaryTextColor //causes ugly white borders around the colored rectangle
}
