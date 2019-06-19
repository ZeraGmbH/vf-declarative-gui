import QtQuick 2.12
import QtQuick.Controls 2.5
import GlobalConfig 1.0

Item {
  id: root

  // public interface
  property var validator
  onValidatorChanged: {
    tInput.validator = validator
    if(isNumeric) {
      tInput.inputMethodHints = Qt.ImhDigitsOnly
    }
  }
  property string text: ""
  onTextChanged: tInput.text = text
  property alias textField: tInput
  property alias inputMethodHints: tInput.inputMethodHints;
  property alias placeholderText: tInput.placeholderText;

  // some extra labels (would like to get rid of them...)
  property alias description: descriptionText
  property alias unit: unitLabel

  // overridable
  function postApplyInput() {}

  function applyInput() {
    if(tInput.text !== root.text && root.hasValidInput()) {
      if(hasAlteredValue())
      {
        root.text = tInput.text
        postApplyInput()
      }
      // we changed text but did not change value
      else
        // discard changes
        tInput.text = root.text
    }
  }
  function discardInput() {
    if(tInput.text !== root.text) {
      // default: discard
      tInput.text = root.text
    }
  }
  function hasAlteredValue() {
    var altered = false
    // Numerical?
    if(isNumeric) {
      if(tInput.text !== root.text && (tInput.text === "" || root.text === ""))
        altered = true
      else if(isDouble)
        altered = (Math.abs(parseFloat(tInput.text) - parseFloat(text))) >= Math.pow(10, -root.validator.decimals)
      else
        altered = parseInt(tInput.text, 10) === parseInt(text, 10)
    }
    else
      altered = tInput.text !== root.text
    return altered
  }



  // helper
  // bit of a hack to check for IntValidator / DoubleValidator to detect a numeric field
  readonly property bool isNumeric: validator && 'bottom' in validator && 'top' in validator
  readonly property bool isDouble: isNumeric && 'decimals' in validator

  function hasValidInput() {
    var valid = tInput.acceptableInput
    if (valid && root.validator) {
      // IntValidator / DoubleValidator?
      if(root.isNumetic) {
        if(root.isDouble)
          valid = root.validator.top>=parseFloat(tInput.text) && root.validator.bottom<=parseFloat(tInput.text)
        else
          valid = root.validator.top>=parseInt(tInput.text, 10) && root.validator.bottom<=parseInt(tInput.text, 10)
      }
      // RegExpValidator
      else {
        // TODO
      }
    }
    return valid
  }

  // controls
  Label { // compatibility - see comment above
    id: descriptionText
    height: root.rowHeight
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: Math.max(height/2, 20)
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
      id: tInput
      anchors.fill: parent
      anchors.bottomMargin: GC.standardTextBottomMargin
      anchors.leftMargin: GC.standardTextHorizMargin
      anchors.rightMargin: GC.standardTextHorizMargin
      horizontalAlignment: Text.AlignRight
      implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                               background ? background.implicitHeight : 0)

      mouseSelectionMode: TextInput.SelectWords
      selectByMouse: true
      onAccepted: {
        applyInput()
        focus = false
      }
      Keys.onEscapePressed: {
        discardInput()
        focus = false
      }
      onFocusChanged: {
        if(!focus) {
          if(root.hasAlteredValue()) {
            if(root.hasValidInput())
              applyInput()
            else
              discardInput()
          }
        }
        else {
          selectAll()
        }
      }

      font.pixelSize: height/2.5

      Rectangle {
        color: "red"
        opacity: 0.2
        visible: root.hasValidInput() === false && tInput.enabled
        anchors.fill: parent
        anchors.bottomMargin: -GC.standardTextBottomMargin
      }
      Rectangle {
        color: "green"
        opacity: 0.2
        visible: root.hasValidInput() && tInput.enabled && root.hasAlteredValue()
        anchors.fill: parent
        anchors.bottomMargin: -GC.standardTextBottomMargin
      }
    }
  }
  Label { // compatibility - see comment above
    id: unitLabel
    height: parent.height
    font.pixelSize: height/2
    anchors.right: parent.right
    anchors.rightMargin: text !== "" ? GC.standardMargin : 0
    verticalAlignment: Text.AlignVCenter
  }
}
