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
    readonly property int animationDuration: 250
    property bool ignoreFirstGroupOnChange: groupingActive
    onGroupingActiveChanged: {
        groupinChangeAnimationUp.stop()
        if(groupingActive && ignoreFirstGroupOnChange) {
            groupAnimationValue = 1
            ignoreFirstGroupOnChange = false
            return
        }
        groupinChangeAnimationUp.from = groupAnimationValue
        groupinChangeAnimationUp.to = groupingActive ? 1 : 0
        groupinChangeAnimationUp.start()
    }
    NumberAnimation {
        id: groupinChangeAnimationUp
        duration: animationDuration
        target: ranges
        property: "groupAnimationValue"
        easing.type: Easing.OutCubic
    }
    property real groupAnimationValue: 0

    delegate: Item {
        id: channelsRow
        width: (ranges.width - (channelCount-1)*spacing) / channelCount
        height: ranges.height
        readonly property int systemChannelNo: channels[index] // 1-based!!
        readonly property string channelName: MeasChannelInfo.channelNames[systemChannelNo-1]
        readonly property string rangeComponentName: "PAR_Channel"+parseInt(systemChannelNo)+"Range"
        readonly property bool isGroupLeader: systemChannelNo === MeasChannelInfo.voltageGroupLeaderIdx || systemChannelNo === MeasChannelInfo.currentGroupLeaderIdx
        readonly property real leaderWidth: width * groupMemberCount + (groupMemberCount-1)*spacing

        Label {
            id: label
            anchors.left: parent.left
            anchors.top: parent.top
            height: headerHeight
            font.pointSize: pointSize
            verticalAlignment: Label.AlignBottom
            text: Z.tr(channelsRow.channelName) + ":"
            color: FT.getColorByIndex(channelsRow.systemChannelNo, MeasChannelInfo.rangeGroupingActive)
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
            nominal: Math.SQRT2 * Number(rangeModule["INF_Channel"+(channelsRow.systemChannelNo)+"ActREJ"]) * preScale
            actual: Number(rangeModule["ACT_Channel"+(channelsRow.systemChannelNo)+"Peak"])
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
            width: channelsRow.isGroupLeader ? parent.width+(channelsRow.leaderWidth-parent.width)*groupAnimationValue : parent.width
            anchors.top: label.bottom
            pointSize: root.pointSize
            enabled: !MeasChannelInfo.rangeAutoActive
            popupKeepHorizontalSize: MeasChannelInfo.rangeGroupingActive && channelsRow.isGroupLeader
            contentMaxRows: 5
            visible: {
                if(channelsRow.isGroupLeader) // leader
                    return true
                if(!MeasChannelInfo.isGroupMember(channelsRow.systemChannelNo)) // AUX
                    return true
                return !MeasChannelInfo.rangeGroupingActive && !groupinChangeAnimationUp.running
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
