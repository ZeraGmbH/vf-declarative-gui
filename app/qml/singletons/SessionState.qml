pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0

Item {
    property string currentSession
    onCurrentSessionChanged: {
        if(currentSession !== "") {
            var availableEntityIds = VeinEntity.getEntity("_System")["Entities"];
            if(availableEntityIds === undefined)
                availableEntityIds = [];
            var oldIdList = VeinEntity.getEntityList();

            for(var idIterator in availableEntityIds) {
                let entityId = availableEntityIds[idIterator]
                if(!oldIdList.includes(entityId))
                    VeinEntity.entitySubscribeById(entityId);
            }
        }
    }

    readonly property bool dcSession: String(currentSession).includes('-dc')
    readonly property bool emobSession: String(currentSession).includes('emob-session')
    readonly property bool refSession: String(currentSession).includes('ref-session')
}
