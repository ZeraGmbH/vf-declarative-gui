import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraComponents 1.0
import "qrc:/qml/controls" as CCMP

Popup {
  id: recordNamePopup
  width: parent.width
  height: parent.height-GC.vkeyboardHeight
  modal: !Qt.inputMethod.visible
  closePolicy: Popup.NoAutoClose

  readonly property real rowHeight: (height-captionLabel.height)/6
  readonly property real pointSize: 10

  property QtObject customerdataEntity: VeinEntity.hasEntity("CustomerData") ? VeinEntity.getEntity("CustomerData") : null

  signal sigAccepted(string t_resultText);
  signal sigCanceled();

  property string resultText: substitutePlaceholders(intermediaryText);
  property string intermediaryText: currentRecordNameLabel.text;

  function substitutePlaceholders(t_text) {
    var retVal = t_text;
    var dateTime = new Date();
    var customerID = customerdataEntity ? customerdataEntity.PAR_CustomerNumber : Z.tr("[customer data is not available]")
    var replacementModel = {
      "$VIEW": Z.tr(GC.currentViewName),
      "$YEAR": Qt.formatDate(dateTime, "yyyy"),
      "$MONTH": Qt.formatDate(dateTime, "MM"),
      "$DAY": Qt.formatDate(dateTime, "dd"),
      "$TIME": Qt.formatDateTime(dateTime, "hh:mm"),
      "$SECONDS": Qt.formatDateTime(dateTime, "ss"),
      "$CUSTOMER_ID" : customerID.length>0 ? customerID : Z.tr("[customer id is not set]")
    }

    for(var replaceIndex in replacementModel)
    {
      var tmpRegexp = new RegExp("\\"+replaceIndex, 'g') //the $ is escaped as \$
      retVal = retVal.replace(tmpRegexp, replacementModel[replaceIndex]);
    }

    return retVal;
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
    font.pointSize: 12
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
        text: Z.tr("Current record name:");
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
          if(checked)
          {
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
        text: Z.tr("Preset record name:")
        font.pointSize: recordNamePopup.pointSize
      }

      Label {
        id: presetRecordNameLabel
        text: "$VIEW $YEAR/$MONTH/$DAY"
        Layout.fillWidth: true
        font.pointSize: recordNamePopup.pointSize
        horizontalAlignment: Text.AlignRight
      }

      RadioButton {
        ButtonGroup.group: presetSelectionGroup
        checked: loggerEntity.recordName === undefined || loggerEntity.recordName === "";
        onCheckedChanged: {
          if(checked)
          {
            recordNamePopup.intermediaryText = Qt.binding(function(){ return presetRecordNameLabel.text; });
          }
        }
      }
    }
    RowLayout {
      width: selectionColumn.width
      height: recordNamePopup.rowHeight

      Label {
        text: Z.tr("Custom record name:");
        font.pointSize: recordNamePopup.pointSize
      }

      ZLineEdit {
        //property alias pixelSize: textField.pixelSize
        id: customRecordNameTextField
        height: parent.height
        text: presetRecordNameLabel.text
        pointSize: recordNamePopup.pointSize

        Layout.fillWidth: true
        Layout.fillHeight: true
        textField.bottomPadding: 16
        textField.anchors.rightMargin: 0
        enabled: customRecordNameRadio.checked
        changeOnFocusLost: false
      }

      RadioButton {
        id: customRecordNameRadio
        ButtonGroup.group: presetSelectionGroup
        onCheckedChanged: {
          if(checked)
          {
            recordNamePopup.intermediaryText = Qt.binding(function(){ return customRecordNameTextField.textField.text; });
          }
        }
      }
    }
    RowLayout {
      width: selectionColumn.width
      height: recordNamePopup.rowHeight

      Button {
        text: "$VIEW"
        focusPolicy: Qt.NoFocus
        enabled: customRecordNameRadio.checked && customRecordNameTextField.textField.focus
        onPressed: {
            customRecordNameTextField.textField.insert(customRecordNameTextField.cursorPosition, text);
        }
      }
      Item {
        //spacer
        width: 4;
      }
      Button {
        text: "$YEAR"
        focusPolicy: Qt.NoFocus
        enabled: customRecordNameRadio.checked && customRecordNameTextField.textField.focus
        onPressed: {
          customRecordNameTextField.textField.insert(customRecordNameTextField.cursorPosition, text);
        }
      }
      Button {
        text: "$MONTH"
        focusPolicy: Qt.NoFocus
        enabled: customRecordNameRadio.checked && customRecordNameTextField.textField.focus
        onPressed: {
          customRecordNameTextField.textField.insert(customRecordNameTextField.cursorPosition, text);
        }
      }
      Button {
        text: "$DAY"
        focusPolicy: Qt.NoFocus
        enabled: customRecordNameRadio.checked && customRecordNameTextField.textField.focus
        onPressed: {
          customRecordNameTextField.textField.insert(customRecordNameTextField.cursorPosition, text);
        }
      }
      Item {
        //spacer
        width: 4;
      }
      Button {
        text: "$TIME"
        focusPolicy: Qt.NoFocus
        enabled: customRecordNameRadio.checked && customRecordNameTextField.textField.focus
        onPressed: {
          customRecordNameTextField.textField.insert(customRecordNameTextField.cursorPosition, text);
        }
      }
      Button {
        text: "$SECONDS"
        focusPolicy: Qt.NoFocus
        enabled: customRecordNameRadio.checked && customRecordNameTextField.textField.focus
        onPressed: {
          customRecordNameTextField.textField.insert(customRecordNameTextField.cursorPosition, text);
        }
      }
      Item {
        //spacer
        width: 4;
      }
      Button {
        text: "$CUSTOMER_ID"
        visible: VeinEntity.hasEntity("CustomerData")
        focusPolicy: Qt.NoFocus
        enabled: customRecordNameRadio.checked && customRecordNameTextField.textField.focus
        onPressed: {
          customRecordNameTextField.textField.insert(customRecordNameTextField.cursorPosition, text);
        }
      }
      Item {
        Layout.fillWidth: true
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
      font.pointSize: 12
    }

    Label {
      text: resultText
      horizontalAlignment: Text.AlignRight
      font.pointSize: 12
      textFormat: Label.PlainText
    }
    Item {
      //spacer
      Layout.fillWidth: true
    }

    Button {
      id: okButton
      text: Z.tr("OK")
      enabled: intermediaryText !== "";
      Layout.minimumWidth: cancelButton.width
      onClicked: {
        customRecordNameTextField.applyInput()
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
        customRecordNameTextField.discardInput();
        sigCanceled();
        recordNamePopup.close();
        defaultRadioButton.checked = true;
      }
    }
  }
}
