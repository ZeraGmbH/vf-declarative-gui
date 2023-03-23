import QtQuick 2.14
import VeinEntity 1.0

ListView {
    id: root
    // setters
    property var entity
    property real visibleHeight

    height: privProps.canChangePhases ? visibleHeight : 0
    QtObject {
        id: privProps
        readonly property bool canChangePhases: VeinEntity.getEntity(entity).ACT_CanChangePhaseMask
        readonly property int measSysCount: String(VeinEntity.getEntity(entity).PAR_MeasModePhaseSelect).length
        readonly property int maxMeasSysCount: VeinEntity.getEntity(entity).ACT_MaxMeasSysCount // common 3 / 2wire 1
    }
}
