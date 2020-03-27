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
  property string text: "" // locale C
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

  // overridables
  function doApplyInput(newText) {return true} // (return true: apply immediate)
  function hasAlteredValue() {
    var decimals = isDouble ? validator.decimals : 0
    return tHelper.hasAlteredValue(isNumeric, isDouble, decimals, tField.text, text)
  }
  function hasValidInput() {
    return tField.acceptableInput && tHelper.hasValidInput(isDouble, tField.text)
  }
  function discardInput() {
    tField.text = tHelper.strToLocal(text, isNumeric, isDouble)
  }

  // signal handler
  onTextChanged: {
    discardInput()
  }
  onValidatorChanged: {
    tField.validator = validator
    if(isNumeric) {
      tField.inputMethodHints = Qt.ImhFormattedNumbersOnly
    }
    else {
      tField.inputMethodHints = Qt.ImhNoAutoUppercase
    }
  }
  onLocaleNameChanged: {
    discardInput()
  }

  // helpers
  HELPERS.TextHelper {
    id: tHelper
  }
  // bit of a hack to check for IntValidator / DoubleValidator to detect a numeric field
  readonly property bool isNumeric: validator !== undefined && 'bottom' in validator && 'top' in validator
  readonly property bool isDouble: isNumeric && 'decimals' in validator
  readonly property string localeName: GC.localeName
  function applyInput() {
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
        if(hasValidInput()) {
          applyInput()
          focus = false
        }
      }
      Keys.onEscapePressed: {
        discardInput()
        focus = false
      }

      onFocusChanged: {
        if(changeOnFocusLost && !focus) {
          if(hasAlteredValue()) {
            if(hasValidInput()) {
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
        visible: hasValidInput() === false && tField.enabled
        anchors.fill: parent
      }
      Rectangle {
        color: "green"
        opacity: 0.2
        visible: hasValidInput() && tField.enabled && hasAlteredValue()
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
