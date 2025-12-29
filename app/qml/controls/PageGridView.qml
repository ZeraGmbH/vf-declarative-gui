import QtQuick 2.5
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.0
import ZeraTranslation  1.0
import GlobalConfig 1.0
import ZeraThemeConfig 1.0
import AppStarterForWebGLSingleton 1.0

/**
  * @b A selection of the available pages/views laid out in an elliptic path
  * @todo split grid and page view into separate qml files then use a loader to switch between them
  */
Item {
    id: root

    property var model;
    readonly property double scaleFactor: Math.min(width/1024, height/600);

    // negative for no element
    signal elementSelected(var elementValue)

    Component {
        id: gridDelegate

        Rectangle {
            id: gridWrapper
            property string itemName: name
            border.color: ZTC.isDarkTheme ? Qt.darker(ZTC.frameColor, 1.3) : Qt.lighter(ZTC.frameColor, 1.3)
            border.width: 3
            width: root.width/2 - 12
            height: 64*scaleFactor+6
            color: "#11ffffff" // Material.backgroundColor
            radius: 4

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    GC.setLastPageViewIndexSelected(index)
                    root.elementSelected({"elementIndex": index, "value": elementValue})
                }
            }
            Loader {
                id: listImage
                active: !ASWGL.isServer
                width: height*1.83 // image form factor
                height: parent.height-8
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 4
                sourceComponent: Image {
                    source: ZTC.isDarkTheme ? icon : iconLight
                    mipmap: true
                }
            }
            Label {
                id: nameText
                text: Z.tr(name)
                textFormat: Text.PlainText
                anchors.left: listImage.right
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Label.Wrap
                font.pointSize: 14
                color: (gridView.currentItem === gridWrapper ? Material.accentColor : Material.primaryTextColor)
                AnimationActivity {
                    targetItem: nameText
                    running: isRunningItem.isRunning()
                }
            }
        }
    }

    GridView {
        id: gridView
        model: root.model
        flow: GridView.FlowTopToBottom
        boundsBehavior: Flickable.StopAtBounds
        cellHeight: 64*scaleFactor+12
        cellWidth: width/2
        anchors.fill: parent
        // Center one in case of one column
        // This is a hack - but it works and a better solution was not yet found
        anchors.leftMargin: 8 + (model.count <= 6 ? root.width/4 : 0)
        anchors.topMargin: root.height/10
        anchors.bottomMargin: root.height/10
        clip: true
        ScrollBar.horizontal: ScrollBar { policy: gridView.contentWidth>gridView.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff; }

        delegate: gridDelegate
        currentIndex: GC.lastPageViewIndexSelected
    }
}
