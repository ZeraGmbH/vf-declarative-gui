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

    // we need a reference to menu stack layout to move around
    property var menuStackLayout

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
        // GC.getLoggerCustomContentSets(false): ensure that gui context
        // default content does not sneak in
        var contentSets = GC.getLoggerCustomContentSets(false).split(',').filter(n => n)
        if(!contentSets.includes(addContentSet)) {
            contentSets.push(addContentSet)
        }
        GC.setLoggerCustomContentSets(contentSets.join(','))
    }
    function removeFromCustomDbContentSet(removeContentSet) {
        // GC.getLoggerCustomContentSets(false): ensure that gui context
        // default content does not sneak in
        var contentSets = GC.getLoggerCustomContentSets(false).split(',').filter(n => n)
        if(contentSets.includes(removeContentSet)) {
            contentSets = contentSets.filter(str => str !== removeContentSet)
        }
        GC.setLoggerCustomContentSets(contentSets.join(','))
    }

    readonly property real pointSize: height > 0 ? (height / 30) : 10

    ColumnLayout {
        anchors.fill: parent
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
            property bool vScrollbarVisible: buttonList.contentHeight > buttonList.height
            boundsBehavior: vScrollbarVisible ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
            clip: true
            ScrollBar.vertical: ScrollBar {
                anchors.right: parent.right
                orientation: Qt.Vertical
                policy: buttonList.vScrollbarVisible ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }
            delegate: Button {
                id: selectionButton
                // User cannot disable content for current context:
                readonly property bool unchangable: modelData === GC.getDefaultDbContentSet(GC.currentGuiContext)
                text: unchangable ?
                          "<font color='" + selectionButton.Material.accentColor + "'>" + Z.tr(modelData) + "</font>" :
                          Z.tr(modelData)
                width: buttonList.width * 3/5
                x: (buttonList.width - width) / 2
                font.pointSize: pointSize
                height: root.height > 0 ? (root.height / 6.5) : 10
                checkable: true
                checked: {
                    return GC.getLoggerCustomContentSets().includes(modelData)
                }
                onClicked: {
                    // ignore clicks on gui default content
                    if(!unchangable) {
                        if(checked) {
                            addToCustomDbContentSet(modelData)
                        }
                        else {
                            removeFromCustomDbContentSet(modelData)
                        }
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
                        // ignore checked on gui default content
                        color: (selectionButton.checked || selectionButton.unchangable) && selectionButton.enabled ?
                                   selectionButton.Material.accentColor : selectionButton.Material.buttonColor
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
    Button {
        text: Z.tr("Back")
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 8
        font.pointSize: pointSize
        onClicked: {
            menuStackLayout.pleaseCloseMe(true)
        }
    }
}
