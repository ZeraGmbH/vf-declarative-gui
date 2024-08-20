import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtCharts 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import SessionState 1.0
import JsonHelper 1.0
import GraphFunctions 1.0
import ZeraComponents 1.0
import ZeraTranslation  1.0

Item {
    id:  root
    readonly property var voltageComponents : [ "ACT_RMSPN1", "ACT_RMSPN2", "ACT_RMSPN3", "ACT_DC7"]
    readonly property var currentComponents : [ "ACT_RMSPN4", "ACT_RMSPN5", "ACT_RMSPN6", "ACT_DC8"]
    readonly property var powerComponents   : ["ACT_PQS1", "ACT_PQS2", "ACT_PQS3"]

    property var graphHeight
    property var graphWidth
    property var componentsList
    property var jsonData : VeinEntity.getEntity("Storage").StoredValues0
    onJsonDataChanged:
        loadData()

    function createLineSeries(componentsList) {
        var lineSeriesList = []
        for(var component in componentsList) {
            if(powerComponents.includes(componentsList[component]))
                var series = chartViewPower.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisXPower, axisYPower);
            if(voltageComponents.includes(componentsList[component]))
                series = chartView.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisX, axisYLeft);
            if(currentComponents.includes(componentsList[component]))
                series = chartView.createSeries(ChartView.SeriesTypeLine, componentsList[component], axisX, axisYRight);
            lineSeriesList.push(series)
        }
        var flatLineSeries = GraphFunctions.lineSeriesList
        flatLineSeries.push(lineSeriesList)
        flatLineSeries = [].concat.apply([], flatLineSeries )
        GraphFunctions.lineSeriesList = flatLineSeries
        GraphFunctions.setColors()
    }

    function removeLineSeries(componentsList) {
        var lineSeries = GraphFunctions.lineSeriesList
        for(var i= 0; i<componentsList.length; i++) {
            if(powerComponents.includes(componentsList[i])) {
                var series = chartViewPower.series(componentsList[i])
                chartViewPower.removeSeries(series)
            }
            if(voltageComponents.includes(componentsList[i])) {
                series = chartView.series(componentsList[i])
                chartView.removeSeries(series)
            }
            if(currentComponents.includes(componentsList[i])) {
                series = chartView.series(componentsList[i])
                chartView.removeSeries(series)
            }

            for(var index = 0; index < lineSeries.length; index++)
                if(lineSeries[index].name === componentsList[i])
                    GraphFunctions.lineSeriesList.splice(index, 1)
        }
    }

    function loadData() {
        var actValU = []
        var actValI = []
        var actValP = []

        GraphFunctions.prepareCharts(Object.keys(jsonData))
        var timestamps = Object.keys(jsonData).sort()
        var timestamp = timestamps[timestamps.length - 1]
        var time = jsonHelper.convertTimestampToMs(timestamp)
        var components = jsonHelper.getComponents(jsonData, time)
        for(var v = 0 ; v <components.length; v++) {
            if(voltageComponents.includes(components[v]))
                actValU.push({x: time, y: components[v]})
            if(currentComponents.includes(components[v]))
                actValI.push({x: time, y: components[v]})
            if(powerComponents.includes(components[v]))
                actValP.push({x: time, y: components[v]})
        }
        for(let vCompo in voltageComponents)
            GraphFunctions.appendLastElemt(actValU, voltageComponents[vCompo], jsonData, axisYLeft, axisX, axisXPower)
        for(let iCompo in currentComponents)
            GraphFunctions.appendLastElemt(actValI, currentComponents[iCompo], jsonData, axisYRight, axisX, axisXPower)
        for(let pCompo in powerComponents)
            GraphFunctions.appendLastElemt(actValP, powerComponents[pCompo], jsonData, axisYPower, axisX, axisXPower)
    }

    JsonHelper {
        id: jsonHelper
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: chartView.height + chartViewPower.height + phasesLoader.height
        width: root.width
        height: root.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        ScrollBar.vertical: ScrollBar {
            id: verticalScroll
            width: 8
            policy : flickable.height >= chartView.height + chartViewPower.height ?  ScrollBar.AlwaysOff : ScrollBar.AlwaysOn
        }

        PinchArea {
            id: pinchArea
            MouseArea {
                anchors.fill: parent
            }
            anchors.fill: parent
            pinch.dragAxis: Pinch.YAxis
            onPinchUpdated: {
                let pinchScale = pinch.scale * pinch.previousScale
                if (pinchScale > 1.0) {
                    chartView.height = root.graphHeight /2
                    chartViewPower.height = root.graphHeight / 2 - phasesLoader.height
                    rectHorScrollPChart.visible = true
                }
                else if (pinchScale < 1.0) {
                    chartView.height = root.graphHeight / 4 - phasesLoader.height/2
                    chartViewPower.height = root.graphHeight / 4 - phasesLoader.height/2
                    rectHorScrollPChart.visible = false
                }
            }
        }
        Item {}

        Loader {
            id: phasesLoader
            height: 32  // root.graphHeight * 0.045
            active: SessionState.emobSession && !SessionState.dcSession
            sourceComponent: RowLayout {
                id: phases
                visible: SessionState.emobSession && !SessionState.dcSession
                width: root.graphWidth
                height: parent.height

                Label {
                    id: phaseLabel
                    text: Z.tr("Select phase to display: ")
                    textFormat: Text.PlainText
                    font.pointSize: pointSize
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Label.AlignVCenter
                }
                ZCheckBox {
                    text: Z.tr("L1")
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    checked: true
                    onCheckStateChanged: {
                        var phase1Compos = ["ACT_RMSPN1", "ACT_RMSPN4", "ACT_PQS1"]
                        if(checked)
                            createLineSeries(phase1Compos)
                        else
                            removeLineSeries(phase1Compos)
                    }
                }
                ZCheckBox {
                    text: Z.tr("L2")
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    checked: true
                    onCheckStateChanged: {
                        var phase2Compos = ["ACT_RMSPN2", "ACT_RMSPN5", "ACT_PQS2"]
                        if(checked)
                            createLineSeries(phase2Compos)
                        else
                            removeLineSeries(phase2Compos)
                    }
                }
                ZCheckBox {
                    text: Z.tr("L3")
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    checked: true
                    onCheckStateChanged: {
                        var phase3Compos = ["ACT_RMSPN3", "ACT_RMSPN6", "ACT_PQS3"]
                        if(checked)
                            createLineSeries(phase3Compos)
                        else
                            removeLineSeries(phase3Compos)
                    }
                }
            }
        }
        ChartView {
            id: chartViewPower
            height: root.graphHeight/4 - phasesLoader.height/2
            anchors.rightMargin: chartView.height * 0.1
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.left: chartView.left
            anchors.right: chartView.right
            anchors.top: phasesLoader.bottom
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: false

            ValueAxis {
                id: axisYPower
                color: GC.colorUAux1
                labelsColor: GC.colorUAux1
                titleText: "P"
                titleFont.pixelSize: chartViewPower.height * 0.08
                labelsFont.pixelSize: height * 0.03
                labelFormat: "%d"
            }
            DateTimeAxis {
                id: axisXPower
                format: "hh:mm:ss"
            }
            LineSeries {
                id: lineSeriesP
                axisX: axisXPower
                axisY: axisYPower
                color: GC.colorUAux1
            }

            MouseArea {
                id: mAPower
                anchors.fill: parent
                drag.target: dragTargetPower
                drag.axis: Drag.XAxis
                property bool chartNotZoomed: true
                onDoubleClicked: {
                    if(chartNotZoomed) {
                        var zoomFactor = 2
                        var center_x = mouse.x
                        var center_y = mouse.y
                        var width_zoom = width/ zoomFactor;
                        var height_zoom = height/ zoomFactor;
                        var rect = Qt.rect(center_x-width_zoom/2, center_y - height_zoom/2, width_zoom, height_zoom)
                        chartViewPower.zoomIn(rect)
                        chartNotZoomed = false
                        mAPower.drag.axis = Drag.XAndYAxis
                    }
                    else {
                        chartViewPower.zoomReset();
                        chartNotZoomed = true
                        mAPower.drag.axis = Drag.XAxis
                    }
                }

                Item {
                   id: dragTargetPower
                   property real oldX : x
                   property real oldY : y
                   onXChanged: {
                       chartViewPower.scrollLeft( x - oldX );
                       chartView.scrollLeft( x - oldX );
                       rectHorScrollPChart.x = rectHorScrollPChart.xPosition - x
                       rectHorScrollUIChart.x = rectHorScrollUIChart.xPosition - x
                       oldX = x;
                    }
                   onYChanged: {
                       chartViewPower.scrollUp( y - oldY );
                       oldY = y;
                    }
                }
            }
        }
        Rectangle {
            width:parent.width
            height:parent.height * 0.10
            anchors.bottom: chartViewPower.bottom
            color:"transparent"

            Rectangle {
                id: rectHorScrollPChart
                property real xPosition: parent.width - margin
                property real margin: {
                    let lineSeriesList = GraphFunctions.lineSeriesList
                    var points = []
                    for(var i = 0; i<lineSeriesList.length; i++) {
                        points.push(lineSeriesList[i].count)
                    }
                    var max = Math.max(...points)
                    return ((flickable.width - max) * 1.02)
                }
                visible: false
                anchors.bottom : parent.bottom
                color: "dimgray"
                height: 9
                width: margin
                onWidthChanged: {
                    rectHorScrollPChart.x = xPosition
                }
            }
        }
        ChartView {
            id: chartView
            height: root.graphHeight/4 - phasesLoader.height/2
            width: root.graphWidth * 1.08
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: chartViewPower.bottom
            anchors.topMargin: 0
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: false

            ValueAxis {
                id: axisYLeft
                color: GC.colorUAux1
                labelsColor: GC.colorUAux1
                titleText: "U"
                titleFont.pixelSize: chartView.height * 0.08
                labelsFont.pixelSize: height * 0.03
                labelFormat: "%d"
            }
            ValueAxis {
                id: axisYRight
                color: GC.colorIAux1
                labelsColor: GC.colorIAux1
                titleText: "I"
                titleFont.pixelSize: chartView.height * 0.08
                labelsFont.pixelSize: height * 0.03
                labelFormat: "%d"
            }
            DateTimeAxis {
                id: axisX
                format: "hh:mm:ss"
            }

            LineSeries {
                id: lineSeriesU
                axisX: axisX
                axisY: axisYLeft
                color: GC.colorUAux1
            }
            LineSeries {
                id: lineSeriesI
                axisX: axisX
                axisYRight: axisYRight
                color: GC.colorIAux1
            }

            MouseArea {
                id: mA
                anchors.fill: parent
                drag.target: dragTarget
                drag.axis: Drag.XAxis
                property bool chartNotZoomed: true
                onDoubleClicked: {
                    if(chartNotZoomed) {
                        var zoomFactor = 2
                        var center_x = mouse.x
                        var center_y = mouse.y
                        var width_zoom = width/ zoomFactor;
                        var height_zoom = height/ zoomFactor;
                        var rect = Qt.rect(center_x-width_zoom/2, center_y - height_zoom/2, width_zoom, height_zoom)
                        chartView.zoomIn(rect)
                        chartNotZoomed = false
                        mA.drag.axis = Drag.XAndYAxis
                    }
                    else {
                        chartView.zoomReset();
                        chartNotZoomed = true
                        mA.drag.axis = Drag.XAxis
                    }
                }

                Item {
                   id: dragTarget
                   property real oldX : x
                   property real oldY : y
                   onXChanged: {
                       chartView.scrollLeft( x - oldX );
                       chartViewPower.scrollLeft( x - oldX );
                       rectHorScrollPChart.x = rectHorScrollPChart.xPosition - x
                       rectHorScrollUIChart.x = rectHorScrollUIChart.xPosition - x
                       oldX = x;
                    }
                   onYChanged: {
                       chartView.scrollUp( y - oldY );
                       oldY = y;
                    }
                }
            }
        }
        Rectangle{
            width:parent.width
            height: parent.height * 0.10
            anchors.bottom: chartView.bottom
            color:"transparent"

            Rectangle {
                id: rectHorScrollUIChart
                property real xPosition: parent.width - margin
                property real margin: {
                    let lineSeriesList = GraphFunctions.lineSeriesList
                    var points = []
                    for(var i = 0; i<lineSeriesList.length; i++) {
                        points.push(lineSeriesList[i].count)
                    }
                    var max = Math.max(...points)
                    return ((flickable.width - max) * 1.02)
                }
                anchors.bottom : parent.bottom
                color: "dimgray"
                height: 9
                width: margin
                onWidthChanged: {
                    rectHorScrollUIChart.x = xPosition
                }
            }
        }
    }
    Component.onCompleted: {
        createLineSeries(componentsList)
    }
}
