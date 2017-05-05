import QtQuick 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import GlobalConfig 1.0

Item {
  id: root
  property int inputMethodHints
  onInputMethodHintsChanged: tInput.inputMethodHints = inputMethodHints
  property var validator
  onValidatorChanged: tInput.validator = validator

  property string text: ""
  property string unit: ""
  onTextChanged: tInput.text = text
  property QtObject entity
  property string controlPropertyName

  readonly property bool m_alteredValue: (Math.abs(parseFloat(tInput.text) - entity[controlPropertyName]) >=  Math.pow(10, -root.validator.decimals))

  readonly property bool acceptableInput: tInput.acceptableInput && (!validator || (validator.top>=parseFloat(tInput.text) && validator.bottom<=parseFloat(tInput.text)))

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
    property var intermediateValue: root.entity[root.controlPropertyName]
    onIntermediateValueChanged: {
      tInput.text = intermediateValue
      root.text = intermediateValue
    }
  }

  Item {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: unitLabel.left
    anchors.rightMargin: 8

    //radius: height/4
    //border.color: Material.frameColor
    //border.width: 1.5
    //color: root.m_alteredValue ? (root.acceptableInput ? Material.primaryColor : Material.backgroundDimColor) : "transparent"

    TextField {
      id: tInput
      anchors.fill: parent
      anchors.bottomMargin: -8
      anchors.leftMargin: height/4
      anchors.rightMargin: height/4
      horizontalAlignment: Text.AlignRight
      implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                               background ? background.implicitHeight : 0)


      font.pixelSize: Math.max(height/2, 16)

      mouseSelectionMode: TextInput.SelectWords
      selectByMouse: true
      onAccepted: {
        focus = false
        confirmInput()
      }

      color: Material.primaryTextColor
    }
  }
  Label {
    id: unitLabel
    text: unit
    height: parent.height
    font.pixelSize: Math.max(height/2, 20)
    anchors.right: acceptButton.left
    anchors.rightMargin: 8
    verticalAlignment: Text.AlignVCenter
  }

  Button {
    id: acceptButton
    text: "\u2713" //unicode checkmark
    font.pixelSize: Math.max(height/2, 20)

    implicitHeight: 0
    width: height*1.5
    //only show the button if the value is different from the remote
    visible: root.m_alteredValue
    highlighted: true

    anchors.right: resetButton.left
    anchors.rightMargin: 8
    anchors.bottom: parent.bottom
    anchors.top: parent.top

    onClicked: {
      focus = true
      confirmInput()
    }
    enabled: root.acceptableInput
  }
  Button {
    id: resetButton
    text: "\u00D7" //unicode x mark
    font.pixelSize: Math.max(height/2, 20)

    implicitHeight: 0
    width: height*1.5
    //only show the button if the value is different from the remote
    visible: root.m_alteredValue

    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.bottom: parent.bottom
    anchors.top: parent.top
    onClicked: {
      focus = true
      tInput.text = root.entity[root.controlPropertyName]
    }
  }
}
