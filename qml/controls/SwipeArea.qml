import QtQuick 2.0

/**
 * @b Enables swipe gestures without intercepting clicks
 * @warn Do not override the onPressed() signal handler
 * @note currently not used anymore
 */
MouseArea {
  id: root
  anchors.fill: parent

  drag.target: pseudoDraggable
  //override this where needed
  drag.axis: Drag.XAndYAxis
  drag.filterChildren: true
  drag.threshold: 25

  property int triggerDistance: 100
  property bool dragging: drag.active
  property vector2d m_startPosition

  signal horizontalSwipe(var isLeftDirection)
  signal verticalSwipe(var isUpDirection)


  onDraggingChanged: {
    if(dragging)
    {
      m_startPosition = Qt.vector2d(pseudoDraggable.x, pseudoDraggable.y)
    }
    else
    {
      if(Math.abs(m_startPosition.x-pseudoDraggable.x)>=triggerDistance)
      {
        horizontalSwipe(m_startPosition.x>pseudoDraggable.x)
      }
      if(Math.abs(m_startPosition.y-pseudoDraggable.y)>=triggerDistance)
      {
        verticalSwipe(m_startPosition.y>pseudoDraggable.y)
      }
    }
  }

  Item {
    id: pseudoDraggable
    x: parent.width/2
    y: parent.height/2
    height: 1
    width: 1
  }
}
