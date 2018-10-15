import QtQuick 2.0

/**
  * @b Used for debuging the real size / position of elements (QQC2 elements do not allow clean and simple modifications of their internal margins/padding)
  */
Rectangle {
  id: debugRectangle
  color: "transparent"

  border.width: 1
  border.color: borderColor

  property color borderColor: "white"

  SequentialAnimation {
    running: visible
    loops: SequentialAnimation.Infinite

    ColorAnimation {
      target: debugRectangle
      property: "borderColor"
      to: "blue"
      duration: 1000
    }
    ColorAnimation {
      target: debugRectangle
      property: "borderColor"
      to: "white"
      duration: 1000
    }
  }
}
