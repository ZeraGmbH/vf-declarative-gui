import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import TableEventDistributor 1.0
import ZeraLocale 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import SlowMachineSettingsHelper 1.0
import FontAwesomeQml 1.0
import "../controls/settings"

Item {
    id: root

    Button {
        id: settingsButton
        z: 1
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: -4
        anchors.bottomMargin: -4
        width: 45 // chart's legend has fixed distance
        height: width * 0.4 + root.height * 0.05
        text: FAQ.fa_cogs
        font.pointSize: height * 0.325
        visible: settingsPopup.settingsRowCount > 0
        onClicked: settingsPopup.open()
    }

    InViewSettingsPopup {
        id: settingsPopup
        settingsRowCount: (hasAux ? 1 : 0)
        Column {
            anchors.topMargin: settingsPopup.rowHeight/2
            anchors.fill: parent
            InViewSettingsCheckShowAux {
                width: settingsPopup.width
                enabledHeight: settingsPopup.inPopupRowHeight
            }
        }
    }

    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1");
    readonly property int channelCount: GC.showAuxPhases ? ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount : Math.min(6, ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount)

    // convention that channels are numbered by unit was broken, so do some $%!7 to get the right data
    readonly property var dataModels: [ZGL.OSCIP1Model, ZGL.OSCIP2Model, ZGL.OSCIP3Model, ZGL.OSCIP1Model, ZGL.OSCIP2Model, ZGL.OSCIP3Model,  ZGL.OSCIPNModel, ZGL.OSCIPNModel]

    // convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
    readonly property var leftChannels: {
        let retVal = [];
        for (let channelNum=0; channelNum<channelCount; ++channelNum) {
            let unit = ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+parseInt(channelNum+1)].Unit;
            if(unit === "V") //UL1..UL3 +UN
                retVal.push(channelNum)
        }
        return retVal;
    }
    readonly property var rightChannels: {
        let retVal = [];
        for (let channelNum=0; channelNum<channelCount; ++channelNum) {
            let unit = ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+parseInt(channelNum+1)].Unit;
            if (unit === "A") //IL1..IL3 +IN
                retVal.push(channelNum)
        }
        return retVal;
    }

    readonly property int leftRightOffset: 15
    readonly property real plotWidth: width-2 * leftRightOffset;
    readonly property real unitPointSize: 14
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
            x: leftRightOffset
            height: pinchArea.pinchScale * root.height/3
            width: root.plotWidth
            ChartView {
                anchors.fill: parent
                // lots of trials - hope they won't change ChartView too much in future releases..
                anchors.topMargin: -27
                anchors.bottomMargin: -45
                antialiasing: false
                backgroundColor: "transparent" // workaround overlap on small pinch
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

                    minorGridLineColor: CS.dividerColor
                    gridLineColor: Material.frameColor
                    labelsColor: CS.getColorByIndexWithReference(leftChannels[index]+1)
                    color: CS.getColorByIndexWithReference(leftChannels[index]+1)
                }
                ValueAxis {
                    id: yAxisRight
                    visible: root.rangeModule["PAR_Channel"+(rightChannels[index]+1)+"Range"] !== "--"
                    //120% possible rejection * sqrt(2) rounded up to avoid crooked numbers
                    property real minMax: root.rangeModule["INF_Channel"+(rightChannels[index]+1)+"ActREJ"]*2.0

                    min: -minMax
                    max: minMax
                    tickCount: pinchArea.pinchScale < 2 ? 3 : 5

                    minorGridLineColor: CS.dividerColor
                    gridLineColor: Material.frameColor
                    labelsColor: CS.getColorByIndexWithReference(rightChannels[index]+1)
                    color: CS.getColorByIndexWithReference(rightChannels[index]+1)
                }

                LineSeries {
                    id: leftSeries
                    axisX: xAxis
                    axisY: yAxisLeft
                    color: CS.getColorByIndexWithReference(leftChannels[index]+1);
                    width: 2
                    useOpenGL: true
                }

                LineSeries {
                    id: rightSeries
                    axisX: xAxis
                    axisYRight: yAxisRight
                    color: CS.getColorByIndexWithReference(rightChannels[index]+1);
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
                text: Z.tr(ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+(leftChannels[index]+1)].ChannelName)
                font.pointSize: unitPointSize
                font.bold: true
                color: CS.getColorByIndexWithReference(leftChannels[index]+1);
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                rotation: 90
                text: Z.tr(ModuleIntrospection.osciIntrospection.ComponentInfo["ACT_OSCI"+(rightChannels[index]+1)].ChannelName)
                font.pointSize: unitPointSize
                font.bold: true
                color: CS.getColorByIndexWithReference(rightChannels[index]+1);
            }
        }
    }
}
