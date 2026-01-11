import QtQuick 2.14
import QtQuick.Controls 2.14
import ModuleIntrospection 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ColorSettings 1.0
import ZeraTranslation 1.0
import MeasChannelInfo 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

ListView {
    id: ranges
    property var channels: []
    property int rangeComboRows: 5
    readonly property int channelCount: channels.length
    model: channelCount

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal

    readonly property real headerHeight: height * 0.2
    readonly property real headerComboMargin: headerHeight * 0.3
    readonly property real comboHeight: height * 0.6
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property int groupMemberCount: {
        let count = 0
        for(let i=0; i<channelCount; i++) {
            if(MeasChannelInfo.isGroupMember(channels[i]))
                count++
        }
        return count
    }

    delegate: Item {
        id: channelsRow
        width: (ranges.width - (channelCount-1)*spacing) / channelCount
        height: ranges.height
        readonly property int systemChannelNo: channels[index] // 1-based!!
        readonly property string channelName: MeasChannelInfo.channelNames[systemChannelNo-1]
        readonly property string rangeComponentName: "PAR_Channel"+parseInt(systemChannelNo)+"Range"
        readonly property bool isGroupLeader: systemChannelNo === MeasChannelInfo.voltageGroupLeaderIdx || systemChannelNo === MeasChannelInfo.currentGroupLeaderIdx
        readonly property bool isLeaderOrNotInGroup: isGroupLeader || !MeasChannelInfo.isGroupMember(channelsRow.systemChannelNo)
        readonly property real leaderMaxWidth: width * groupMemberCount + (groupMemberCount-1)*spacing
        readonly property real leaderCurrWidth: width + (leaderMaxWidth-width) * MeasChannelInfo.groupAnimationValue
        readonly property real relLeaderXPos: - index * (width+spacing)
        readonly property real leaderLenLeftEnter: -relLeaderXPos

        readonly property bool groupingComboCoversMe: leaderCurrWidth + relLeaderXPos >= width * 0.999

        Label {
            id: label
            anchors { left: parent.left; top: parent.top }
            height: headerHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignVCenter
            text: Z.tr(channelsRow.channelName)
            color: CS.getColorByIndexWithReference(channelsRow.systemChannelNo)
        }

        SacVuUnsigned {
            anchors { top : parent.top; left: label.right; leftMargin: parent.width * 0.025; right: parent.right }
            height: headerHeight
            horizontal: true
            // TODO:
            // * DC displays too small values: peak / sqrt2
            nominal: Number(rangeModule["INF_Channel"+(channelsRow.systemChannelNo)+"ActREJ"])
            actual: Number(rangeModule["ACT_Channel"+(channelsRow.systemChannelNo)+"Rms"])
            overshootFactor: Number(rangeModule["INF_Channel"+(channelsRow.systemChannelNo)+"ActOVLREJ"]) / nominal

            MouseArea {
                anchors.fill: parent
                onClicked: rangeCombo.openDropList()
            }
        }

        VFComboBox {
            id: rangeCombo
            height: comboHeight
            anchors { left: parent.left; top: label.bottom; topMargin: headerComboMargin }
            width: channelsRow.isGroupLeader ? channelsRow.leaderCurrWidth : parent.width
            pointSize: root.pointSize
            enabled: !MeasChannelInfo.rangeAutoActive
            popupKeepHorizontalSize: MeasChannelInfo.rangeGroupingActive && channelsRow.isGroupLeader
            contentMaxRows: rangeComboRows
            visible: {
                if(channelsRow.isLeaderOrNotInGroup)
                    return true
                return !channelsRow.groupingComboCoversMe
            }
            opacity: {
                let opacityDefault = 1
                if(channelsRow.isLeaderOrNotInGroup || width === 0.0)
                    return opacityDefault
                let relOverlap = (channelsRow.leaderCurrWidth-channelsRow.leaderLenLeftEnter) / width
                let opa = 1-relOverlap
                if(opa < 0.0)
                    opa = 0.0
                if(opa > opacityDefault)
                    opa = opacityDefault
                return opa
            }

            // TODO: Get this to vf-qmllibs
            // To flash once only we set model only on content change
            // because metadata is JSON and that reports change on all channels
            flashOnContentChange: true
            readonly property var validationData: ModuleIntrospection.rangeIntrospection.ComponentInfo[channelsRow.rangeComponentName].Validation.Data
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
            controlPropertyName: channelsRow.rangeComponentName
        }
    }
}
