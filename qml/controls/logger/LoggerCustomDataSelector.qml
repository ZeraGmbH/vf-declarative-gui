import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraFa 1.0

Item {
    id: root

    readonly property var availableSingleContentSets: {
        // We want to have our buttons sorted
        var contentSets = []
        for(var guiContext in GC.guiContextEnum) {
            var contentSet = GC.getDefaultDbContentSet(GC.guiContextEnum[guiContext])
            if(!contentSets.includes(contentSet)) {
                contentSets.push(contentSet)
            }
        }
        return contentSets
    }

    function addToCustomDbContentSet(addContentSet) {
        var contentSet = GC.getLoggerCustomContentSets().split(',').filter(n => n)
        if(!contentSet.includes(addContentSet)) {
            contentSet.push(addContentSet)
        }
        GC.setLoggerCustomContentSets(contentSet.join(','))
    }
    function removeFromCustomDbContentSet(removeContentSet) {
        var contentSet = GC.getLoggerCustomContentSets().split(',').filter(n => n)
        if(contentSet.includes(removeContentSet)) {
            contentSet = contentSet.filter(str => str !== removeContentSet)
        }
        GC.setLoggerCustomContentSets(contentSet.join(','))
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: parent.width / 6
        anchors.rightMargin: parent.width / 6
        Label { // Header
            id: captionLabel
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Z.tr("Select custom data contents")
            font.pointSize: root.height > 0 ? (root.height / 25) : 10
        }
        ListView {
            id: buttonList
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: availableSingleContentSets
            clip: true
            delegate: Button {
                text: Z.tr(modelData)
                width: buttonList.width
                font.pointSize: root.height > 0 ? (root.height / 30) : 10
                height: root.height > 0 ? (root.height / 6.5) : 10
                checked: checkable // we do not want to see a bar when not checked -> checkable is working var
                checkable: {
                    return GC.getLoggerCustomContentSets().includes(modelData)
                }
                onClicked: {
                    checkable = !checkable
                    if(checkable) {
                        addToCustomDbContentSet(modelData)
                    }
                    else {
                        removeFromCustomDbContentSet(modelData)
                    }
                }
            }
        }
    }
}
