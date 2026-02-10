import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtCharts 2.14
import ZeraThemeConfig 1.0
import AxisSetter 1.0

Item {
    id: root
    property var graphWidth
    property var chartView
    property string title
    property string unitBase
    property bool onTheRight: false
    property alias valueAxis: axisY
    property alias axisSetter: axisYsetter

    function reset() {
        axisYsetter.min = 0
        axisYsetter.max = 10
    }

    ValueAxis {
        id: axisY
        titleText: title + "[" + axisYsetter.unitPrefix + unitBase + "]"
        titleFont.pixelSize: chartView.height * 0.06
        labelsFont.pixelSize: chartView.height * 0.04
        labelsVisible: false
        property real perDivision: (max - min) / (tickCount - 1)
    }

    AxisSetter {
        id: axisYsetter
        axis: axisY
        isXaxis: false
        min: 0
        max: 10
    }

    // For the sake of scaling / unit prefix (m/k/M..) we have to draw labels
    // on our own
    Repeater {
        model: axisY.tickCount
        delegate: Text {
            text: ((axisY.max - (index * axisY.perDivision)) * axisYsetter.scale).toFixed(2)

            color: ZTC.primaryTextColor
            font.pixelSize: chartView.height * 0.04
            x: onTheRight ?
                   root.graphWidth - chartView.plotArea.x + 5 :
                   (chartView.plotArea.x * 0.9) - width
            y: (chartView.plotArea.y * 0.4) + (index * (chartView.plotArea.height / (axisY.tickCount - 1)))
        }
    }
}
