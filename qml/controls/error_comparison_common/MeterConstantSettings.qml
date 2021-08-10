import QtQuick 2.14
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.4
import QtQml.Models 2.11
import GlobalConfig 1.0
import VeinEntity 1.0
import FunctionTools 1.0
import ZeraFa 1.0
import ZeraTranslation 1.0
import ZeraComponents 1.0
import ZeraVeinComponents 1.0


Popup {
    id: root
    property QtObject secEntity: VeinEntity.getEntity("SEC1Module1")
    readonly property real pointSize: root.height / 30
    property int newConst: secEntity["PAR_DutConstant"]
    readonly property int comboBoxWidth : 80

    function setDefault(){
        secEntity["PAR_DutTypeMeasurePoint"]="CsIsUs"
        secEntity["PAR_DutConstantIScaleNum"]="1"
        secEntity["PAR_DutConstantIScaleDenom"]="1"
        secEntity["PAR_DutConstantUScaleNum"]="1"
        secEntity["PAR_DutConstantUScaleDenom"]="1"
    }



        Item{
            id: page1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: closeBut.top
            ObjectModel{
                readonly property int labelWidth : page1.width/4
                readonly property int rowHeight : page1.height/10
                id: propertieModel

                Label {
                    id: header1
                    height: propertieModel.rowHeight
                    font.pointSize: root.pointSize
                    text: Z.tr("Device Under Test Properties")
                }
                Item{
                    width: paramList.width
                    height: propertieModel.rowHeight
                    Label{
                        id: cpcslabel
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: root.pointSize
                        text: Z.tr("Meter Constant:")
                    }

                    ZComboBox{
                        id: cpcs
                        height: propertieModel.rowHeight
                        width: 50
                        anchors.bottom: parent.bottom
                        anchors.right: csEdit.left
                        model: ["CP", "CS"]
                        arrayMode: true
                        popup.z: 1
                        focus: true
                        automaticIndexChange: true
                        currentIndex: {
                            if(secEntity["PAR_DutTypeMeasurePoint"].includes("Cp")){
                                    return 0;
                            }else if(secEntity["PAR_DutTypeMeasurePoint"].includes("Cs")){
                                    return 1;
                            }else{
                                    return 0;
                            }
                        }

                        onSelectedTextChanged: {
                            if(selectedText === "CP"){
                                secEntity["PAR_DutTypeMeasurePoint"]=secEntity["PAR_DutTypeMeasurePoint"].replace("Cs", "Cp")
                            }
                            if(selectedText === "CS"){
                                secEntity["PAR_DutTypeMeasurePoint"]=secEntity["PAR_DutTypeMeasurePoint"].replace("Cp", "Cs")
                            }

                        }
                    }

                    VFLineEdit {
                        id: csEdit
                        entity: secEntity
                        controlPropertyName: "PAR_DutConstant"
                        width: Math.min(parent.width-cpcslabel.width,parent.width/2)-comboBoxWidth-cpcs.width
                        height: propertieModel.rowHeight
                        anchors.right: parent.right
                        anchors.rightMargin: comboBoxWidth
                        anchors.bottom: parent.bottom
                        pointSize: root.pointSize
                        description.width: 0
                        validator: ZDoubleValidator {
                            bottom: validatorDutConstant.Data[0];
                            top: validatorDutConstant.Data[1];
                            decimals: FT.ceilLog10Of1DividedByX(validatorDutConstant.Data[2]);
                        }

                    }
                    VFComboBox {
                        arrayMode: true
                        entity: secEntity
                        controlPropertyName: "PAR_DUTConstUnit"
                        model: validatorDutConstUnit.Data;
                        anchors.right: parent.right
                        width: comboBoxWidth
                        popup.z:1
                        height: propertieModel.rowHeight
                        contentRowHeight: height*GC.standardComboContentScale
                    }
                }

                Item{
                    width: paramList.width
                    height: 2*propertieModel.rowHeight
                    Label{
                        id: itrLabel
                        anchors.left: parent.left
                        font.pointSize: root.pointSize
                        text: Z.tr("I Transformer:")
                    }
                    Column{
                        anchors.right: parent.right
                        width: Math.min(parent.width-itrLabel.width,parent.width/2)
                        height: 2*propertieModel.rowHeight
                        ZLineEdit {
                            id: iTrN
                            width: parent.width - comboBoxWidth
                            height: propertieModel.rowHeight
                            anchors.right: parent.right
                            anchors.rightMargin: comboBoxWidth
                            pointSize: root.pointSize
                            description.width: 50
                            description.text: "Prim:"
                            text: secEntity["PAR_DutConstantIScaleDenom"]
                            unit.text: "A"
                            validator: IntValidator{}
                            function doApplyInput(newText) {
                                secEntity["PAR_DutConstantIScaleDenom"]=newText
                            }
                        }

                        ZLineEdit {
                            id: iTrZ
                            width: parent.width - comboBoxWidth
                            height: propertieModel.rowHeight
                            anchors.right: parent.right
                            anchors.rightMargin: comboBoxWidth
                            pointSize: root.pointSize
                            description.width: 50
                            description.text: "Sec:"
                            text: secEntity["PAR_DutConstantIScaleNum"]
                            unit.text: "A"
                            function doApplyInput(newText) {
                                secEntity["PAR_DutConstantIScaleNum"]=newText
                            }
                        }

                    }
                }

                Item{
                    width: paramList.width
                    height: 2*propertieModel.rowHeight
                    Label{
                        id: utrLabel
                        anchors.left: parent.left
                        //                anchors.bottom: parent.bottom
                        font.pointSize: root.pointSize
                        text: Z.tr("U Transformer:")
                    }
                    Column{
                        id: utrCol
                        anchors.right: parent.right
                        width:  Math.min(parent.width-utrLabel.width,parent.width/2)
                        height: 2*propertieModel.rowHeight

                        Item{
                            height: propertieModel.rowHeight
                            width: parent.width
                            ZLineEdit {
                                id: uTrN
                                width: parent.width-uZComb.width
                                height: propertieModel.rowHeight
                                anchors.right: uNComb.left
                                pointSize: root.pointSize
                                description.width: 50
                                description.text: "Prim:"
                                text:secEntity["PAR_DutConstantUScaleDenom"].replace("/sqrt(3)","")
                                unit.text: "V"
                                validator: RegExpValidator{ regExp: /^[1-9][0-9]*$/ }
                                function doApplyInput(newText) {
                                    secEntity["PAR_DutConstantUScaleDenom"]=newText+uNComb.currentText
                                }
                            }
                            ZVisualComboBox{
                                id: uNComb
                                height: propertieModel.rowHeight
                                anchors.right: parent.right
                                width: comboBoxWidth
                                contentRowHeight: height*1.2
                                model: ["","/sqrt(3)"]
                                imageModel: ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png"]
                                automaticIndexChange: true
                                popup.z: 1
                                currentIndex:{
                                    if(secEntity.PAR_DutConstantUScaleDenom.includes("/sqrt(3)")){
                                        return 1;
                                    }
                                    return 0;
                                }
                                onSelectedTextChanged: {
                                    secEntity.PAR_DutConstantUScaleDenom=uTrN.text+selectedText
                                }
                            }
                        }


                        Item{
                            height: propertieModel.rowHeight
                            width: parent.width
                            ZLineEdit {
                                id: uTrZ
                                width: parent.width-uZComb.width
                                height: propertieModel.rowHeight
                                anchors.right: uZComb.left
                                pointSize: root.pointSize
                                description.width: 50
                                description.text: "Sec:"
                                text: secEntity["PAR_DutConstantUScaleNum"].replace("/sqrt(3)","")
                                unit.text: "V"
                                validator: RegExpValidator{ regExp: /^[1-9][0-9]*$/ }
                                function doApplyInput(newText) {
                                    secEntity["PAR_DutConstantUScaleNum"]=newText+uZComb.currentText
                                }
                            }
                            ZVisualComboBox{
                                id: uZComb
                                height: propertieModel.rowHeight
                                anchors.right: parent.right
                                width: comboBoxWidth
                                contentRowHeight: height*1.2
                                model: ["","/sqrt(3)"]
                                imageModel: ["qrc:/data/staticdata/resources/x_1.png", "qrc:/data/staticdata/resources/x_1_over_sqrt_3.png"]
                                automaticIndexChange: true
                                popup.z: 1
                                currentIndex:{
                                    if(secEntity.PAR_DutConstantUScaleNum.includes("/sqrt(3)")){
                                        return 1;
                                    }
                                    return 0;
                                }
                                onSelectedTextChanged: {
                                    secEntity["PAR_DutConstantUScaleNum"]=uTrZ.text+selectedText
                                }
                            }
                        }

                    }

                }

            }



            ListView{
                id: paramList
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 2*parent.width/3
                spacing: 5
                model: propertieModel

            }

            Rectangle{
                id: circImageBorder
                width: circImage.width-5
                height: circImage.height-5
                anchors.right: parent.right
                Image {
                    id: circImage
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    width: page1.width/4
                    source: "qrc:/data/staticdata/resources/transMeterIllustration.jpg"
                }
                clip: true
            }


            ButtonGroup {
                id: modeGroupe
                checkedButton: {
                    if(secEntity["PAR_DutTypeMeasurePoint"].includes("IsUs")){
                            return radSecondary;
                    }else if(secEntity["PAR_DutTypeMeasurePoint"].includes("IpUp")){
                            return radPrimary
                    }else{
                            return null;
                    }
                }
            }

            Column {
                anchors.right: parent.right
                anchors.left: circImageBorder.left
                anchors.top: circImageBorder.bottom
                anchors.bottom: parent.bottom
                width: parent.width/4
                spacing: 0
                Label{
                    text: Z.tr("Measurement Point")
                }

                RadioButton {
                    id: radSecondary
                    checked: true
                    text: "Is Us"
                    height: parent.height/6
                    ButtonGroup.group: modeGroupe
                    onClicked: {
                        secEntity["PAR_DutTypeMeasurePoint"]=secEntity["PAR_DutTypeMeasurePoint"].replace("IpUp","IsUs")
                    }
                }
                RadioButton {
                    id: radPrimary
                    text: "Ip Up"
                    height: parent.height/6
                    ButtonGroup.group: modeGroupe
                    onClicked: {
                        secEntity["PAR_DutTypeMeasurePoint"]=secEntity["PAR_DutTypeMeasurePoint"].replace("IsUs","IpUp")
                    }
                }
            }
        }

Button{
    id: defaultBut
    text: FA.icon(FA.fa_undo)
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    onPressed: {
        setDefault()
    }
}
    Button{
        id: closeBut
        text: "close"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onPressed: {
            root.visible=false
            secEntity["PAR_DutConstant"]=newConst
        }
    }

}
