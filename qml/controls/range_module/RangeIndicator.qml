import QtQuick 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraFa 1.1
import ZeraTranslation  1.0


Loader {
    id: invisibleRoot
    active: false
    property bool highlighted: false
    property real pointSize: 18
    sourceComponent: Component {
        Item {
            id: root

            readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
            // convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
            readonly property var upperChannels: {
                var retVal = [];
                for(var channelNum=0; channelNum<channelCount; ++channelNum) {
                    var name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
                    var unit = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].Unit;
                    if(name.startsWith("REF")) {
                        if(channelNum<3) { // REF1..REF3
                            retVal.push(channelNum);
                        }
                    }
                    else if(unit === "V") { // UL1..UL3 +UAUX
                        retVal.push(channelNum)
                    }
                }
                return retVal;
            }

            readonly property var lowerChannels: {
                var retVal = [];
                for(var channelNum=0; channelNum<channelCount; ++channelNum) {
                    var name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
                    var unit = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].Unit;
                    if(name.startsWith("REF")) {
                        if(channelNum>=3) { // REF4..REF6
                            retVal.push(channelNum);
                        }
                    }
                    else if(unit === "A") { // IL1..IL3 +IAUX
                        retVal.push(channelNum)
                    }
                }
                return retVal;
            }

            readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
            property int contentWidth: root.width/(root.channelCount/2)*0.9
            readonly property int rangeGrouping: rangeModule.PAR_ChannelGrouping

            signal sigOverloadHintClicked();

            width: invisibleRoot.width
            height: invisibleRoot.height

            Rectangle {
                anchors.fill: parent
                color: Material.background
                opacity: 0.2
            }

            Item {
                anchors.right: parent.right
                anchors.rightMargin: -4
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: height*1.3

                Label {
                    anchors.centerIn: parent
                    font.family: FA.regular
                    font.pointSize: pointSize
                    text: {
                        if(overload){
                            return FA.icons.fa_exclamation_triangle;
                        }else if(preScale){
                            return FA.icons.fa_percent;
                        }else{
                            return FA.icons.fa_exclamation_triangle;
                        }
                    }
                    property bool overload: rangeModule.PAR_Overload === 1
                    property bool preScale: rangeModule.PAR_PreScalingEnabledGroup0 || rangeModule.PAR_PreScalingEnabledGroup1
                    opacity: (overload || preScale) ? 1.0 : 0.2
                    color:  {
                        if(overload){
                            return Material.color(Material.Yellow);
                        }else if(preScale){
                            return Material.color(Material.Amber);
                        }else{
                            return Material.color(Material.Grey);
                        }
                    }
                }
            }

            ListView {
                id: voltageList
                model: root.upperChannels
                anchors.left: parent.left
                anchors.leftMargin: root.contentWidth*0.1
                anchors.right: parent.right
                interactive: false

                height: root.height/2

                boundsBehavior: ListView.StopAtBounds
                orientation: Qt.Horizontal
                spacing: root.contentWidth*0.1

                delegate: Item {
                    width: root.contentWidth*0.9
                    height: root.height/2
                    Label {
                        width: parent.width*0.5
                        font.pixelSize: parent.height/1.3
                        fontSizeMode: Label.HorizontalFit
                        anchors.verticalCenter: parent.verticalCenter
                        text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].ChannelName) + ": "
                        color: FT.getColorByIndex(modelData+1, rangeGrouping)
                        font.bold: true
                    }
                    Label {
                        width: parent.width*0.5
                        anchors.right: parent.right
                        horizontalAlignment: Label.AlignRight
                        font.pixelSize: parent.height/1.3
                        fontSizeMode: Label.HorizontalFit
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.rangeModule["PAR_Channel"+parseInt(modelData+1)+"Range"]
                        color: invisibleRoot.highlighted ? Material.accentColor : Material.primaryTextColor
                    }
                }
            }
            ListView {
                model: root.lowerChannels
                anchors.left: parent.left
                anchors.leftMargin: root.contentWidth*0.1
                anchors.right: parent.right
                height: root.height/2
                anchors.top: voltageList.bottom
                interactive: false

                boundsBehavior: ListView.StopAtBounds
                orientation: Qt.Horizontal
                spacing: root.contentWidth*0.1

                delegate: Item {
                    width: root.contentWidth*0.9
                    height: root.height/2
                    Label {
                        width: parent.width*0.5
                        font.pixelSize: parent.height/1.3
                        fontSizeMode: Label.HorizontalFit
                        anchors.verticalCenter: parent.verticalCenter
                        text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].ChannelName) + ": "
                        color: FT.getColorByIndex(modelData+1, rangeGrouping)
                        font.bold: true
                    }
                    Label {
                        width: parent.width*0.5
                        anchors.right: parent.right
                        horizontalAlignment: Label.AlignRight
                        font.pixelSize: parent.height/1.3
                        fontSizeMode: Label.HorizontalFit
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.rangeModule["PAR_Channel"+parseInt(modelData+1)+"Range"]
                        color: invisibleRoot.highlighted ? Material.accentColor : Material.primaryTextColor
                    }
                }
            }
        }
    }
}


