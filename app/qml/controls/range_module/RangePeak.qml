import QtQuick 2.0
import QtCharts 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import QwtChart 1.0
import ZeraTranslation  1.0

Item {
    id: root

    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    property bool bottomLabels: true
    property bool rangeGrouping: false

    BarChart {
        id: peakChart

        property var peakBars: []

        anchors.fill: parent
        anchors.bottomMargin: 16
        color: Material.backgroundColor
        leftAxisBars: peakBars
        leftAxisLogScale: false
        legendEnabled: false
        bottomLabelsEnabled: root.bottomLabels
        leftScaleTransform: "%1%"

        leftAxisMinValue: 0
        leftAxisMaxValue: 125
        textColor: Material.primaryTextColor
        Repeater {
            model: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
            delegate: Bar {
                title: ModuleIntrospection.rangeIntrospection.ComponentInfo["ACT_Channel"+(index+1)+"Peak"].ChannelName
                value: relativeValue
                //toFixed(2) because of visual screen flickering of bars, bug in Qwt?
                //Math.SQRT2 because peak value are compared with rms rejection
                property real preScale: {
                    if(index<3){
                        return root.rangeModule[`INF_PreScalingInfoGroup0`];
                    }else if(index<6){
                        return root.rangeModule[`INF_PreScalingInfoGroup1`];
                    }else{
                        return 1;
                    }
                }

                property real relativeValue: Number((100 * rangeModule["ACT_Channel"+(index+1)+"Peak"] / (Math.SQRT2 * rangeModule["INF_Channel"+(index+1)+"ActREJ"])).toFixed(2))*preScale
                color: FT.getColorByIndex(index+1, root.rangeGrouping)
                Component.onCompleted: {
                    peakChart.peakBars.push(this);
                    peakChart.peakBarsChanged();
                }
            }
        }
    }
}
