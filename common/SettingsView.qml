import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

Item {
  id: root

  signal acceptClicked;
  signal resetClicked;

  property VisualItemModel model;
  property int rowHeight: height/10
  property int rowWidth: sView.width-sView.anchors.leftMargin
  property alias viewAnchors: sView.anchors

  ListView {
    id: sView
    clip: true
    anchors.fill: parent
    model: root.model
    boundsBehavior: Flickable.StopAtBounds
    ScrollIndicator.vertical: ScrollIndicator {
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
