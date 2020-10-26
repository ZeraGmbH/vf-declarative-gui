import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12
import QtQuick.Layouts 1.12
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraFa 1.0

Item {
    id: root

    readonly property var availableSingleContentSets: {
        // We want to have our buttons sorted
        var contentSets = []
        for(var guiContextEnumVal in GC.guiContextEnum) {
            var contentSet = GC.getDefaultDbContentSet(GC.guiContextEnum[guiContextEnumVal])
            if(contentSet !== "" && !contentSets.includes(contentSet)) {
                contentSets.push(contentSet)
            }
        }
        return contentSets
    }

    function addToCustomDbContentSet(addContentSet) {
        var contentSets = GC.getLoggerCustomContentSets().split(',').filter(n => n)
        if(!contentSets.includes(addContentSet)) {
            contentSets.push(addContentSet)
        }
        GC.setLoggerCustomContentSets(contentSets.join(','))
    }
    function removeFromCustomDbContentSet(removeContentSet) {
        var contentSets = GC.getLoggerCustomContentSets().split(',').filter(n => n)
        if(contentSets.includes(removeContentSet)) {
            contentSets = contentSets.filter(str => str !== removeContentSet)
        }
        GC.setLoggerCustomContentSets(contentSets.join(','))
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
                id: selectionButton
                text: Z.tr(modelData)
                width: buttonList.width
                font.pointSize: root.height > 0 ? (root.height / 30) : 10
                height: root.height > 0 ? (root.height / 6.5) : 10
                checkable: true
                checked: {
                    return GC.getLoggerCustomContentSets().includes(modelData)
                }
                onClicked: {
                    if(checked) {
                        addToCustomDbContentSet(modelData)
                    }
                    else {
                        removeFromCustomDbContentSet(modelData)
                    }
                }
                // The default Material colors for check-bar cannot be changed so re-implement
                // (=steal code from qtquickcontrols2 / src/imports/controls/material/Button.qml)
                background: Rectangle {
                    implicitWidth: 64
                    implicitHeight: selectionButton.Material.buttonHeight
                    radius: 2
                    color: !selectionButton.enabled ? selectionButton.Material.buttonDisabledColor :
                            selectionButton.highlighted ? selectionButton.Material.highlightedButtonColor : selectionButton.Material.buttonColor

                    // The layer is disabled when the button color is transparent so you can do
                    // Material.background: "transparent" and get a proper flat button without needing
                    // to set Material.elevation as well
                    layer.enabled: selectionButton.enabled && selectionButton.Material.buttonColor.a > 0
                    layer.effect: ElevationEffect {
                        elevation: selectionButton.Material.elevation
                    }
                    Rectangle {
                        y: parent.height - 6
                        width: parent.width
                        height: 6
                        radius: 4
                        clip: true
                        visible: selectionButton.checkable && (!selectionButton.highlighted || selectionButton.flat)
                        color: selectionButton.checked && selectionButton.enabled ? selectionButton.Material.accentColor : selectionButton.Material.buttonColor
                    }
                    Ripple {
                        clipRadius: 2
                        width: parent.width
                        height: selectionButton.height-12
                        pressed: selectionButton.pressed
                        anchor: selectionButton
                        active: selectionButton.down || selectionButton.visualFocus || selectionButton.hovered
                        color: selectionButton.flat && selectionButton.highlighted ? selectionButton.Material.highlightedRippleColor : selectionButton.Material.rippleColor
                    }
                }
            }
        }
    }
}
