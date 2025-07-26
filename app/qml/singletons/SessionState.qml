pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0

Item {
    property string currentSession
    onCurrentSessionChanged: {
        if(currentSession !== "") {
            var ve = VeinEntity
            var availableEntityIds = ve.getEntity("_System")["Entities"];
            if(availableEntityIds === undefined)
                availableEntityIds = [];
            var oldIdList = ve.getEntityList();

            for(var idIterator in availableEntityIds) {
                var entityId = availableEntityIds[idIterator]
                if(!oldIdList.includes(entityId))
                    ve.entitySubscribeById(entityId);
            }
        }
    }

    readonly property bool dcSession: String(currentSession).includes('-dc')
    readonly property bool emobSession: String(currentSession).includes('emob-session')
    readonly property bool refSession: String(currentSession).includes('ref-session')
}
