pragma Singleton
import QtQuick 2.0
import GlobalConfig 1.0
import VeinEntity 1.0
import ModuleIntrospection 1.0

Item {
    readonly property int channelCountTotal: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    // TODO:
    // * We assume all here - range module should get more supportive...
    // * COM5003 REF
    readonly property var voltageChannelIds: GC.entityInitializationDone ? channelCountTotal >= 7 ? [1,2,3,7] : [1,2,3] : []
    readonly property var currentChannelIds: GC.entityInitializationDone ? channelCountTotal >= 8 ? [4,5,6,8] : [4,5,6] : []
}
