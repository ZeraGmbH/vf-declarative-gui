import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import ZeraFa 1.0

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

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            preview.text = GC.loggerSessionNameReplace(textFieldSessionNameDefault.text)
        }
    }

    onAboutToShow: {
        // Do not bind by design
        textFieldSessionNameDefault.text = GC.loggerSessionNameDefault
        // Intended to be late so textFieldSessionNameDefault selects properly
        root.focus = true
        textFieldSessionNameDefault.focus = true
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
                id: textFieldSessionNameDefault
                Layout.fillWidth: true;
                bottomPadding: GC.standardTextBottomMargin
                inputMethodHints: Qt.ImhNoAutoUppercase
                horizontalAlignment: Text.AlignRight
                font.pointSize: root.pointSize

                Keys.onEscapePressed: {
                    text = GC.loggerSessionNameDefault
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
                text: GC.loggerSessionNameReplace(textFieldSessionNameDefault.text)
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
                var selStart = textFieldSessionNameDefault.selectionStart
                var selEnd = textFieldSessionNameDefault.selectionEnd
                // selected: replace
                if(selEnd - selStart > 0) {
                    var newText = textFieldSessionNameDefault.text.substring(0, selStart) +
                            textToAdd +
                            textFieldSessionNameDefault.text.substring(selEnd, textFieldSessionNameDefault.text.length)
                    textFieldSessionNameDefault.text = newText
                }
                // otherwise: insert at cursor position
                else {
                    textFieldSessionNameDefault.insert(textFieldSessionNameDefault.cursorPosition, textToAdd);
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
            Item {
                // spacer
                Layout.fillWidth: true
            }
            Button { // reset default session name to standard
                Layout.preferredWidth: height
                font.family: FA.old
                font.pointSize: root.pointSize
                text: FA.fa_undo
                focusPolicy: Qt.NoFocus
                enabled: textFieldSessionNameDefault.text !== GC.loggerSessionNameDefaultStandard
                onPressed: {
                    textFieldSessionNameDefault.text = GC.loggerSessionNameDefaultStandard
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
                    GC.setLoggerSessionNameDefault(textFieldSessionNameDefault.text)
                    root.close()
                }
            }
        }
    }
}
