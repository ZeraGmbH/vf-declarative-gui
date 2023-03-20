pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0

Item {
    property string accumulatorSocText: "0"
    property string accumulatorStatusText: "0"
    property bool accuDown: accumulatorSocText <= 10 && accumulatorStatusText === "1"
    property bool entityInitializationDone: GC.entityInitializationDone
    onEntityInitializationDoneChanged: {
        if(entityInitializationDone) {
            accumulatorSocText = Qt.binding(function() {
                return VeinEntity.getEntity("StatusModule1").INF_AccumulatorSoc;
            });
            accumulatorStatusText = Qt.binding(function() {
                return VeinEntity.getEntity("StatusModule1").INF_AccumulatorStatus;
            });
        }
    }
}
