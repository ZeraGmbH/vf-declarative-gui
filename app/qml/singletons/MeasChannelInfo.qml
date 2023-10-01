pragma Singleton
import QtQuick 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ModuleIntrospection 1.0

Item {
    readonly property int channelCountTotal: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

    // TODO:
    // * We assume all here - range module should get more supportive...
    // * COM5003 REF
    readonly property var voltageChannelIds: GC.entityInitializationDone ? channelCountTotal >= 7 ? [1,2,3,7] : [1,2,3] : []
    readonly property var currentChannelIds: GC.entityInitializationDone ? channelCountTotal >= 8 ? [4,5,6,8] : [4,5,6] : []

    readonly property bool rangeGroupingActive: GC.entityInitializationDone ? rangeModule.PAR_ChannelGrouping : false
    readonly property bool rangeAutoActive: GC.entityInitializationDone ? rangeModule.PAR_RangeAutomatic : false
}