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
    contentHeight: pinchArea.pinchScale * height
    boundsBehavior: Flickable.OvershootBounds
    clip: true

    /* With the introduction of vertical pinch/zoom we buyed a problem: As
       soon as x is on start swiping out left to other view stopped working
       most of the times. To get around we temporary unset HorizontalFlick
       Yeah another hack and what happens if we get a neighbour view on the
       right...
       But for sake of usabiltiy we have to
    */
    Timer {
        id: flickTimer
        interval: 1000
        repeat: false
        onTriggered: {
            // set back default
            flickableDirection = Flickable.AutoFlickDirection
        }
    }
    onMovementEnded: {
        let defaultIsFine = true
        if(contentHeight > height && atXBeginning) {
            defaultIsFine = false
            flickableDirection = Flickable.VerticalFlick
            flickTimer.start()
        }
        if(defaultIsFine) {
            flickableDirection = Flickable.AutoFlickDirection
        }
    }

    ScrollBar.horizontal: ScrollBar {
        parent: root.parent
        anchors.top: root.bottom
        anchors.left: root.left
        anchors.right: root.right
        policy: ScrollBar.AlwaysOn
    }
    ScrollBar.vertical: ScrollBar {
        // Did not get y reparenting to work - but this is good enough
        /*parent: root.parent
        anchors.left: root.right
        anchors.top: root.top
        anchors.bottom: root.bottom*/
        policy: contentHeight > height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        width: 8
    }

    PinchArea {
        id: pinchArea
        anchors.fill: parent
        property real pinchScale: GC.harmonicPowerChartPinchScale
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
            GC.setHarmonicPowerChartPinchScale(newPinch)
            pinchArea.pinchScale = newPinch
        }
    }

    Repeater {
        model: 3
        Item {
            height: pinchArea.pinchScale * root.height/3
            width: root.width*2
            y: index*height

            HpwBarChart {
                id: harmonicChart
                height: parent.height
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
