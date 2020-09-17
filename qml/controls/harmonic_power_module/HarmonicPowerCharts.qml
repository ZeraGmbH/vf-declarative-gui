import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP

Flickable {
    id: root

    readonly property QtObject power3Module: VeinEntity.getEntity("Power3Module1");
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1");

    contentWidth: width*2
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    ScrollBar.horizontal: ScrollBar {
        id: hBar
        anchors.bottom: root.bottom
        anchors.left: root.left
        anchors.right: root.right
        orientation: Qt.Horizontal
        height: 12
        policy: root.contentWidth > root.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    Repeater {
        model: 3
        Item {
            height: root.height/3 - 4
            width: root.width*2
            y: index*height

            HpwBarChart {
                id: harmonicChart
                height: root.height/3
                width: parent.width

                color: Material.backgroundColor
                borderColor: Material.backgroundColor
                legendEnabled: false
                function getTitleLabel() {
                    var retVal=[];

                    retVal.push(ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPP%1").arg(index+1)].ChannelName)
                    retVal.push(ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPQ%1").arg(index+1)].ChannelName)
                    retVal.push(ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPS%1").arg(index+1)].ChannelName)

                    return retVal.join("  ");
                }

                titleLeftAxis: getTitleLabel();
                bottomLabelsEnabled: true
                colorLeftAxis: GC.systemColorByIndex(index+1)

                pValueList: power3Module[String("ACT_HPP%1").arg(index+1)];
                qValueList: power3Module[String("ACT_HPQ%1").arg(index+1)];
                sValueList: power3Module[String("ACT_HPS%1").arg(index+1)];

                maxValueLeftAxis: rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+1)] * rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+4)]
                minValueLeftAxis: -rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+1)] * rangeModule[String("INF_Channel%1ActOVLREJ").arg(index+4)]
                textColor: Material.primaryTextColor
                //titleLeftAxis: ModuleIntrospection.p3m1Introspection.ComponentInfo[String("ACT_HPW%1").arg(index+1)].ChannelName
            }
        }
    }
}
