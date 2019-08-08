import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

Item {
  id: root

  property VisualItemModel model;
  property int horizMargin: 0
  property int rowHeight: height/10
  // hack to check scroll bar visibility
  property int rowWidth: sView.width-horizMargin-(sView.atYBeginning && sView.atYEnd ? 0 : scroller.width)
  property alias viewAnchors: sView.anchors

  ListView {
    id: sView
    anchors.fill: parent
    anchors.leftMargin: root.horizMargin
    anchors.rightMargin: root.horizMargin
    clip: true
    spacing: 0
    model: root.model
    boundsBehavior: Flickable.StopAtBounds
    ScrollIndicator.vertical: ScrollIndicator {
      id: scroller
      active: true
      onActiveChanged: {
        if(active !== true)
        {
          active = true;
        }
      }
    }
  }
}
