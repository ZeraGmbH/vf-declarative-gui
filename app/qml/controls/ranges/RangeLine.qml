import QtQuick 2.14
import QtQuick.Controls 2.14
import ModuleIntrospection 1.0
import VeinEntity 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraTranslation 1.0
import MeasChannelInfo 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0

ListView {
    id: ranges
    property var channels: []
    readonly property int channelCount: channels.length
    model: channelCount

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal

    readonly property real headerHeight: height * 0.2
    readonly property real comboHeight: height * 0.6
    readonly property real vuHeight: height * 0.15
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property int groupMemberCount: {
        let count = 0
        for(let i=0; i<channelCount; i++) {
            if(MeasChannelInfo.isGroupMember(channels[i]))
                count++
        }
        return count
    }

    readonly property bool groupingActive: MeasChannelInfo.rangeGroupingActive
    // Vein reports grouping 'on' late causing animation on load. Hack that away:
    property bool ignoreFirstGroupOnChange: groupingActive
    onGroupingActiveChanged: {
        groupinChangeAnimation.stop()
        if(groupingActive && ignoreFirstGroupOnChange) {
            groupAnimationValue = 1
            ignoreFirstGroupOnChange = false
            return
        }
        groupinChangeAnimation.from = groupAnimationValue
        groupinChangeAnimation.to = groupingActive ? 1 : 0
        groupinChangeAnimation.start()
    }
    property real groupAnimationValue: 0
    NumberAnimation {
        id: groupinChangeAnimation
        duration: 250
        target: ranges
        property: "groupAnimationValue"
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
        readonly property real leaderCurrWidth: width + (leaderMaxWidth-width)*groupAnimationValue
        readonly property real relLeaderXPos: - index * (width+spacing)
        readonly property real leaderLenLeftEnter: -relLeaderXPos

        readonly property bool groupingComboTouchesMe: leaderCurrWidth + relLeaderXPos > 0
        readonly property bool groupingComboCoversMe: leaderCurrWidth + relLeaderXPos >= width * 0.999

        Label {
            id: label
            anchors.left: parent.left
            anchors.top: parent.top
            height: headerHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignBottom
            text: Z.tr(channelsRow.channelName) + ":"
            color: FT.getColorByIndex(channelsRow.systemChannelNo)
        }

        SimpleAndCheapVu {
            anchors.top : parent.top
            height: label.height * 0.75
            anchors.left: label.right
            anchors.leftMargin: parent.width * 0.025
            anchors.right: parent.right
            horizontal: true
            // We cannot use Material colors: They often just add opacity (not worst ideea to react on dark/light)
            vuBackColor: Qt.darker("dimgray", 1.5)
            vuEndRadius: 4
            vuOvershootIndicatorColor: "yellow"

            readonly property real preScale: {
                let ret = 1.0
                // maybe I am missing something but scale from range module is 1/scale here...
                if(channelsRow.systemChannelNo <= 3)
                    ret = 1 / rangeModule["INF_PreScalingInfoGroup0"]
                else if(channelsRow.systemChannelNo <= 6)
                    ret = 1 / rangeModule["INF_PreScalingInfoGroup1"]
                return ret
            }
            // TODO:
            // * DC displays too small values: peak / sqrt2
            // * Don't hardcode overshoot
            nominal: Number(rangeModule["INF_Channel"+(channelsRow.systemChannelNo)+"ActREJ"]) * preScale
            actual: Number(rangeModule["ACT_Channel"+(channelsRow.systemChannelNo)+"Rms"])
            overshootFactor: 1.25

            MouseArea {
                anchors.fill: parent
                onClicked: rangeCombo.openDropList()
            }
        }

        VFComboBox {
            id: rangeCombo
            height: comboHeight
            anchors.left: parent.left
            width: channelsRow.isGroupLeader ? channelsRow.leaderCurrWidth : parent.width
            anchors.top: label.bottom
            pointSize: root.pointSize
            enabled: !MeasChannelInfo.rangeAutoActive
            popupKeepHorizontalSize: MeasChannelInfo.rangeGroupingActive && channelsRow.isGroupLeader
            contentMaxRows: 5
            visible: {
                if(channelsRow.isLeaderOrNotInGroup)
                    return true
                return !channelsRow.groupingComboCoversMe
            }
            opacity: {
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
