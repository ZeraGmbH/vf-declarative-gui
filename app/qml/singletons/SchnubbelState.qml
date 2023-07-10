pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0
import GlobalConfig 1.0

Item {
    readonly property bool inserted: GC.entityInitializationDone ? VeinEntity.getEntity("StatusModule1").INF_Schnubbel === 1 : false
}
