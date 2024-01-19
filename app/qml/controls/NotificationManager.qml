import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import VeinEntity 1.0
import GlobalConfig 1.0
import ZeraTranslation  1.0

Item {
    id: root
    property int windowWidth
    property int windowHeight

    property var notifTextsList : []
    onNotifTextsListChanged: {
        if(Object.keys(notifTextsList).length !== 0) {
            for(let notif in notifTextsList) {
                popup.text = notifTextsList[notif]
                popup.open()
            }
        }
    }

    readonly property string notifList: GC.entityInitializationDone ? VeinEntity.getEntity("StatusModule1")["INF_ExpiringNotifList"] : ""
    onNotifListChanged:
        notifTextsList = retrieveText(notifList)

    function retrieveText(notifsList) {
        if(notifsList !== "") {
            let jsonNotifs = JSON.parse(notifsList)
            for(let jsonEntry in jsonNotifs) {
                let item = jsonNotifs[jsonEntry]
                notifTextsList.push(item)
            }
        }
        return notifTextsList
    }

    function close(msg){
        for(var i = 0; i < notifTextsList.length; i++) {
            while(notifTextsList[i].includes(msg)) {
                popup.close()
                notifTextsList.splice(i,1);
            }
        }
    }


    Popup {
        id: popup
        modal: false
        focus: false
        width: text.length + root.windowWidth
        height : text.length + root.windowHeight
        anchors.centerIn: parent
        property string text
        closePolicy: Popup.NoAutoClose
        verticalPadding: 2
        horizontalPadding: 2
        background: Rectangle {
            color: "grey"
            radius: 5
            border.color: "black"
        }

        contentItem: Item {
            id: con
            Column{
                id: col
                Label {
                    id: txt
                    padding: 2
                    text: popup.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: popup.width
                    wrapMode: Text.Wrap
                    color: "white"
                }
                Button {
                    text : "Ok"
                    onClicked: popup.close()
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
