import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ModuleIntrospection 1.0
import ZeraTranslation 1.0

ListView {
    id: root

    readonly property QtObject fftModule: VeinEntity.getEntity("FFTModule1")
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property QtObject thdnModule: VeinEntity.getEntity("THDNModule1")
    readonly property int fftCount: GC.showAuxPhases ? ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount : Math.min(6, ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount);
    //convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
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

    clip: true
    snapMode: ListView.SnapToItem
    boundsBehavior: Flickable.OvershootBounds
    contentHeight: pinchArea.pinchScale * height/3 * Math.ceil(fftCount/2)
    ScrollBar.vertical: ScrollBar {
        policy: root.contentHeight > root.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        snapMode: ScrollBar.SnapOnRelease
        stepSize: 3 / (GC.fftChartsPinchScale * (root.count-1))
        size: root.visibleArea.heightRatio
        width: 8
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
    delegate: Item {
        height: pinchArea.pinchScale * root.height/3
        width: root.width-8
        y: index*height
        readonly property string strThdn: Z.tr("THDN:") + " "
        Text {
            id: thdnTextU
            //index starts with 1
            readonly property string componentName: String("ACT_THDN%1").arg(leftChannels[index]+1);
            readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
            text: strThdn + FT.formatNumber(thdnModule[componentName]) + unit
            font.pointSize: root.height/50
            color: GC.currentColorTable[leftChannels[index]]
        }
        Text {
            id: thdnTextI
            //index starts with 1
            readonly property string componentName: String("ACT_THDN%1").arg(rightChannels[index]+1);
            readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
            text: strThdn + FT.formatNumber(thdnModule[componentName]) + unit
            anchors.right: parent.right
            anchors.rightMargin: 8
            font.pointSize: root.height/50
            color: GC.currentColorTable[rightChannels[index]]
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
            colorLeftAxis: GC.currentColorTable[leftChannels[index]]
            colorRightAxis: GC.currentColorTable[rightChannels[index]]

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
