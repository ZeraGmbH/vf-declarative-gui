import QtQuick 2.14
import QtQuick.Controls 2.14
import ModuleIntrospection 1.0
import VeinEntity 1.0
import FunctionTools 1.0
import ZeraTranslation 1.0
import MeasChannelInfo 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

ListView {
    id: ranges
    property var channels: []
    model: channels.length

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal

    readonly property real headerHeight: height * 0.2
    readonly property real comboHeight: height * 0.6
    readonly property real vuHeight: height * 0.1
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

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
            pointSize: root.pointSize
            enabled: !MeasChannelInfo.rangeAutoActive
            contentMaxRows: 5

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
            entity: rangeModule
            controlPropertyName: parChannelRange
        }
        SimpleAndCheapVu {
            anchors.top : rangeCombo.bottom
            height: vuHeight
            anchors.left: parent.left
            anchors.right: parent.right
            horizontal: true

            readonly property real preScale: {
                let ret = 1.0
                // maybe I am missing something but scale from range module is 1/scale here...
                if(channelsRow.channelNo <= 3)
                    ret = 1 / rangeModule["INF_PreScalingInfoGroup0"]
                else if(channelsRow.channelNo <= 6)
                    ret = 1 / rangeModule["INF_PreScalingInfoGroup1"]
                return ret
            }
            // TODO:
            // * DC displays too small values: peak / sqrt2
            // * Don't hardcode overshoot
            nominal: Math.SQRT2 * Number(rangeModule["INF_Channel"+(channelsRow.channelNo)+"ActREJ"]) * preScale
            actual: Number(rangeModule["ACT_Channel"+(channelsRow.channelNo)+"Peak"])
            overshootFactor: 1.25

            MouseArea {
                anchors.fill: parent
                onClicked: rangeCombo.openDropList()
            }
        }
    }
}
