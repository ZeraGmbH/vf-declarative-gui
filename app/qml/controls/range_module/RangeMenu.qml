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
import "../ranges"
import "../../controls"
import "../../controls/measurement_modes"

Item {
    id: root

    readonly property real rowHeight: height/10
    readonly property real valueColumnWidth: width*0.152

    readonly property real pointSize: rowHeight > 0 ? rowHeight * 0.325 : 10
    readonly property real smallPointSize: pointSize * 0.8
    readonly property QtObject rangeModule: VeinEntity.getEntity("RangeModule1")
    readonly property bool groupingActive: groupingMode.checked
    readonly property int channelCount: ModuleIntrospection.rangeIntrospection.ModuleInfo.ChannelCount
    anchors.leftMargin: 10
    anchors.topMargin: 10
    anchors.bottomMargin: 10

    //convention that channels are numbered by unit was broken, so do some $%!7 to get the right layout
    readonly property var upperChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            var name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
            if(name.startsWith("REF")) {
                if(channelNum<3) //REF1..REF3
                    retVal.push(channelNum);
            }
            else if(name.startsWith("U"))
                retVal.push(channelNum)
        }
        return retVal;
    }
    readonly property var lowerChannels: {
        var retVal = [];
        for(var channelNum=0; channelNum<channelCount; ++channelNum) {
            var name = ModuleIntrospection.rangeIntrospection.ComponentInfo["PAR_Channel"+parseInt(channelNum+1)+"Range"].ChannelName;
            if(name.startsWith("REF")) {
                if(channelNum>=3) //REF3..REF6
                    retVal.push(channelNum);
            }
            else if(name.startsWith("I"))
                retVal.push(channelNum)
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
            height: rowHeight/3
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
                    rangeModule["PAR_PreScalingGroup0"]=uTrZ.text+"/"+newText+sqrtComb.currentText
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
                    if(rangeModule["PAR_PreScalingGroup0"].includes("(1/sqrt(3))"))
                        return 2;
                    else if(rangeModule["PAR_PreScalingGroup0"].includes("(sqrt(3))"))
                        return 1;
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
            height: rowHeight/4
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
            height: !referenceRanges ? rowHeight*1.4 : 0
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

        Item{
            id:measmodeText
            width: leftList.width
            height: rowHeight/3
            visible: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
            Label {
                text: Z.tr("Measurement modes:")
                anchors.left: parent.left
                verticalAlignment: Label.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: pointSize
            }
        }
        Row {
            id: measmodeRow
            height: rowHeight
            width: leftList.width
            visible: VeinEntity.getEntity("_System").Session !== "com5003-ref-session.json"
            GridRect {
                id: measModeGrid
                height: parent.height
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                Repeater {
                    model: VeinEntity.hasEntity("POWER1Module4") ? 4 : 3
                    Item {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        x: root.valueColumnWidth*(index)
                        width: root.valueColumnWidth *0.94
                        Label {
                            text: {
                                switch(index) {
                                case 0:
                                    return VeinEntity.getEntity("POWER1Module1").ACT_PowerDisplayName
                                case 1:
                                    return VeinEntity.getEntity("POWER1Module2").ACT_PowerDisplayName
                                case 2:
                                    return VeinEntity.getEntity("POWER1Module3").ACT_PowerDisplayName
                                case 3:
                                    return Z.tr("Ext.")
                                }
                            }
                            height: parent.height
                            anchors.left: measModeCombo.right
                            anchors.leftMargin: GC.standardTextHorizMargin / 5
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: measModeGrid.height*0.4
                        }
                        MeasModeCombo {
                            id: measModeCombo
                            width: root.valueColumnWidth * 0.7
                            height: parent.height * 0.85
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            power1ModuleIdx: index
                        }
                    }
                }
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
        boundsBehavior: Flickable.StopAtBounds
    }


    Item {
        id: rightview
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width*7/16-45

        OverloadButton {
            id: overloadButton
            anchors.top: parent.top
            anchors.horizontalCenter: rangbar.horizontalCenter
            font.pointSize: pointSize * 0.75
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
