pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0

Item {
    readonly property bool accuAvail: privProps.accumulatorStatus & privProps.bitAvailable
    readonly property bool accuCharging: accuAvail && (privProps.accumulatorStatus & privProps.bitCharging)
    readonly property int accumulatorChargeValue: accuAvail ? VeinEntity.getEntity("StatusModule1").INF_AccumulatorSoc : 0
    readonly property bool accuDown: accuAvail && accumulatorChargeValue <= 10

    QtObject {
        id: privProps
        readonly property int accumulatorStatus: GC.entityInitializationDone ? VeinEntity.getEntity("StatusModule1").INF_AccumulatorStatus : 0
        readonly property int bitAvailable: (1<<0)
        readonly property int bitCharging: (1<<1)
    }
}
