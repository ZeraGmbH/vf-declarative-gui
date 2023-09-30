import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Controls.Material 2.14
import ModuleIntrospection 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0

ListView {
    id: ranges
    property var channels: []
    model: channels.length

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal
    spacing: frameMargin

    readonly property real relativeHeaderHeight: 0.5
    readonly property real relativeComboHeight: 1.2
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

    delegate: Item {
        id: channelsRow
        width: (ranges.width - (channels.length-1)*frameMargin) / channels.length
        height: ranges.height
        readonly property int channelNo: channels[index]
        readonly property string parChannelRange: "PAR_Channel"+parseInt(channelNo)+"Range"

        Label {
            id: label
            anchors.left: parent.left
            anchors.top: parent.top
            height: rowHeight * relativeHeaderHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignBottom
            text: Z.tr(ModuleIntrospection.rangeIntrospection.ComponentInfo[parChannelRange].ChannelName) + ":"
            color: FT.getColorByIndex(channelsRow.channelNo, root.groupingActive)
        }
        VFComboBox {
            id: rangeCombo
            height: rowHeight * relativeComboHeight
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
            id: vu
            anchors.top : rangeCombo.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            property real preScale: {
                if(channelNo <= 3)
                    return root.rangeModule[`INF_PreScalingInfoGroup0`];
                else if(channelNo <= 6)
                    return root.rangeModule[`INF_PreScalingInfoGroup1`];
                return 1;
            }

            horizontal: true
            nominal: 100
            overshootFactor: 1.25
            // This code was taken from RangePeak/relativeValue and adapted to different model
            // TODO:
            // * DC displays too small values: peak / sqrt2
            // * Don't hardcode overshoot
            //toFixed(2) because of visual screen flickering of bars, bug in Qwt?
            //Math.SQRT2 because peak value are compared with rms rejection
            actual: Number((100 * rangeModule["ACT_Channel"+(channelsRow.channelNo)+"Peak"] /
                            (Math.SQRT2 * rangeModule["INF_Channel"+(channelsRow.channelNo)+"ActREJ"])).toFixed(2))*preScale
        }
    }
}
