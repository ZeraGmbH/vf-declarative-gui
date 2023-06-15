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

    readonly property real rowHeight: height/10
    readonly property real pointSize: rowHeight > 0 ? rowHeight * 0.325 : 10
    readonly property real smallPointSize: pointSize * 0.8
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property bool groupingActive: groupingMode.checked
    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount

    //convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
    readonly property var upperChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            var name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
            var unit = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].Unit;
            if(name.startsWith("REF")) {
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
            if(name.startsWith("REF")) {
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

    readonly property bool referenceRanges: {
        let ref = false
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            let name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
            if(name.startsWith("REF")) {
                ref = true
                break
            }
        }
        return ref
    }

    ObjectModel{
        id: leftView
        Item{
            width: parent.width
            height: rowHeight
            Label {
                text: Z.tr("Range automatic:")
                anchors.left: parent.left
                verticalAlignment: Label.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                height: rowHeight
                font.pointSize: pointSize
                color: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
            }
            VFSwitch {
                id: autoMode
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: rowHeight
                entity: root.rangeModule
                enabled: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
                controlPropertyName: "PAR_RangeAutomatic"
            }
        }
        Item{
            width: leftList.width
            height: rowHeight
            Label {
                text: Z.tr("Range grouping:")
                anchors.left: parent.left
                verticalAlignment: Label.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                height: rowHeight
                font.pointSize: pointSize
                color: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json" ? Material.primaryTextColor : Material.hintTextColor
            }
            VFSwitch {
                id: groupingMode
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: rowHeight
                entity: root.rangeModule
                enabled: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
                controlPropertyName: "PAR_ChannelGrouping"
            }
        }
        RangeView{
            id: uranges
            rangeWidth: leftList.width
            rangeHeight: 1.4*rowHeight
            model: root.upperChannels
        }

        Item {
            id: extU
            width: iranges.width
            height: !referenceRanges ? rowHeight : 0
            visible: !referenceRanges
            Label{
                text: Z.tr("UExt:")
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: uTrZ
                width: parent.width/4
                height: rowHeight
                anchors.right: udiv.left
                description.width: 0
                pointSize: root.pointSize
                text: rangeModule["PAR_PreScalingGroup0"].split("*")[0].split("/")[0]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup0"]=newText+"/"+uTrN.text+sqrtComb.currentText
                }
            }
            Label{
                id: udiv
                text: "/"
                anchors.right: uTrN.left
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: uTrN
                width: parent.width/4
                height: rowHeight
                anchors.right: sqrtComb.left
                description.width: 0
                pointSize: root.pointSize
                text: rangeModule["PAR_PreScalingGroup0"].split("*")[0].split("/")[1]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup0"]=rangeModule["PAR_PreScalingGroup0"]=uTrZ.text+"/"+newText+sqrtComb.currentText
                }
            }
            ZVisualComboBox {
                id: sqrtComb
                height: rowHeight
                width: parent.width * 0.145
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
                height: rowHeight
            }

        }
        Item {
            id: spacer
            height: rowHeight/2
            width: leftList.width
        }

        RangeView{
            id: iranges
            rangeWidth: leftList.width
            rangeHeight: 1.4*rowHeight
            model: root.lowerChannels
        }
        Item {
            id: extI
            width: iranges.width
            height: !referenceRanges ? rowHeight : 0
            visible: !referenceRanges
            Label{
                text: Z.tr("IExt:")
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: iTrZ
                width: parent.width/4
                height: rowHeight
                anchors.right: idiv.left
                description.width: 0
                pointSize: root.pointSize
                text: rangeModule["PAR_PreScalingGroup1"].split("*")[0].split("/")[0]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup1"]=newText+"/"+iTrN.text
                }
            }
            Label{
                id: idiv
                text: "/"
                anchors.right: iTrN.left
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: pointSize
            }
            ZLineEdit {
                id: iTrN
                width: parent.width/4
                height: rowHeight
                anchors.right: extIcheck.left
                anchors.rightMargin: 70
                description.width: 0
                pointSize: root.pointSize
                text: rangeModule["PAR_PreScalingGroup1"].split("*")[0].split("/")[1]
                validator: IntValidator{bottom: 1; top: 999999 }
                function doApplyInput(newText) {
                    rangeModule["PAR_PreScalingGroup1"]=iTrZ.text+"/"+newText
                }
            }
            VFSwitch{
                id: extIcheck
                anchors.right: parent.right
                height: rowHeight
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


    Item {
        id: rightview
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width*7/16-10

        Button {
            id: overloadButton
            text: Z.tr("Overload")
            readonly property bool overload: root.rangeModule.PAR_Overload
            anchors.top: parent.top
            anchors.horizontalCenter: rangbar.horizontalCenter
            enabled: overload
            font.pointSize: pointSize * 0.75
            onClicked: {
                root.rangeModule.PAR_Overload = 0;
            }
            background: Rectangle {
                anchors.fill: parent
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
            anchors.margins: rowHeight*0.3
            rangeGrouping: root.groupingActive
        }
    }
}
