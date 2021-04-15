import QtQuick 2.5
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import AppStarterForWebGLSingleton 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraFa 1.0
import ZeraLocale 1.0
import "qrc:/qml/controls" as CCMP

Rectangle {
    property real result;
    onResultChanged: {
        refreshLineData();
    }
    property int rating
    property real maxValue
    onMaxValueChanged: {
        refreshLineData();
    }
    property real minValue
    onMinValueChanged: {
        refreshLineData();
    }
    readonly property real minMaxOffset: Math.max(Math.abs(maxValue), Math.abs(minValue)) *0.5

    Component.onCompleted: refreshLineData();
    function refreshLineData() {
        resultLine.clear();
        resultLine.append(0, result);
        resultLine.append(1, result);
        upperErrorMarginLine.clear();
        upperErrorMarginLine.append(0, maxValue);
        upperErrorMarginLine.append(1, maxValue);
        lowerErrorMarginLine.clear();
        lowerErrorMarginLine.append(0, minValue);
        lowerErrorMarginLine.append(1, minValue);
    }

    border.color: Material.dividerColor
    color: rating !== 0 ? "transparent" : "#11FF0000";

    ChartView {
        z: parent.z-1
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: parent.height
        anchors.verticalCenter: parent.verticalCenter

        antialiasing: false
        backgroundColor: Material.backgroundColor
        legend.visible:false

        margins.bottom:0
        margins.left:0
        margins.top:0
        margins.right:0

        localizeNumbers: true
        locale: ZLocale.locale

        ValueAxis {
            id: xAxis
            min: 0
            max: 1
            labelsVisible: false
            gridVisible: true
            tickCount: 2
            minorGridVisible: false
            gridLineColor: Material.frameColor
            color: "transparent"
        }
        ValueAxis {
            id: yAxisLeft

            max: maxValue!==0 ? maxValue+minMaxOffset : (minMaxOffset!==0 ? minMaxOffset : 0.5)
            min: minValue!==0 ? minValue-minMaxOffset : (minMaxOffset!==0 ? -minMaxOffset : -0.5)

            tickCount: 7

            minorGridLineColor: Material.dividerColor
            gridLineColor: Material.frameColor
            labelsColor: Material.primaryTextColor
            color: Material.frameColor
        }
        LineSeries {
            id: resultLine
            axisX: xAxis
            axisY: yAxisLeft
            color: (minValue<=result && result<=maxValue) ? "lawngreen" : "red";
            width: 3
            useOpenGL: true
        }
        LineSeries {
            id: upperErrorMarginLine
            axisX: xAxis
            axisY: yAxisLeft
            color: "red";
            style: Qt.DashLine
            width: 1
            useOpenGL: true
        }
        LineSeries {
            id: lowerErrorMarginLine
            axisX: xAxis
            axisY: yAxisLeft
            color: "red";
            style: Qt.DashLine
            width: 1
            useOpenGL: true
        }
    }
}
