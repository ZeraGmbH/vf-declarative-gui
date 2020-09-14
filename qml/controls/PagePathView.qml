import QtQuick 2.5
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraFa 1.0
import "qrc:/qml/controls" as CCMP

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

    function incrementElement() {
        delayedOperation.command = pathView.incrementCurrentIndex
        delayedOperation.start();
    }

    function decrementElement() {
        delayedOperation.command = pathView.decrementCurrentIndex
        delayedOperation.start();
    }

    Timer {
        id: delayedOperation
        property var command
        interval: 50
        repeat: false
        onTriggered: {
            command();
        }
    }

    Component {
        id: pageDelegate

        Item {
            id: wrapper
            width: 128; height: 64
            scale: PathView.iconScale
            opacity: PathView.iconOpacity
            z: -1/PathView.iconOpacity
            property string itemName: name

            Rectangle {
                id: previewImage
                anchors.centerIn: parent
                border.color: Qt.darker(Material.frameColor, 1.3)
                border.width: 3
                width: 410*scaleFactor+4
                height: 220*scaleFactor+6
                color: "transparent" //Material.backgroundColor
                radius: 4

                Image {
                    anchors.centerIn: parent
                    source: icon
                    scale: 0.8*scaleFactor
                    mipmap: false
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        if(wrapper.PathView.isCurrentItem &&
                           // prevents unexpected user activation of items while they move around
                           (pathView.offset - Math.floor(pathView.offset)) == 0) {
                            GC.pageViewLastSelectedIndex = index
                            root.elementSelected({"elementIndex": index, "value": elementValue})
                        }
                        else {
                            if(mapToItem(root, mouse.x, mouse.y).x<=root.width/2) {
                                pathView.incrementCurrentIndex()
                            }
                            else {
                                pathView.decrementCurrentIndex()
                            }
                        }
                    }
                }
            }
            Label {
                id: nameText
                text: Z.tr(name)
                textFormat: Text.PlainText
                anchors.horizontalCenter: previewImage.horizontalCenter
                anchors.bottom: previewImage.bottom
                anchors.bottomMargin: -font.pointSize*2
                font.pointSize: 16
                color: (wrapper.PathView.isCurrentItem ? Material.accentColor : Material.primaryTextColor)
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 4
                    opacity: 0.8
                    color: Material.dropShadowColor
                    z: parent.z-1
                }
            }
        }
    }

    PathView {
        id: pathView
        model: root.model
        interactive: false
        enabled: visible
        anchors.fill: parent
        highlightMoveDuration: 200
        currentIndex: GC.pageViewLastSelectedIndex

        onCurrentItemChanged: {
            //untranslated raw text
            GC.currentViewName = currentItem.itemName;
        }

        delegate: pageDelegate
        path: Path {
            startX: width/2;
            startY: height/1.8

            // describes an ellipse, the elements get scaled down and become more transparent the farther away they are from the current index on that ring
            PathAttribute { name: "iconScale"; value: 1.0 }
            PathAttribute { name: "iconOpacity"; value: 1.0 }
            PathQuad { x: m_w/2; y: 200; controlX: -m_w*0.3; controlY: m_h/4+100 }
            PathAttribute { name: "iconScale"; value: 0.4 }
            PathAttribute { name: "iconOpacity"; value: 0.2 }
            PathQuad { x: m_w/2; y: m_h/1.8; controlX: m_w*1.3; controlY: m_h/4+100 }
        }
    }
}
