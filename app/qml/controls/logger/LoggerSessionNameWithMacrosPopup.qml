import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0

Popup {
    id: root
    parent: Overlay.overlay
    width: parent.width
    height: parent.height - GC.vkeyboardHeight
    modal: !Qt.inputMethod.visible
    closePolicy: Popup.NoAutoClose

    readonly property real rowHeight: parent.height/4
    readonly property real fontScale: 0.1
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10

    signal sessionNameSelected(string newSessionName)

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            preview.text = GC.loggerSessionNameReplace(textFieldSessionNameWithMacros.text)
        }
    }

    onAboutToShow: {
        // Do not bind by design
        textFieldSessionNameWithMacros.text = Z.tr("Session ") + '$YEAR/$MONTH/$DAY'
        // Intended to be late so textFieldSessionNameWithMacros selects properly
        root.focus = true
        textFieldSessionNameWithMacros.focus = true
    }

    ColumnLayout {
        id: selectionColumn
        anchors.fill: parent
        RowLayout { // Standard name
            Label {
                text: Z.tr("Current name:");
                font.pointSize: root.pointSize
            }
            TextField {
                id: textFieldSessionNameWithMacros
                Layout.fillWidth: true;
                bottomPadding: GC.standardTextBottomMargin
                inputMethodHints: Qt.ImhNoAutoUppercase
                horizontalAlignment: Text.AlignRight
                font.pointSize: root.pointSize

                Keys.onEscapePressed: {
                    focus = false
                }
                onAccepted: {
                    focus = false
                }
                onFocusChanged: {
                    if(focus) {
                        selectAll()
                    }
                }
            }
        }
        RowLayout { // Preview
            id: previewRow
            Label {
                id: previewLabel
                text: Z.tr("Preview:");
                font.pointSize: root.pointSize
            }
            Item {
                // spacer
                Layout.fillWidth: true
            }
            Label { // For sake of seconds text is set by timer
                id: preview
                text: GC.loggerSessionNameReplace(textFieldSessionNameWithMacros.text)
                horizontalAlignment: Text.AlignRight
                font.pointSize: root.pointSize
                elide: Text.ElideRight
                Layout.maximumWidth: selectionColumn.width - // Ugly: suggestions welcome...
                                     previewLabel.width - 10
            }
        }
        RowLayout { // macro buttons
            id: macroButtonsRow
            function addToSessionName(textToAdd) {
                var selStart = textFieldSessionNameWithMacros.selectionStart
                var selEnd = textFieldSessionNameWithMacros.selectionEnd
                // selected: replace
                if(selEnd - selStart > 0) {
                    var newText = textFieldSessionNameWithMacros.text.substring(0, selStart) +
                            textToAdd +
                            textFieldSessionNameWithMacros.text.substring(selEnd, textFieldSessionNameWithMacros.text.length)
                    textFieldSessionNameWithMacros.text = newText
                }
                // otherwise: insert at cursor position
                else {
                    textFieldSessionNameWithMacros.insert(textFieldSessionNameWithMacros.cursorPosition, textToAdd);
                }
            }

            Button {
                text: "$CUST_ID"
                visible: VeinEntity.hasEntity("CustomerData")
                focusPolicy: Qt.NoFocus
                font.pointSize: root.pointSize
                onPressed: {
                    macroButtonsRow.addToSessionName(text)
                }
            }
            Button {
                text: "$CUST_NUM"
                visible: VeinEntity.hasEntity("CustomerData")
                focusPolicy: Qt.NoFocus
                font.pointSize: root.pointSize
                onPressed: {
                    macroButtonsRow.addToSessionName(text)
                }
            }
            Item { // spacer
                visible: VeinEntity.hasEntity("CustomerData")
                Layout.minimumWidth: 1
            }
            Button {
                text: "$YEAR"
                focusPolicy: Qt.NoFocus
                font.pointSize: root.pointSize
                onPressed: {
                    macroButtonsRow.addToSessionName(text)
                }
            }
            Button {
                text: "$MONTH"
                focusPolicy: Qt.NoFocus
                font.pointSize: root.pointSize
                onPressed: {
                    macroButtonsRow.addToSessionName(text)
                }
            }
            Button {
                text: "$DAY"
                focusPolicy: Qt.NoFocus
                font.pointSize: root.pointSize
                onPressed: {
                    macroButtonsRow.addToSessionName(text)
                }
            }
            Item {
                // spacer
                Layout.minimumWidth: 1
            }
            Button {
                text: "$TIME"
                focusPolicy: Qt.NoFocus
                font.pointSize: root.pointSize
                onPressed: {
                    macroButtonsRow.addToSessionName(text)
                }
            }
            Button {
                text: "$SECONDS"
                focusPolicy: Qt.NoFocus
                font.pointSize: root.pointSize
                onPressed: {
                    macroButtonsRow.addToSessionName(text)
                }
            }
        }
        RowLayout { // Cancel / OK buttons
            id: cancelOKRow
            Item {
                id: spacerItem
                Layout.fillWidth: true
            }
            Button {
                id: cancelButton
                text: Z.tr("Cancel")
                font.pointSize: root.pointSize
                onClicked: {
                    root.close()
                }
            }
            Button {
                id: okButton
                text: Z.tr("OK")
                font.pointSize: root.pointSize
                Layout.minimumWidth: cancelButton.width
                onClicked: {
                    sessionNameSelected(GC.loggerSessionNameReplace(textFieldSessionNameWithMacros.text))
                    root.close()
                }
            }
        }
    }
}
