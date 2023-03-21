pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0

Item {
    readonly property string accumulatorSocText: entityInitializationDone ? VeinEntity.getEntity("StatusModule1").INF_AccumulatorSoc : "0"
    readonly property string accumulatorStatusText: entityInitializationDone ? VeinEntity.getEntity("StatusModule1").INF_AccumulatorStatus : "0"
    readonly property bool accuDown: accumulatorSocText <= 10 && accumulatorStatusText === "1"
    readonly property bool entityInitializationDone: GC.entityInitializationDone
}
