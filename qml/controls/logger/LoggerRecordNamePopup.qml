import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import "qrc:/qml/controls" as CCMP

Popup {
    id: recordNamePopup
    parent: Overlay.overlay
    width: parent.width
    height: parent.height - GC.vkeyboardHeight
    modal: !Qt.inputMethod.visible
    closePolicy: Popup.NoAutoClose

    readonly property real rowHeight: height/6.5
    readonly property real fontScale: 0.3
    readonly property real pointSize: rowHeight*fontScale > 0.0 ? rowHeight*fontScale : 10

    property QtObject customerdataEntity: VeinEntity.hasEntity("CustomerData") ? VeinEntity.getEntity("CustomerData") : null

    signal sigAccepted(string t_resultText);
    signal sigCanceled();

    property string resultText: substitutePlaceholders(intermediaryText);
    property string intermediaryText: currentRecordNameLabel.text;
    property bool customerIDSet: customerdataEntity ? customerdataEntity.PAR_DatasetIdentifier !=="" : false

    function substitutePlaceholders(t_text) {
        var retVal = t_text;
        var dateTime = new Date();
        var customerID = customerdataEntity ? customerdataEntity.PAR_DatasetIdentifier : Z.tr("[customer data is not available]")
        var customerNumber = customerdataEntity ? customerdataEntity.PAR_CustomerNumber : Z.tr("[customer data is not available]")
        var replacementModel = {
            "$VIEW": Z.tr(GC.currentViewName),
            "$YEAR": Qt.formatDate(dateTime, "yyyy"),
            "$MONTH": Qt.formatDate(dateTime, "MM"),
            "$DAY": Qt.formatDate(dateTime, "dd"),
            "$TIME": Qt.formatDateTime(dateTime, "hh:mm"),
            "$SECONDS": Qt.formatDateTime(dateTime, "ss"),
            "$CUST_ID" : customerID.length>0 ? customerID : Z.tr("[customer id is not set]"),
            "$CUST_NUM" : customerID.length>0 ? customerNumber : Z.tr("[customer number is not set]")
        }
        for(var replaceIndex in replacementModel) {
            var tmpRegexp = new RegExp("\\"+replaceIndex, 'g') //the $ is escaped as \$
            retVal = retVal.replace(tmpRegexp, replacementModel[replaceIndex]);
        }
        return retVal;
    }
    function setCustomRecordName(textToSet) {
        // all selected: replace
        if(customRecordNameTextField.selectedText === customRecordNameTextField.text) {
            customRecordNameTextField.text = textToSet
        }
        // otherwise: insert
        else {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, textToSet);
        }
    }

    ButtonGroup {
        id: presetSelectionGroup
    }
    Label {
        id: captionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        text: Z.tr("Select record name")
        font.pointSize: recordNamePopup.pointSize
    }
    Column {
        id: selectionColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: captionLabel.bottom
        anchors.bottom: popupControlContainer.top
        RowLayout {
            width: selectionColumn.width
            visible: loggerEntity.recordName !== undefined && loggerEntity.recordName !== "";
            height: recordNamePopup.rowHeight

            Label {
                text: Z.tr("Current name:");
                font.pointSize: recordNamePopup.pointSize
            }
            Label {
                id: currentRecordNameLabel
                text: loggerEntity.recordName ? loggerEntity.recordName : "";
                Layout.fillWidth: true
                font.pointSize: recordNamePopup.pointSize
                horizontalAlignment: Text.AlignRight
            }
            RadioButton {
                id: defaultRadioButton
                checked: loggerEntity.recordName !== undefined && loggerEntity.recordName !== "";
                enabled: loggerEntity.recordName !== undefined && loggerEntity.recordName !== "";
                onCheckedChanged: {
                    if(checked) {
                        recordNamePopup.intermediaryText = Qt.binding(function(){ return currentRecordNameLabel.text; });
                    }
                }
                ButtonGroup.group: presetSelectionGroup
            }
        }
        RowLayout {
            width: selectionColumn.width
            height: recordNamePopup.rowHeight

            Label {
                text: Z.tr("Default name:")
                font.pointSize: recordNamePopup.pointSize
            }
            Label {
                id: presetRecordNameLabel
                text: GC.loggerRecordnamePreset
                Layout.fillWidth: true
                font.pointSize: recordNamePopup.pointSize
                horizontalAlignment: Text.AlignRight
            }
            RadioButton {
                ButtonGroup.group: presetSelectionGroup
                checked: loggerEntity.recordName === undefined || loggerEntity.recordName === "";
                onCheckedChanged: {
                    if(checked) {
                        recordNamePopup.intermediaryText = Qt.binding(function(){ return presetRecordNameLabel.text; });
                    }
                }
            }
        }
        RowLayout {
            width: selectionColumn.width
            height: recordNamePopup.rowHeight

            Label {
                text: Z.tr("Custom name:");
                font.pointSize: recordNamePopup.pointSize
            }
            // No ZLineEdit due to special handling (Button insert / delete)
            TextField {
                id: customRecordNameTextField
                text: presetRecordNameLabel.text;
                Layout.fillWidth: true;
                bottomPadding: GC.standardTextBottomMargin
                enabled: customRecordNameRadio.checked
                inputMethodHints: Qt.ImhNoAutoUppercase
                horizontalAlignment: Text.AlignRight
                property string lastAccepted: presetRecordNameLabel.text
                Keys.onEscapePressed: {
                    customRecordNameTextField.text = customRecordNameTextField.lastAccepted
                    focus = false
                }
                onAccepted: {
                    customRecordNameTextField.lastAccepted = customRecordNameTextField.text
                    focus = false
                }
                onFocusChanged: {
                    if(focus) {
                        selectAll()
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "green"
                    opacity: 0.2
                    visible: customRecordNameRadio.checked &&
                             customRecordNameTextField.lastAccepted != customRecordNameTextField.text
                }
            }

            RadioButton {
                id: customRecordNameRadio
                ButtonGroup.group: presetSelectionGroup
                onCheckedChanged: {
                    if(checked) {
                        recordNamePopup.intermediaryText = Qt.binding(function(){ return customRecordNameTextField.text; });
                        customRecordNameTextField.focus = true
                    }
                }
            }
        }
        RowLayout {
            width: selectionColumn.width
            height: recordNamePopup.rowHeight

            Button {
                text: "$CUST_ID"
                visible: VeinEntity.hasEntity("CustomerData")
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.focus
                onPressed: {
                    setCustomRecordName(text)
                }
            }
            Button {
                text: "$CUST_NUM"
                visible: VeinEntity.hasEntity("CustomerData")
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.focus
                onPressed: {
                    setCustomRecordName(text)
                }
            }
            Item { // spacer
                Layout.minimumWidth: 1
            }
            Button {
                text: "$YEAR"
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.focus
                onPressed: {
                    setCustomRecordName(text)
                }
            }
            Button {
                text: "$MONTH"
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.focus
                onPressed: {
                    setCustomRecordName(text)
                }
            }
            Button {
                text: "$DAY"
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.focus
                onPressed: {
                    setCustomRecordName(text)
                }
            }
            Item {
                // spacer
                Layout.minimumWidth: 1
            }
            Button {
                text: "$TIME"
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.focus
                onPressed: {
                    setCustomRecordName(text)
                }
            }
            Button {
                text: "$SECONDS"
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.focus
                onPressed: {
                    setCustomRecordName(text)
                }
            }
            Item {
                // spacer
                Layout.fillWidth: true
            }
            Button {
                text: Z.tr("Preset")
                focusPolicy: Qt.NoFocus
                enabled: customRecordNameRadio.checked && customRecordNameTextField.text !== ""
                onPressed: {
                    GC.setLoggerRecordnamePreset(customRecordNameTextField.text)
                }
            }
        }
    }

    RowLayout {
        id: popupControlContainer
        width: selectionColumn.width
        height: recordNamePopup.rowHeight
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Label {
            text: Z.tr("Preview:");
            font.bold: true
            font.pointSize: recordNamePopup.pointSize
        }

        Label {
            text: resultText
            horizontalAlignment: Text.AlignRight
            font.pointSize: recordNamePopup.pointSize
            textFormat: Label.PlainText
        }
        Item {
            // spacer
            Layout.fillWidth: true
        }
        Button {
            id: okButton
            text: Z.tr("OK")
            enabled: intermediaryText !== "";
            Layout.minimumWidth: cancelButton.width
            onClicked: {
                customRecordNameTextField.lastAccepted = customRecordNameTextField.text
                sigAccepted(substitutePlaceholders(intermediaryText)); //updates values date/time placeholders
                recordNamePopup.close();
                defaultRadioButton.checked = true;
            }
        }
        Button {
            id: cancelButton
            text: Z.tr("Cancel")
            Layout.minimumWidth: okButton.width
            onClicked: {
                customRecordNameTextField.text = customRecordNameTextField.lastAccepted
                sigCanceled();
                recordNamePopup.close();
                defaultRadioButton.checked = true;
            }
        }
    }
}
