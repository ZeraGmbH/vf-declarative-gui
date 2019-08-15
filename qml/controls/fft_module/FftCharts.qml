import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraTranslation 1.0
import "qrc:/qml/controls" as CCMP

Flickable {
  id: root

  readonly property QtObject fftModule: VeinEntity.getEntity("FFTModule1")
  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
  readonly property QtObject thdnModule: VeinEntity.getEntity("THDNModule1")
  readonly property int fftCount: ModuleIntrospection.fftIntrospection.ModuleInfo.FFTCount
  //convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
  readonly property var leftChannels: {
    var retVal = [];
    for(var channelNum=0; channelNum<fftCount; ++channelNum)
    {
      var unit = ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(channelNum+1)].Unit;
      if(unit === "V")//UL1..UL3 +UN
      {
        retVal.push(channelNum)
      }
    }
    return retVal;
  }
  readonly property var rightChannels: {
    var retVal = [];
    for(var channelNum=0; channelNum<fftCount; ++channelNum)
    {
      var unit = ModuleIntrospection.fftIntrospection.ComponentInfo["ACT_FFT"+parseInt(channelNum+1)].Unit;
      if(unit === "A")//IL1..IL3 +IN
      {
        retVal.push(channelNum);
      }
    }
    return retVal;
  }

  clip: true
  boundsBehavior: Flickable.StopAtBounds
  contentHeight: height/3 * Math.ceil(fftCount/2)
  ScrollBar.vertical: ScrollBar {
    Component.onCompleted: {
      if(QT_VERSION >= 0x050900) //policy was added after 5.7
      {
        policy = Qt.binding(function (){return root.contentHeight > root.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff; });
      }
    }
  }

  Repeater {
    model: Math.ceil(fftCount/2)
    Item {
      height: root.height/3
      width: root.width-16
      y: index*height
      readonly property string strThdn: ZTR["THDN:"]
      Label {
        id: thdnLabelU
        //index starts with 1
        readonly property string componentName: String("ACT_THDN%1").arg(leftChannels[index]+1);
        readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
        text: strThdn +" "+ GC.formatNumber(thdnModule[componentName]) + unit
        color: GC.systemColorByIndex(leftChannels[index]+1)
      }
      Label {
        id: thdnLabelI
        //index starts with 1
        readonly property string componentName: String("ACT_THDN%1").arg(rightChannels[index]+1);
        readonly property string unit: ModuleIntrospection.thdnIntrospection.ComponentInfo[componentName].Unit
        text: strThdn +" "+ GC.formatNumber(thdnModule[componentName]) + unit
        anchors.right: parent.right
        anchors.rightMargin: 8
        color: GC.systemColorByIndex(rightChannels[index]+1)
      }

      FftBarChart {
        id: harmonicChart
        anchors.fill: parent
        anchors.topMargin: thdnLabelU.height

        rightAxisEnabled: true

        color: Material.backgroundColor
        borderColor: Material.backgroundColor
        legendEnabled: false
        bottomLabelsEnabled: true
        logScaleLeftAxis: false
        logScaleRightAxis: false
        colorLeftAxis: GC.systemColorByIndex(leftChannels[index]+1)
        colorRightAxis: GC.systemColorByIndex(rightChannels[index]+1)

        leftValue: fftModule[String("ACT_FFT%1").arg(leftChannels[index]+1)]
        rightValue: fftModule[String("ACT_FFT%1").arg(rightChannels[index]+1)]

        maxValueLeftAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(leftChannels[index]+1)] * 1.5
        minValueLeftAxis: 0
        maxValueRightAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(rightChannels[index]+1)] * 1.5
        minValueRightAxis: 0
        textColor: Material.primaryTextColor

        titleLeftAxis: ModuleIntrospection.fftIntrospection.ComponentInfo[String("ACT_FFT%1").arg(leftChannels[index]+1)].ChannelName
        titleRightAxis: ModuleIntrospection.fftIntrospection.ComponentInfo[String("ACT_FFT%1").arg(rightChannels[index]+1)].ChannelName
      }
    }
  }
}
