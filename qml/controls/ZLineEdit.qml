import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import GlobalConfig 1.0
import "qrc:/qml/helpers" as HELPERS

Item {
  Layout.alignment: Qt.AlignVCenter
  Layout.minimumWidth: tField.width
  id: root

  // public interface
  property var validator
  onValidatorChanged: {
    tField.validator = validator
    if(isNumeric) {
      tField.inputMethodHints = Qt.ImhFormattedNumbersOnly
    }
    else {
      tField.inputMethodHints = Qt.ImhNoAutoUppercase
    }
  }
  property string text: "" // locale C
  onTextChanged: {
    tField.text = tHelper.strToLocal(text, isNumeric, isDouble)
  }
  property alias textField: tField
  property alias inputMethodHints: tField.inputMethodHints;
  property alias placeholderText: tField.placeholderText;
  property alias readOnly: tField.readOnly
  readonly property bool acceptableInput: hasValidInput()
  property real pointSize: height/2.5
  property bool changeOnFocusLost: true

  // some extra labels (would like to get rid of them...)
  property alias description: descriptionText
  property alias unit: unitLabel

  // overridable (return true: apply immediate)
  function doApplyInput(newText) {return true}

  // helpers
  HELPERS.TextHelper {
    id: tHelper
  }
  function hasAlteredValue() {
    var decimals = isDouble ? validator.decimals : 0
    return tHelper.hasAlteredValue(isNumeric, isDouble, decimals, tField.text, text)
  }
  function hasValidInput() {
    var bottom = isNumeric ? validator.bottom : 0
    var top = isNumeric ? validator.top : 0
    return tHelper.hasValidInput(isNumeric, isDouble, validator !== undefined, bottom, top, tField.acceptableInput, tField.text)
  }

  // bit of a hack to check for IntValidator / DoubleValidator to detect a numeric field
  readonly property bool isNumeric: validator !== undefined && 'bottom' in validator && 'top' in validator
  readonly property bool isDouble: isNumeric && 'decimals' in validator
  readonly property string localeName: GC.localeName
  onLocaleNameChanged: {
    tField.text = tHelper.strToLocal(text, isNumeric, isDouble)
  }
  function applyInput() {
    if(tHelper.strToCLocale(tField.text, isNumeric, isDouble) !== text) {
      if(hasValidInput())
      {
        if(hasAlteredValue())
        {
          var newText = tHelper.strToCLocale(tField.text, isNumeric, isDouble)
          if(doApplyInput(newText)) {
            text = newText
          }
        }
        // we changed text but did not change value
        else {
          discardInput()
        }
      }
      else {
        discardInput()
      }
    }
  }
  function discardInput() {
    if(tField.text !== text) {
      tField.text = tHelper.strToLocal(text, isNumeric, isDouble)
    }
  }

  // controls
  Label { // compatibility - see comment above
    id: descriptionText
    height: parent.height
    verticalAlignment: Text.AlignVCenter
    font.pointSize: root.pointSize
    anchors.left: parent.left
    anchors.rightMargin: text !== "" ? GC.standardMargin : 0
  }
  Item {
    anchors.left: descriptionText.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: unitLabel.left
    anchors.rightMargin: unitLabel.text !== "" ? GC.standardMargin : 0

    TextField {
      id: tField
      anchors.fill: parent
      anchors.leftMargin: GC.standardTextHorizMargin
      anchors.rightMargin: GC.standardTextHorizMargin
      horizontalAlignment: Text.AlignRight
      bottomPadding: GC.standardTextBottomMargin
      font.pointSize: root.pointSize

      mouseSelectionMode: TextInput.SelectWords
      selectByMouse: true
      inputMethodHints: Qt.ImhNoAutoUppercase
      onAccepted: {
        if(root.hasValidInput()) {
          applyInput()
          focus = false
        }
      }
      Keys.onEscapePressed: {
        discardInput()
        focus = false
      }
      /* Avoid QML magic: when the cursor is at start/end position,
         left/right keys are used to change tab. We don't want that */
      Keys.onLeftPressed: {
        if(cursorPosition > 0 || selectedText !== "") {
          event.accepted = false;
        }
      }
      Keys.onRightPressed: {
        if(cursorPosition < text.length || selectedText !== "") {
          event.accepted = false;
        }
      }

      onFocusChanged: {
        if(changeOnFocusLost && !focus) {
          if(root.hasAlteredValue()) {
            if(root.hasValidInput()) {
              applyInput()
            }
            else {
              discardInput()
            }
          }
        }
        // Hmm - maybe we should add an option for this...
        /*else {
          selectAll()
        }*/
      }

      Rectangle {
        color: "red"
        opacity: 0.2
        visible: root.hasValidInput() === false && tField.enabled
        anchors.fill: parent
      }
      Rectangle {
        color: "green"
        opacity: 0.2
        visible: root.hasValidInput() && tField.enabled && root.hasAlteredValue()
        anchors.fill: parent
      }
    }
  }
  Label { // compatibility - see comment above
    id: unitLabel
    height: parent.height
    font.pointSize: root.pointSize
    anchors.right: parent.right
    anchors.rightMargin: text !== "" ? GC.standardMargin : 0
    verticalAlignment: Text.AlignVCenter
  }
}
