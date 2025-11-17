import QtQuick 2.14
import VeinEntity 1.0
import GlobalConfig 1.0

Item {
    readonly property bool accuAvail: privProps.accumulatorStatus & privProps.bitmaskAvailable
    readonly property bool accuCharging: accuAvail && (privProps.accumulatorStatus & privProps.bitmaskCharging)
    readonly property bool accuLowWarning: accuAvail && (privProps.accumulatorStatus & privProps.bitmaskLowWarning)
    readonly property bool accuLowAlert: accuAvail && (privProps.accumulatorStatus & privProps.bitmaskLowAlert)
    readonly property int accumulatorChargeValue: accuAvail ? VeinEntity.getEntity("StatusModule1").INF_AccumulatorSoc : 0
    readonly property bool accuDown: accuAvail && accumulatorChargeValue <= 10

    QtObject {
        id: privProps
        readonly property int accumulatorStatus: GC.entityInitializationDone ? VeinEntity.getEntity("StatusModule1").INF_AccumulatorStatus : 0
        readonly property int bitmaskAvailable: (1<<0)
        readonly property int bitmaskCharging: (1<<1)
        readonly property int bitmaskLowWarning: (1<<2)
        readonly property int bitmaskLowAlert: (1<<3)
    }
}
