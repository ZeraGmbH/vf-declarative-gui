import QtQuick 2.14
import QtQuick.Controls 2.14
import ModuleIntrospection 1.0
import VeinEntity 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import MeasChannelInfo 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

ListView {
    id: ranges
    property var channels: []
    model: channels.length

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal

    // remaining height up to 1 -> vu
    readonly property real headerHeight: height * 0.2
    readonly property real comboHeight: height * 0.6

    delegate: Item {
        id: channelsRow
        width: (ranges.width - (channels.length-1)*spacing) / channels.length
        height: ranges.height
        readonly property int channelNo: channels[index]
        readonly property string parChannelRange: "PAR_Channel"+parseInt(channelNo)+"Range"

        Label {
            id: label
            anchors.left: parent.left
            anchors.top: parent.top
            height: headerHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignBottom
            text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo[parChannelRange].ChannelName) + ":"
            color: FT.getColorByIndex(channelsRow.channelNo, MeasChannelInfo.rangeGroupingActive)
        }
        VFComboBox {
            id: rangeCombo
            height: comboHeight
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: label.bottom

            // To flash once only we set model only on content change
            // because metadata is JSON and that reports change on all channels
            flashOnContentChange: true
            readonly property var validationData: ModuleIntrospection.rangeIntrospection.ComponentInfo[parChannelRange].Validation.Data
            property string validdationDataStr
            onValidationDataChanged: {
                let newValidationData = JSON.stringify(validationData)
                if(validdationDataStr !== newValidationData) {
                    validdationDataStr = newValidationData
                    model = validationData
                }
            }

            arrayMode: true
            entity: VeinEntity.getEntity("RangeModule1")
            controlPropertyName: parChannelRange
            contentMaxRows: 5
            centerVertical: true
            enabled: true // TODO
        }
        SimpleAndCheapVu {
            anchors.top : rangeCombo.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            horizontal: true

            readonly property real preScale: {
                if(channelsRow.channelNo <= 3)
                    return MeasChannelInfo.rangeModule[`INF_PreScalingInfoGroup0`];
                else if(channelsRow.channelNo <= 6)
                    return MeasChannelInfo.rangeModule[`INF_PreScalingInfoGroup1`];
                return 1;
            }
            // TODO:
            // * DC displays too small values: peak / sqrt2
            // * Don't hardcode overshoot
            nominal: Math.SQRT2 * Number(MeasChannelInfo.rangeModule["INF_Channel"+(channelsRow.channelNo)+"ActREJ"]) * preScale
            actual: Number(MeasChannelInfo.rangeModule["ACT_Channel"+(channelsRow.channelNo)+"Peak"])
            overshootFactor: 1.25

            MouseArea {
                anchors.fill: parent
                onClicked: rangeCombo.openDropList()
            }
        }
    }
}
