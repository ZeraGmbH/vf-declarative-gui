pragma Singleton
import QtQuick 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ModuleIntrospection 1.0

Item {
    id: measChannelInfo
    readonly property int channelCountTotal: GC.entityInitializationDone ? ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount : 0
    readonly property var channelNames: {
        let names = []
        for(let systemChannelNo=1; systemChannelNo<=channelCountTotal; systemChannelNo++) { // systemChannelNo is 1-based !!!
            let channelRangeComponent = "PAR_Channel"+parseInt(systemChannelNo)+"Range"
            let name = ModuleIntrospection.rangeIntrospection.ComponentInfo[channelRangeComponent].ChannelName
            names.push(name)
        }
        return names
    }

    // Assumptions - range module should get more supportive...
    readonly property var voltageChannelIds: channelCountTotal >= 7 ? [1,2,3,7] : [1,2,3]
    readonly property var currentChannelIds: channelCountTotal >= 8 ? [4,5,6,8] : [4,5,6]
    // Hard codings - RangeLine is not prepared for other than first group member
    readonly property int voltageGroupLeaderIdx: voltageChannelIds.length > 0 ? voltageChannelIds[0] : 0
    readonly property int currentGroupLeaderIdx: currentChannelIds.length > 0 ? currentChannelIds[0] : 0

    readonly property bool rangeGroupingActive: GC.entityInitializationDone ? VeinEntity.getEntity("RangeModule1").PAR_ChannelGrouping : false
    readonly property int rangeGroupCount: GC.entityInitializationDone ? ModuleIntrospection.rangeIntrospection.ModuleInfo.GroupCount : 0
    readonly property var rangeGroupVoltage: rangeGroupCount >= 1 ? ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup1 : []
    readonly property var rangeGroupCurrent: rangeGroupCount >= 2 ? ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup2 : []
    readonly property var rangeGroupRef: rangeGroupCount >= 3 ? ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup3 : []
    function isGroupMember(systemChannelNo) { // systemChannelNo is 1-based !!!
        if(rangeGroupVoltage.indexOf(channelNames[systemChannelNo-1]) >= 0)
            return true
        if(rangeGroupCurrent.indexOf(channelNames[systemChannelNo-1]) >= 0)
            return true
        if(rangeGroupRef.indexOf(channelNames[systemChannelNo-1]) >= 0)
            return true
        return false
    }

    readonly property bool rangeAutoActive: GC.entityInitializationDone ? VeinEntity.getEntity("RangeModule1").PAR_RangeAutomatic : false

    onRangeGroupingActiveChanged: {
        groupinChangeAnimation.stop()
        groupinChangeAnimation.from = groupAnimationValue
        groupinChangeAnimation.to = rangeGroupingActive ? 1 : 0
        groupinChangeAnimation.start()
    }
    property real groupAnimationValue: 0
    NumberAnimation {
        id: groupinChangeAnimation
        duration: 250
        target: measChannelInfo
        property: "groupAnimationValue"
    }

}
