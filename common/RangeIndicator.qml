import QtQuick 2.0
import ModuleIntrospection 1.0
import VeinEntity 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.0
import GlobalConfig 1.0
import "qrc:/data/staticdata/FontAwesome.js" as FA


Loader {
  id: invisibleRoot
  active: false
  sourceComponent: Component {
    Item {
      id: root
      width: invisibleRoot.width
      height: invisibleRoot.height
      property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
      readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")

      property int contentWidth: root.width/(root.channelCount/2)*0.9

      property int rangeGrouping: rangeModule.PAR_ChannelGrouping

      Rectangle {
        anchors.fill: parent
        color: Material.background
        opacity: 0.2
      }

      Label {
        anchors.right: parent.right
        anchors.rightMargin: root.contentWidth*0.1
        anchors.verticalCenter: parent.verticalCenter
        font.family: "FontAwesome"
        font.pixelSize: 18
        text: FA.fa_exclamation_triangle

        property bool overload: rangeModule.PAR_Overload === 1

        opacity: overload ? 1.0 : 0.2
        color:  overload ? Material.color(Material.Yellow) : Material.color(Material.Grey)
      }

      ListView {
        id: voltageList
        model: root.channelCount/2
        anchors.left: parent.left
        anchors.leftMargin: root.contentWidth*0.1
        anchors.right: parent.right

        height: root.height/2

        boundsBehavior: ListView.StopAtBounds
        orientation: Qt.Horizontal
        spacing: root.contentWidth*0.2

        delegate: Item {
          width: root.contentWidth*0.8
          height: root.height/2
          Label {
            font.pixelSize: parent.height/1.3
            anchors.verticalCenter: parent.verticalCenter
            text: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(index+1)+"Range"].ChannelName + ": "
            color: GC.getColorByIndex(index+1, rangeGrouping)
            font.bold: true
          }
          Label {
            anchors.right: parent.right
            font.pixelSize: parent.height/1.3
            anchors.verticalCenter: parent.verticalCenter
            text: root.rangeModule["PAR_Channel"+parseInt(index+1)+"Range"]
          }
        }
      }
      ListView {
        model: root.channelCount/2
        anchors.left: parent.left
        anchors.leftMargin: root.contentWidth*0.1
        anchors.right: parent.right
        height: root.height/2
        anchors.top: voltageList.bottom

        boundsBehavior: ListView.StopAtBounds
        orientation: Qt.Horizontal
        spacing: root.contentWidth*0.2

        delegate: Item {
          width: root.contentWidth*0.8
          height: root.height/2
          Label {
            font.pixelSize: parent.height/1.3
            anchors.verticalCenter: parent.verticalCenter
            text: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(index+4)+"Range"].ChannelName + ": "
            color: GC.getColorByIndex(index+4, rangeGrouping)
            font.bold: true
          }
          Label {
            anchors.right: parent.right
            font.pixelSize: parent.height/1.3
            anchors.verticalCenter: parent.verticalCenter
            text: root.rangeModule["PAR_Channel"+parseInt(index+4)+"Range"]
          }
        }
      }
    }
  }
}


