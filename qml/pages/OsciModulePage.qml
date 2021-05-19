import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraGlueLogic 1.0
import ZeraLocale 1.0

Item {
    id: root

    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1");
    readonly property real plotWidth: width-8;
    readonly property int channelCount: GC.showAuxPhases ? ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount : Math.min(6, ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount)

    //convention that channels are numbered by unit was broken, so do some $%!7 to get the right data
    readonly property var dataModels: [ZGL.OSCIP1Model, ZGL.OSCIP2Model, ZGL.OSCIP3Model, ZGL.OSCIP1Model, ZGL.OSCIP2Model, ZGL.OSCIP3Model,  ZGL.OSCIPNModel, ZGL.OSCIPNModel]

    //convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
    readonly property var leftChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            var unit = ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+parseInt(channelNum+1)].Unit;
            if(unit === "V") { //UL1..UL3 +UN
                retVal.push(channelNum)
            }
        }
        return retVal;
    }

    readonly property var rightChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            var unit = ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+parseInt(channelNum+1)].Unit;
            if(unit === "A") { //IL1..IL3 +IN
                retVal.push(channelNum)
            }
        }
        return retVal;
    }
    Keys.forwardTo: [lvOsci]

    ListView {
        id: lvOsci
        anchors.fill: parent
        boundsBehavior: Flickable.OvershootBounds
        model: Math.ceil(channelCount/2)
        clip: true
        snapMode: ListView.SnapToItem

        ScrollBar.vertical: ScrollBar {
            policy: lvOsci.contentHeight > lvOsci.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            width: 8
            snapMode: ScrollBar.SnapOnRelease
            stepSize: 3 / (GC.osciPinchScale*(lvOsci.count-1))
            size: lvOsci.visibleArea.heightRatio
        }

        PinchArea {
            id: pinchArea
            anchors.fill: parent
            property real pinchScale: GC.osciPinchScale
            onPinchUpdated: {
                // pinch.minimumScale / pinch.maximumScale do not work
                // here so do the calculations necessary here
                let scaleFactor = pinch.scale * pinch.previousScale
                let newPinch = pinchArea.pinchScale * scaleFactor
                if(newPinch > 3.0) {
                    newPinch = 3.0
                }
                else if(newPinch < 1.0) {
                    newPinch = 1.0
                }
                GC.setOsciPinchScale(newPinch)
                pinchArea.pinchScale = newPinch
            }
        }

        delegate: Item {
            height: pinchArea.pinchScale * root.height/3
            width: root.plotWidth
            ChartView {
                anchors.left: parent.left
                anchors.right: parent.right
                // lots of trials - hope they won't change ChartView too much in future releases..
                height: (parent.height + Math.sqrt(parent.height) * 10) / 1.4
                anchors.verticalCenter: parent.verticalCenter
                margins.top: 15
                margins.bottom: 0

                antialiasing: false
                backgroundColor: Material.backgroundColor
                legend.visible:false
                legend.width: 0
                legend.height: 0
                localizeNumbers: true
                locale: ZLocale.locale

                ValueAxis {
                    id: xAxis
                    min: 0
                    max: 127
                    labelsVisible: false
                    gridVisible: true
                    tickCount: 2
                    minorGridVisible: false
                    gridLineColor: Material.frameColor
                }
                ValueAxis {
                    id: yAxisLeft
                    visible: root.rangeModule["PAR_Channel"+(leftChannels[index]+1)+"Range"] !== "--"
                    //120% possible rejection * sqrt(2) rounded up to avoid crooked numbers
                    property real minMax: root.rangeModule["INF_Channel"+(leftChannels[index]+1)+"ActREJ"]*2.0

                    min: -minMax
                    max: minMax
                    tickCount: pinchArea.pinchScale < 2 ? 3 : 5

                    minorGridLineColor: Material.dividerColor
                    gridLineColor: Material.frameColor
                    labelsColor: FT.getColorByIndex(leftChannels[index]+1)
                    color: FT.getColorByIndex(leftChannels[index]+1)
                }
                ValueAxis {
                    id: yAxisRight
                    visible: root.rangeModule["PAR_Channel"+(rightChannels[index]+1)+"Range"] !== "--"
                    //120% possible rejection * sqrt(2) rounded up to avoid crooked numbers
                    property real minMax: root.rangeModule["INF_Channel"+(rightChannels[index]+1)+"ActREJ"]*2.0

                    min: -minMax
                    max: minMax
                    tickCount: pinchArea.pinchScale < 2 ? 3 : 5

                    minorGridLineColor: Material.dividerColor
                    gridLineColor: Material.frameColor
                    labelsColor: FT.getColorByIndex(rightChannels[index]+1)
                    color: FT.getColorByIndex(rightChannels[index]+1)
                }

                LineSeries {
                    id: leftSeries
                    axisX: xAxis
                    axisY: yAxisLeft
                    color: FT.getColorByIndex(leftChannels[index]+1);
                    width: 2
                    useOpenGL: true
                }

                LineSeries {
                    id: rightSeries
                    axisX: xAxis
                    axisYRight: yAxisRight
                    color: FT.getColorByIndex(rightChannels[index]+1);
                    width: 2
                    useOpenGL: true
                }
                HXYModelMapper {
                    model: dataModels[leftChannels[index]]
                    series: leftSeries
                    xRow: 0
                    yRow: 1
                }
                HXYModelMapper {
                    model: dataModels[rightChannels[index]]
                    series: rightSeries
                    xRow: 0
                    yRow: 2
                }
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                rotation: -90
                text: ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+(leftChannels[index]+1)].ChannelName;
                color: FT.getColorByIndex(leftChannels[index]+1);
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                rotation: 90
                text: ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+(rightChannels[index]+1)].ChannelName;
                color: FT.getColorByIndex(rightChannels[index]+1);
            }
        }
    }
}
