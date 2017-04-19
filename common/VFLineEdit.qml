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
  onTextChanged: tInput.text = text
  property QtObject entity
  property string controlPropertyName

  property bool m_alteredValue: (Math.abs(tInput.text - entity[controlPropertyName]) >=  Math.pow(10, -root.validator.decimals))

  function confirmInput() {
    if(tInput.text !== root.text && tInput.acceptableInput && root.validator)
    {
      if(root.validator.decimals > 0)
      {
        tInput.text = GC.formatNumber(tInput.text, root.validator.decimals)
        tInput.text = tInput.text.replace(/(\.)?0*$/,"") //replace empty fractions and trailing zeroes
      }

      root.entity[root.controlPropertyName] = parseFloat(tInput.text)
    }
    else
    {
      root.entity[root.controlPropertyName] = tInput.text
    }
  }

  Item {
    property var intermediateValue: root.entity[root.controlPropertyName]
    onIntermediateValueChanged: {
      var tmpValue = intermediateValue
      if(root.validator.decimals > 0)
      {
        tmpValue = GC.formatNumber(tmpValue, root.validator.decimals)
        tmpValue = tmpValue.replace(/(\.)?0*$/,"") //replace empty fractions and trailing zeroes
      }
      tInput.text = tmpValue
      root.text = tmpValue
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: acceptButton.left
    anchors.rightMargin: 8

    radius: height/4
    border.color: Material.frameColor
    border.width: 1.5
    color: root.m_alteredValue ? (tInput.acceptableInput ? Material.primaryColor : Material.backgroundDimColor) : "transparent"

    TextInput {
      id: tInput
      anchors.fill: parent
      anchors.leftMargin: height/4
      anchors.rightMargin: height/4
      horizontalAlignment: Text.AlignRight
      verticalAlignment: Text.AlignVCenter
      font.pixelSize: Math.max(height/2, 20)

      mouseSelectionMode: TextInput.SelectWords
      selectByMouse: true
      onAccepted: {
        focus = false
        confirmInput()
      }

      color: Material.primaryTextColor
    }
  }
  Button {
    id: acceptButton
    text: "\u2713" //unicode checkmark
    onTextChanged: console.log(text)
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
    enabled: tInput.acceptableInput
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
