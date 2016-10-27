import QtQuick 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ModuleIntrospection 1.0
import "qrc:/vf-controls/common" as VFControls
import GlobalConfig 1.0
import Com5003Translation  1.0

Item {
  id: root

  readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
  anchors.leftMargin: 300
  anchors.rightMargin: 300

  property bool groupingActive: groupingMode.checked

  Item {
    id: grid

    function getColorByIndex(rangIndex) {
      var retVal;
      if(autoMode.checked)
      {
        retVal = "gray"
      }
      else if(groupingMode.checked)
      {
        var channelName = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+rangIndex+"Range"].ChannelName;
        if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup1.indexOf(channelName)>-1)
        {
          retVal = GC.groupColorVoltage
        }
        else if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup2.indexOf(channelName)>-1)
        {
          retVal = GC.groupColorCurrent
        }
        else if(ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelGroup3.indexOf(channelName)>-1)
        {
          retVal = GC.groupColorReference
        }
      }
      else
      {
        retVal = GC.systemColorByIndex(rangIndex)
      }
      return retVal;
    }

    anchors.fill: parent

    anchors.margins: parent.width*0.02

    property real cellHeight: height/15
    property real cellWidth: width/16

    Label {
      text: ZTR["Range automatic:"]
      y: grid.cellHeight*0.75
      height: grid.cellHeight*2
      width: grid.cellWidth*4
      font.pixelSize: Math.min(18, root.height/20, width/6)
      color: VeinEntity.getEntity("_System").Session !== "1_ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
    }
    VFControls.VFSwitch {
      id: autoMode
      x: grid.cellWidth*5
      height: grid.cellHeight*2
      width: grid.cellWidth*4
      entity: root.rangeModule
      controlPropertyName: "PAR_RangeAutomatic"
      enabled: VeinEntity.getEntity("_System").Session !== "1_ref-session.json"
    }
    Button {
      id: overloadButton
      text: ZTR["Overload"]
      property int overload: root.rangeModule.PAR_Overload

      enabled: overload
      x: grid.cellWidth*16 - width
      height: grid.cellHeight * 2
      width: grid.cellWidth * 4
      font.pixelSize: Math.min(14, root.height/24, width/8)

      onClicked: {
        root.rangeModule.PAR_Overload = 0;
      }

      background: Rectangle {
        implicitWidth: 64
        implicitHeight: 48

        // external vertical padding is 6 (to increase touch area)
        y: 6
        width: parent.width
        height: parent.height - 12
        radius: 2

        color: overloadButton.overload ? "darkorange" : Material.switchDisabledHandleColor

        Behavior on color {
          ColorAnimation {
            duration: 400
          }
        }

        Rectangle {
          width: parent.width
          height: parent.height
          radius: parent.radius
          visible: overloadButton.activeFocus
          color: overloadButton.Material.checkBoxUncheckedRippleColor
        }

        layer.enabled: overloadButton.enabled
        layer.effect: DropShadow {
          verticalOffset: 1
          color: overloadButton.Material.dropShadowColor
          samples: overloadButton.pressed ? 15 : 9
          spread: 0.5
        }
      }
    }
    Label {
      text: ZTR["Range grouping:"]
      y: grid.cellHeight*2.75
      height: grid.cellHeight*2
      width: grid.cellWidth*4
      font.pixelSize: Math.min(18, root.height/20, width/6)
      color: VeinEntity.getEntity("_System").Session !== "1_ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
    }
    VFControls.VFSwitch {
      id: groupingMode
      y: grid.cellHeight*2
      x: grid.cellWidth*5
      height: grid.cellHeight*2
      width: grid.cellWidth*4
      entity: root.rangeModule
      enabled: VeinEntity.getEntity("_System").Session !== "1_ref-session.json"
      controlPropertyName: "PAR_ChannelGrouping"
    }
    Label {
      text: ZTR["Manual:"]
      font.pixelSize: Math.min(18, root.height/20)
      enabled: !autoMode.checked
      color: enabled ? Material.primaryTextColor : Material.hintTextColor
      y: grid.cellHeight*5
      height: grid.cellHeight*1
      width: grid.cellWidth*16
    }
    Repeater {
      id: _repeater1
      model: 3
      Item {
        Item {
          y: grid.cellHeight*6
          x: grid.cellWidth*index*6
          height: grid.cellHeight*3
          width: grid.cellWidth*4
          enabled: !autoMode.checked

          Label {
            text: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(index+1)+"Range"].ChannelName
            color: grid.getColorByIndex(index+1)
            anchors.bottom: parent.top
            anchors.bottomMargin: -(parent.height/3)
            anchors.horizontalCenter: parent.horizontalCenter
          }
          VFControls.VFComboBox {
            //UL1-UL3
            arrayMode: true
            entity: root.rangeModule
            controlPropertyName: "PAR_Channel"+parseInt(index+1)+"Range"
            model: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(index+1)+"Range"].Validation.Data
            centerVertical: true
            centerVerticalOffset:  model.length>2 ? 0 : height
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height/3
            width: parent.width*0.95
            enabled: parent.enabled
            opacity: enabled ? 1.0 : 0.4
            fontSize: Math.min(18, root.height/20, width/6)
          }
        }

        Item {
          y: grid.cellHeight*9
          x: grid.cellWidth*index*6
          height: grid.cellHeight*3
          width: grid.cellWidth*4
          enabled: !autoMode.checked


          Label {
            text: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(index+4)+"Range"].ChannelName
            color: grid.getColorByIndex(index+4)
            anchors.bottom: parent.top
            anchors.bottomMargin: -(parent.height/3)
            anchors.horizontalCenter: parent.horizontalCenter
          }
          VFControls.VFComboBox {
            //IL1-IL3
            arrayMode: true
            entity: root.rangeModule
            controlPropertyName: "PAR_Channel"+parseInt(index+4)+"Range"
            model: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(index+4)+"Range"].Validation.Data

            contentMaxRows: model.length>4 ? Math.min(model.length, 8) : 0
            contentFlow: GridView.FlowTopToBottom
            contentRowHeight: height

            centerVertical: true
            centerVerticalOffset: model.length>2 ? -height*1.25 : height
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height/3
            width: parent.width*0.95
            enabled: parent.enabled
            opacity: enabled ? 1.0 : 0.4
            fontSize: Math.min(18, root.height/20, width/6)
          }
        }
      }
    }
  }
}
