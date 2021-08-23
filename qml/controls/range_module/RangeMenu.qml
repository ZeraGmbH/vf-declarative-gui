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
        // this Item is not active yet. In development for ExtTrans
        Item{
            id: extU
            width: iranges.width
            height: leftView.rowHeight
            visible: true
            Label{
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("UExt:")
                font.pixelSize: Math.min(18, root.height/20)
            }

            ZLineEdit {
                id: uTrZ
                width: parent.width/4
                height: leftView.rowHeight
                anchors.right: udiv.left
                description.width: 0
                pointSize: Math.min(24, Math.max(1,root.height/30))
                text: rangeModule["PAR_PreScalingGroup0"].split("*")[0].split("/")[0]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup0"]=newText+"/"+uTrN.text+sqrtComb.currentText
                }
            }
            Label{
                id: udiv
                anchors.right: uTrN.left
                anchors.verticalCenter: parent.verticalCenter
                text: "/"
                font.pointSize: Math.min(24, Math.max(1,root.height/30))
            }

            ZLineEdit {
                id: uTrN
                width: parent.width/4
                height: leftView.rowHeight
                anchors.right: sqrtComb.left
                description.width: 0
                pointSize: Math.min(24, Math.max(1,root.height/30))
                text: rangeModule["PAR_PreScalingGroup0"].split("*")[0].split("/")[1]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup0"]=rangeModule["PAR_PreScalingGroup0"]=uTrZ.text+"/"+newText+sqrtComb.currentText
                }
            }

            ZVisualComboBox {
                id: sqrtComb
                height: leftView.rowHeight
                width:70
                anchors.right: extUcheck.left

                model: ["","*(sqrt(3))","*(1/sqrt(3))"]
                imageModel: ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_sqrt_3.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png"]
                automaticIndexChange: true
                currentIndex:{
                    if(rangeModule["PAR_PreScalingGroup0"].includes("(1/sqrt(3))")){
                        return 2;
                    }else if(rangeModule["PAR_PreScalingGroup0"].includes("(sqrt(3))")){
                        return 1;
                    }

                    return 0;
                }
                onSelectedTextChanged: {
                    rangeModule["PAR_PreScalingGroup0"]=rangeModule["PAR_PreScalingGroup0"]=uTrZ.text+"/"+uTrN.text+selectedText
                }
            }


            VFSwitch{
                id: extUcheck
                entity: root.rangeModule
                controlPropertyName: "PAR_PreScalingEnabledGroup0"
                anchors.right: parent.right

            }


        }
        Item {
            id: spacer
            height: leftView.rowHeight/2
            width: leftList.width
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
                }
            }
        }

        Item{
            id: extI
            width: iranges.width
            height: leftView.rowHeight
            visible: true
            Label{
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Z.tr("IExt:")
                font.pixelSize: Math.min(18, root.height/20)
            }

            ZLineEdit {
                id: iTrZ
                width: parent.width/4
                height: leftView.rowHeight
                anchors.right: idiv.left
                description.width: 0
                pointSize: Math.min(24, Math.max(1,root.height/30))
                text: rangeModule["PAR_PreScalingGroup1"].split("*")[0].split("/")[0]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup1"]=newText+"/"+iTrN.text
                }
              }
            Label{
                id: idiv
                anchors.right: iTrN.left
                anchors.verticalCenter: parent.verticalCenter
                text: "/"
                font.pointSize: Math.min(24, Math.max(1,root.height/30))
            }

            ZLineEdit {
                id: iTrN
                width: parent.width/4
                height: leftView.rowHeight
                anchors.right: extIcheck.left
                anchors.rightMargin: 70
                description.width: 0
                pointSize: Math.min(24, Math.max(1,root.height/30))
                text: rangeModule["PAR_PreScalingGroup1"].split("*")[0].split("/")[1]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup1"]=iTrZ.text+"/"+newText
                }
            }
            VFSwitch{
                id: extIcheck
                anchors.right: parent.right
                entity: root.rangeModule
                controlPropertyName: "PAR_PreScalingEnabledGroup1"
            }
        }

    }

    ListView {
        id: leftList
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width*9/16
        spacing: 10
        model: leftView
    }



    Item{
        id:rightview
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width*7/16-10

    Button {
        id: overloadButton
        property int overload: root.rangeModule.PAR_Overload
        anchors.top: parent.top
        anchors.horizontalCenter: rangbar.horizontalCenter
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



    RangePeak {
        id: rangbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: overloadButton.bottom
        anchors.margins: 20
        rangeGrouping: root.groupingActive
    }
    }



}
