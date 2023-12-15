import QtQuick 2.5
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0

/**
  * @b A selection of the available pages/views laid out in an elliptic path
  * @todo split grid and page view into separate qml files then use a loader to switch between them
  */
Item {
    id: root

    property var model;
    property double m_w: width
    property double m_h: height
    readonly property double scaleFactor: Math.min(m_w/1024, m_h/600);

    //negative for no element
    signal elementSelected(var elementValue)

    Component {
        id: pageDelegate
        Item {
            id: wrapper
            width: root.width * 0.35
            height: root.height * 0.35 + nameText.implicitHeight
            scale: PathView.iconScale
            opacity: PathView.iconOpacity
            z: -1/PathView.iconOpacity
            property string itemName: name

            Label {
                id: nameText
                text: Z.tr(name)
                textFormat: Text.PlainText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                font.pointSize: root.height * 0.035
                color: (wrapper.PathView.isCurrentItem ? Material.accentColor : Material.primaryTextColor)
                opacity: 1
                AnimationActivity {
                    targetItem: nameText
                    running: typeof activeItem !== 'undefined' ? activeItem.oneOrMoreRunning : false
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 4
                    color: Material.backgroundColor
                    z: parent.z-1
                }
            }

            Rectangle {
                anchors.top: nameText.bottom
                anchors.bottom: parent.bottom
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                border.color: Qt.darker(Material.frameColor, 1.3)
                border.width: 3
                color: "transparent"
                radius: 4
                Image {
                    id: image
                    anchors.fill: parent
                    anchors.margins: 3
                    source: icon
                    mipmap: false
                    fillMode: Image.PreserveAspectFit
                }
            }
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    if(wrapper.PathView.isCurrentItem &&
                       // prevents unexpected user activation of items while they move around
                       (pathView.offset - Math.floor(pathView.offset)) == 0) {
                        GC.setLastPageViewIndexSelected(index)
                        elementSelected({"elementIndex": index, "value": elementValue})
                    }
                    else {
                        pathView.currentIndex = index
                        delayedCloseTimer.elementValue = elementValue
                        delayedCloseTimer.start()
                    }
                }
            }
        }
    }
    Timer {
        id: delayedCloseTimer
        interval: pathView.highlightMoveDuration + 300
        repeat: false
        property var elementValue
        onTriggered: {
            GC.setLastPageViewIndexSelected(pathView.currentIndex)
            elementSelected({"elementIndex": pathView.currentIndex, "value": elementValue})
        }
    }

    PathView {
        id: pathView
        model: root.model
        interactive: false
        anchors.fill: parent
        highlightMoveDuration: 300
        currentIndex: GC.lastPageViewIndexSelected

        delegate: pageDelegate
        path: Path {
            id: path
            startX: width*0.5
            startY: height*0.8

            // Left part
            PathAttribute { name: "iconScale"; value: 0.9 }
            PathAttribute { name: "iconOpacity"; value: 1.0 }
            PathQuad { x: path.startX; y: height*0.15; controlX: -width*0.2; controlY: height*0.35 }
            // Right part
            PathAttribute { name: "iconScale"; value: 0.6 }
            PathAttribute { name: "iconOpacity"; value: 0.7 }
            PathQuad { x: path.startX; y: path.startY; controlX: width*1.2; controlY: height*0.35 }
        }
    }
}
