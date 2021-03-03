import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import QwtChart 1.0
import GlobalConfig 1.0
import ModuleIntrospection 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP

Item {
    id: root
    readonly property bool hasVertScroll: pinchArea.pinchScale > 1.0
    readonly property QtObject power3Module: VeinEntity.getEntity("Power3Module1");
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1");

    ScrollBar {
        id: vBar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        orientation: Qt.Vertical
        width: 8
        policy: hasVertScroll ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }
    ScrollBar {
        id: hBar
        anchors.top: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        orientation: Qt.Horizontal
        height: 8
        policy: ScrollBar.AlwaysOn
    }

    Flickable {
        id: fftFlickable
        anchors.fill: parent
        anchors.bottomMargin: hBar.height
        anchors.rightMargin: hasVertScroll ? vBar.width : 0
        contentWidth: width*2
        contentHeight: pinchArea.pinchScale * height
        boundsBehavior: Flickable.OvershootBounds
        clip: true

        ScrollBar.horizontal: hBar
        ScrollBar.vertical: vBar
        // The following dance is necessary to improve swiping into next tab
        // when being zoomed by pinch
        onMovementEnded: {
            // re-enable atXEnd once we get right neighbour
            helperMouseArea.enabled = hasVertScroll && atXBeginning // || atXEnd
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
    MouseArea {
        id: helperMouseArea
        anchors.fill: parent
        anchors.rightMargin: hasVertScroll ? vBar.width : 0
        anchors.bottomMargin: hBar.height
        enabled: hasVertScroll
        drag.axis: Drag.XAxis
        property real oldXPos: 0
        onPositionChanged: {
            // can we swipe contents left?
            if(mouse.x > oldXPos && fftFlickable.atXEnd) {
                enabled = false
            }
            // can we swipe contents right?
            if(mouse.x < oldXPos && fftFlickable.atXBeginning) {
                enabled = false
            }
            oldXPos = mouse.x
        }
    }
}
