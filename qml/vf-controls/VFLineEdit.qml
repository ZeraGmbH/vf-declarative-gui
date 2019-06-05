import QtQuick 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import GlobalConfig 1.0
import "qrc:/qml/controls" as CCMP

Item {
  id: root
  property var validator
  property string text: ""
  property alias textField: tInput
  property alias description: descriptionText
  property alias unit: unitLabel
  property alias inputMethodHints: tInput.inputMethodHints;
  property alias placeholderText: tInput.placeholderText;
  property QtObject entity
  property string controlPropertyName
  readonly property bool acceptableInput: tInput.acceptableInput && (!validator || (validator.top>=parseFloat(tInput.text) && validator.bottom<=parseFloat(tInput.text)))
  readonly property bool m_alteredValue: (Math.abs(parseFloat(tInput.text) - (controlPropertyName !== "" ? entity[controlPropertyName] : parseFloat(text))) >=  Math.pow(10, -root.validator.decimals))
  onTextChanged: tInput.text = text
  onValidatorChanged: tInput.validator = validator

  // override when not connected to entity/component
  function confirmInput() {
    if(tInput.text !== root.text && root.acceptableInput)
    {
      if(root.validator)
      {
        root.entity[root.controlPropertyName] = parseFloat(tInput.text)
      }
      else
      {
        root.entity[root.controlPropertyName] = tInput.text
      }
    }
  }

  Item {
    property var intermediateValue: root.controlPropertyName !== "" ? root.entity[root.controlPropertyName] : root.text
    onIntermediateValueChanged: {
      if(intermediateValue !== undefined)
      {
        tInput.text = intermediateValue
        root.text = intermediateValue
      }
    }
  }

  Label {
    id: descriptionText
    height: root.rowHeight
    anchors.verticalCenter: parent.verticalCenter
    font.pixelSize: Math.max(height/2, 20)
  }
  Item {
    anchors.left: descriptionText.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: unitLabel.left
    anchors.rightMargin: GC.standardMargin

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
        focus = false
        confirmInput()
      }
      Keys.onEscapePressed: {
        focus = false
        text = controlPropertyName !== "" ? root.entity[root.controlPropertyName] : root.text
      }

      font.pixelSize: height/2.5

      Rectangle {
        color: "red"
        opacity: 0.2
        visible: root.acceptableInput === false
        anchors.fill: parent
        anchors.bottomMargin: -GC.standardTextBottomMargin
      }
      Rectangle {
        color: "green"
        opacity: 0.2
        visible: root.m_alteredValue && root.acceptableInput
        anchors.fill: parent
        anchors.bottomMargin: -GC.standardTextBottomMargin
      }
    }
  }
  Label {
    id: unitLabel
    height: parent.height
    font.pixelSize: height/2
    anchors.right: acceptButton.left
    anchors.rightMargin: GC.standardTextHorizMargin
    verticalAlignment: Text.AlignVCenter
  }

  CCMP.ZButton {
    id: acceptButton
    text: "\u2713" //unicode checkmark
    font.pixelSize: Math.max(height/2, 20)

    implicitHeight: 0
    width: height

    highlighted: true

    anchors.right: resetButton.left
    anchors.rightMargin: GC.standardMarginWithMin
    anchors.bottom: parent.bottom
    anchors.top: parent.top

    onClicked: {
      focus = true
      confirmInput()
    }
    enabled: root.m_alteredValue && root.acceptableInput
  }

  CCMP.ZButton {
    id: resetButton
    text: "\u00D7" //unicode x mark
    font.pixelSize: Math.max(height/2, 20)

    implicitHeight: 0
    width: height

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.top: parent.top

    onClicked: {
      focus = true
      tInput.text = controlPropertyName !== "" ? root.entity[root.controlPropertyName] : root.text
    }
    enabled: root.m_alteredValue
  }
}
