import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import SlowMachineSettingsHelper 1.0
import FontAwesomeQml 1.0
import "../settings"

ListView {
    id: root

    readonly property QtObject fftModule: VeinEntity.getEntity("FFTModule1")
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property QtObject thdnModule: VeinEntity.getEntity("THDNModule1")
    readonly property int fftCount: GC.showAuxPhases ? ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount : Math.min(6, ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount);
    readonly property int scrollbarWidth: root.contentHeight > root.height ? 8 : 0

    clip: true
    snapMode: ListView.SnapToItem
    boundsBehavior: Flickable.OvershootBounds
    contentHeight: pinchArea.pinchScale * height/3 * Math.ceil(fftCount/2)

    readonly property real pointSize: height * 0.02
    readonly property int thdnToHorizontalCenterOffset: 60 // chart's legend has fixed distance
    ZButton {
        id: settingsButton
        z: 1
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: -4
        anchors.bottomMargin: -4
        width: thdnToHorizontalCenterOffset - 15
        height: 18 + root.height * 0.05
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

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOn
        snapMode: ScrollBar.SnapOnRelease
        stepSize: 3 / (GC.fftChartsPinchScale * (root.count-1))
        size: root.visibleArea.heightRatio
        width: scrollbarWidth
    }

    PinchArea {
        id: pinchArea
        anchors.fill: parent
        property real pinchScale: GC.fftChartsPinchScale
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
            GC.setFftChartsPinchScale(newPinch)
            pinchArea.pinchScale = newPinch
        }
    }

    model: Math.ceil(fftCount/2)
    // convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
    readonly property var leftChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<fftCount; ++channelNum) {
            var unit = ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(channelNum+1)].Unit;
            if(unit === "V") {//UL1..UL3 +UN
                retVal.push(channelNum)
            }
        }
        return retVal;
    }
    readonly property var rightChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<fftCount; ++channelNum) {
            var unit = ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(channelNum+1)].Unit;
            if(unit === "A") {//IL1..IL3 +IN
                retVal.push(channelNum);
            }
        }
        return retVal;
    }
    readonly property string strThdn: Z.tr("THDN:") + " "
    delegate: Item {
        id: chartItem
        height: pinchArea.pinchScale * root.height/3
        width: root.width - scrollbarWidth
        y: index*height
        Text {
            id: thdnTextU
            anchors.left: parent.left
            anchors.leftMargin: thdnToHorizontalCenterOffset
            //index starts with 1
            readonly property string componentName: String("ACT_THDN%1").arg(leftChannels[index]+1);
            readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
            text: strThdn + FT.formatNumber(thdnModule[componentName]) + unit
            font.pointSize: pointSize
            color: CS.currentColorTable[leftChannels[index]]
        }
        Text {
            id: thdnTextI
            anchors.right: parent.right
            anchors.rightMargin: thdnToHorizontalCenterOffset
            //index starts with 1
            readonly property string componentName: String("ACT_THDN%1").arg(rightChannels[index]+1);
            readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
            text: strThdn + FT.formatNumber(thdnModule[componentName]) + unit
            font.pointSize: pointSize
            color: CS.currentColorTable[rightChannels[index]]
        }

        FftBarChart {
            id: harmonicChart
            anchors.fill: parent
            anchors.topMargin: thdnTextU.height

            rightAxisEnabled: true

            color: Material.backgroundColor
            borderColor: Material.backgroundColor
            legendEnabled: false
            bottomLabelsEnabled: true
            logScaleLeftAxis: false
            logScaleRightAxis: false
            colorLeftAxis: CS.currentColorTable[leftChannels[index]]
            colorRightAxis: CS.currentColorTable[rightChannels[index]]

            leftValue: fftModule[String("ACT_FFT%1").arg(leftChannels[index]+1)]
            rightValue: fftModule[String("ACT_FFT%1").arg(rightChannels[index]+1)]

            maxValueLeftAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(leftChannels[index]+1)] * 1.5
            minValueLeftAxis: 0
            maxValueRightAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(rightChannels[index]+1)] * 1.5
            minValueRightAxis: 0
            textColor: Material.primaryTextColor

            titleLeftAxis: Z.tr(ModuleIntrospection.fftIntrospection.ComponentInfo[String("ACT_FFT%1").arg(leftChannels[index]+1)].ChannelName)
            titleRightAxis: Z.tr(ModuleIntrospection.fftIntrospection.ComponentInfo[String("ACT_FFT%1").arg(rightChannels[index]+1)].ChannelName)
        }
    }
}
