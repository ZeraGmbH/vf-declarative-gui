import QtQuick 2.0
import QtQuick.Controls 2.0
import VeinEntity 1.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import ModuleIntrospection 1.0
import GlobalConfig 1.0
import FunctionTools 1.0
import ZeraTranslation  1.0
import ZeraVeinComponents 1.0
import ZeraComponents 1.0
import QtQml.Models 2.11

Item {
    id: root

    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property bool groupingActive: groupingMode.checked
    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount

    //convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
    readonly property var upperChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            var name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
            var unit = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].Unit;
            if(name.indexOf("REF") === 0)  { //equivalent of startsWith that is only available in Qt 5.9
                if(channelNum<3) {//REF1..REF3
                    retVal.push(channelNum);
                }
            }
            else if(unit === "V") { //UL1..UL3 +UAUX
                retVal.push(channelNum)
            }
        }
        return retVal;
    }
    readonly property var lowerChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            var name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
            var unit = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].Unit;
            if(name.indexOf("REF") === 0) { //equivalent of startsWith that is only available in Qt 5.9
                if(channelNum>=3) { //REF3..REF6
                    retVal.push(channelNum);
                }
            }
            else if(unit === "A") { //IL1..IL3 +IAUX
                retVal.push(channelNum)
            }
        }
        return retVal;
    }

    anchors.leftMargin: 300
    anchors.rightMargin: 300

    ObjectModel{
        id: leftView
        readonly property int labelWidth : root.width/4
        readonly property int rowHeight : root.height/10
        // this Item is not active yet. In development for ExtTrans
        Item{
            width: parent.width
            height: leftView.rowHeight
            Label {
                text: Z.tr("Range automatic:")
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Math.min(18, root.height/20)
                color: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
                z: 10
            }
            VFSwitch {
                id: autoMode
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                entity: root.rangeModule
                controlPropertyName: "PAR_RangeAutomatic"
                enabled: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
            }
        }
        Item{
            width: leftList.width
            height: leftView.rowHeight
            Label {
                text: Z.tr("Range grouping:")
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Math.min(18, root.height/20)
                color: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
            }
            VFSwitch {
                id: groupingMode
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                entity: root.rangeModule
                enabled: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
                controlPropertyName: "PAR_ChannelGrouping"
            }
        }
        Label {
            text: Z.tr("Manual:")
            font.pixelSize: Math.min(18, root.height/20)
            enabled: !autoMode.checked
            color: enabled ? Material.primaryTextColor : Material.hintTextColor
        }
        ListView {
            id: uranges
            width: leftList.width
            height: 1.4*leftView.rowHeight
            model: root.upperChannels
            boundsBehavior: Flickable.StopAtBounds

            orientation: ListView.Horizontal

            delegate: Item {
                height: parent.height
                width: uranges.width/4
                Label {
                    id: urlabel
                    text: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].ChannelName
                    color: FT.getColorByIndex(modelData+1, root.groupingActive)
                    anchors.bottom: parent.top
                    anchors.bottomMargin: -(parent.height/3)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                VFComboBox {
                    //UL1-UL3 +UAUX
                    arrayMode: true
                    entity: root.rangeModule
                    controlPropertyName: "PAR_Channel"+parseInt(modelData+1)+"Range"
                    model: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].Validation.Data
                    centerVertical: true
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: urlabel.bottom
                    width: parent.width*0.95
                    enabled: parent.enabled
                    fontSize: Math.min(18, root.height/20,width/6)
                }
            }
        }

        ListView {
            id: iranges
            width: leftList.width
            height: 1.4*leftView.rowHeight
            model: root.lowerChannels
            boundsBehavior: Flickable.StopAtBounds

            orientation: ListView.Horizontal

            delegate: Item {
                height: parent.height
                width: iranges.width/4
                Label {
                    id: irlabel
                    text: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].ChannelName
                    color: FT.getColorByIndex(modelData+1, root.groupingActive)
                    anchors.bottom: parent.top
                    anchors.bottomMargin: -(parent.height/3)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                VFComboBox {
                    //IL1-IL3 +IAUX
                    arrayMode: true
                    entity: root.rangeModule
                    controlPropertyName: "PAR_Channel"+parseInt(modelData+1)+"Range"
                    model: ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(modelData+1)+"Range"].Validation.Data
                    contentMaxRows: 5
                    centerVertical: true
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: irlabel.bottom
                    width: parent.width*0.95
                    enabled: parent.enabled
                    fontSize: Math.min(18, root.height/20,width/6)
                }//            anchors.top: iranges.bottom
            }
        }
    }

    ListView {
        id: leftList
        anchors.top: parent.top
        anchors.bottom: overloadButton.top
        anchors.left: parent.left
        width: parent.width
        spacing: 5
        model: leftView
    }

    Button {
        id: overloadButton
        property int overload: root.rangeModule.PAR_Overload
        anchors.bottom: parent.bottom
        text: Z.tr("Overload")
        enabled: overload
        font.pixelSize: Math.min(14, root.height/24)

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
        }
    }

}
