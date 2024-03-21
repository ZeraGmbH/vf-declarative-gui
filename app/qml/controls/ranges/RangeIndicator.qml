import QtQuick 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import MeasChannelInfo 1.0
import FunctionTools 1.0
import FontAwesomeQml 1.0
import ZeraTranslation  1.0
import ZeraComponents 1.0

Loader {
    id: invisibleRoot
    active: false
    property bool highlighted: false
    property real pointSize
    property real smallPointSize: pointSize*0.6
    sourceComponent: Component {
        Item {
            id: root
            width: invisibleRoot.width
            height: invisibleRoot.height

            readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
            readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
            property int contentWidth: root.width/(root.channelCount/2)*0.9

            signal sigOverloadHintClicked();

            RangeIndicatorLine {
                id: voltageList
                model: MeasChannelInfo.voltageChannelIds
                anchors.left: parent.left
                anchors.leftMargin: root.contentWidth*0.1
                anchors.right: parent.right
                height: root.height/2

                contentWidth: root.contentWidth
                highlighted: invisibleRoot.highlighted
                groupTrailerIdx: MeasChannelInfo.voltageGroupTrailerIdx
            }

            RangeIndicatorLine {
                id: currentList
                model: MeasChannelInfo.currentChannelIds
                anchors.left: parent.left
                anchors.leftMargin: root.contentWidth*0.1
                anchors.right: parent.right
                height: root.height/2
                anchors.top: voltageList.bottom

                contentWidth: root.contentWidth
                highlighted: invisibleRoot.highlighted
                groupTrailerIdx: MeasChannelInfo.currentGroupTrailerIdx

            }
            Item {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: height*1.3

                Label {
                    anchors.centerIn: parent
                    font.pointSize: pointSize
                    property bool overload: rangeModule.PAR_Overload === 1
                    property bool preScale: rangeModule.PAR_PreScalingEnabledGroup0 || rangeModule.PAR_PreScalingEnabledGroup1
                    text: {
                        if(overload)
                            return FAQ.fa_exclamation_triangle
                        if(preScale)
                            return FAQ.fa_anchor
                        return FAQ.fa_exclamation_triangle
                    }
                    opacity: (overload || preScale) ? 1.0 : 0.2
                    color:  {
                        if(overload)
                            return Material.color(Material.Yellow)
                        if(preScale)
                            return Qt.lighter(Material.color(Material.Amber))
                        return Material.color(Material.Grey)
                    }
                }
            }
        }
    }
}


