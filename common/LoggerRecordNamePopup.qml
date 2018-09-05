import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import VeinEntity 1.0
import ZeraTranslation  1.0

Popup {
  id: recordNamePopup
  width: root.width*0.9
  height:root.height
  x: root.width/2 - width/2
  dim: true
  modal: true
  closePolicy: Popup.NoAutoClose

  signal sigAccepted(string t_resultText);
  signal sigCanceled();

  property string resultText: substitutePlaceholders(intermediaryText);
  property string intermediaryText: currentRecordNameLabel.text;

  function substitutePlaceholders(t_text) {
    var retVal = t_text;
    var dateTime = new Date();
    var replacementModel = {
      "$VIEW": "SOME_VIEW",
      "$YEAR": Qt.formatDate(dateTime, "yyyy"),
      "$MONTH": Qt.formatDate(dateTime, "MM"),
      "$DAY": Qt.formatDate(dateTime, "dd"),
      "$TIME": Qt.formatDateTime(dateTime, "hh:mm"),
      "$SECONDS": Qt.formatDateTime(dateTime, "ss")
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
    text: "Select record name"
    font.pointSize: 20
  }

  Column {
    id: selectionColumn
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: captionLabel.bottom
    anchors.bottom: popupControlContainer.top
    RowLayout {
      width: selectionColumn.width

      Label {
        text: "Current record name:"
      }

      Label {
        id: currentRecordNameLabel
        text: loggerEntity.recordName
        Layout.fillWidth: true
        font.pointSize: 10
        horizontalAlignment: Text.AlignRight
      }

      RadioButton {
        id: defaultRadioButton
        checked: true
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

      Label {
        text: "Preset record name:"
      }

      Label {
        id: presetRecordNameLabel
        text: "$VIEW $YEAR/$MONTH/$DAY $TIME"
        Layout.fillWidth: true
        font.pointSize: 10
        horizontalAlignment: Text.AlignRight
      }

      RadioButton {
        ButtonGroup.group: presetSelectionGroup
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

      Label {
        text: "Custom record name:"
      }
      Item {
        //spacer
        width: 16
      }

      TextField {
        id: customRecordNameTextField
        text: presetRecordNameLabel.text
        Layout.fillWidth: true
        font.pointSize: 10
        //horizontalAlignment: Text.AlignRight
        selectByMouse: true;
      }

      RadioButton {
        ButtonGroup.group: presetSelectionGroup
        onCheckedChanged: {
          if(checked)
          {
            recordNamePopup.intermediaryText = Qt.binding(function(){ return customRecordNameTextField.text; });
          }
        }
      }
    }
    RowLayout {
      width: selectionColumn.width

      Button {
        text: "$VIEW"
        focusPolicy: Qt.NoFocus
        onPressed: {
          if(customRecordNameTextField.focus === true)
          {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, text);
          }
        }
      }
      Item {
        //spacer
        width: 4;
      }
      Button {
        text: "$YEAR"
        focusPolicy: Qt.NoFocus
        onPressed: {
          if(customRecordNameTextField.focus === true)
          {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, text);
          }
        }
      }
      Button {
        text: "$MONTH"
        focusPolicy: Qt.NoFocus
        onPressed: {
          if(customRecordNameTextField.focus === true)
          {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, text);
          }
        }
      }
      Button {
        text: "$DAY"
        focusPolicy: Qt.NoFocus
        onPressed: {
          if(customRecordNameTextField.focus === true)
          {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, text);
          }
        }
      }
      Item {
        //spacer
        width: 4;
      }
      Button {
        text: "$TIME"
        focusPolicy: Qt.NoFocus
        onPressed: {
          if(customRecordNameTextField.focus === true)
          {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, text);
          }
        }
      }
      Button {
        text: "$SECONDS"
        focusPolicy: Qt.NoFocus
        onPressed: {
          if(customRecordNameTextField.focus === true)
          {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, text);
          }
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
        onPressed: {
          if(customRecordNameTextField.focus === true)
          {
            customRecordNameTextField.insert(customRecordNameTextField.cursorPosition, text);
          }
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
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    Label {
      text: "Preview:"
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
      text: ZTR["Accept"]
      highlighted: true
      onClicked: {
        sigAccepted(substitutePlaceholders(intermediaryText)); //updates values date/time placeholders
        recordNamePopup.close();
        defaultRadioButton.checked = true;
        customRecordNameTextField.text = presetRecordNameLabel.text;
      }
    }
    Item {
      //spacer
      width: 16
    }
    Button {
      text: ZTR["Cancel"]
      onClicked: {
        sigCanceled();
        recordNamePopup.close();
        defaultRadioButton.checked = true;
        customRecordNameTextField.text = presetRecordNameLabel.text;
      }
    }
  }
}
