pragma Singleton
import QtQuick 2.0
import VeinEntity 1.0

Item {
    property string currentSession
    onCurrentSessionChanged: {
        if(currentSession !== "") {
            var availableEntityIds = VeinEntity.getEntity("_System")["Entities"];

            var oldIdList = VeinEntity.getEntityList();
            for(var oldIdIterator in oldIdList)
                VeinEntity.entityUnsubscribeById(oldIdList[oldIdIterator]);

            if(availableEntityIds === undefined)
                availableEntityIds = [0];

            for(var newIdIterator in availableEntityIds)
                VeinEntity.entitySubscribeById(availableEntityIds[newIdIterator]);
        }
    }

    readonly property bool dcSession: String(currentSession).includes('-dc')
    readonly property bool emobSession: String(currentSession).includes('emob-session')
    readonly property bool refSession: String(currentSession).includes('ref-session')
}
